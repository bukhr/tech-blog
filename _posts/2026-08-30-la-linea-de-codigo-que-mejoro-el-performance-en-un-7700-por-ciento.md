---
layout: post
title: La línea de código que mejoró el performance en un 7.700%
subtitle: Cómo un valor de retorno que nadie usaba se convirtió en el 99% del tiempo de carga de una página
author: ginzunza
tags: [ruby, rails, performance, profiling, flamegraph]
date: 2026-08-30 12:00 -0400
---
La ficha del empleado de unos clientes tardaba 70 segundos en cargar. Después del fix, la ficha respondía en menos de 1 segundo: ~78 veces más rápido. La solución fue agregar una sola instrucción: `nil`. Esta es la historia de cómo un valor de retorno que nadie usaba se convirtió en el 99% del tiempo de carga de la página, y sobre como usar *flamegraph*, y no la intuición (optimizar la DB), fue lo que resolvió el problema.


## El inicio: 70 segundos para ver una ficha

Un cliente reportó que la ficha de sus empleados era inusable y que, por lo tanto, no podía trabajar. Coincidentemente empezaron a aparecer *timeouts* en los logs, lo que dio la idea de que podría haber sido introducido por un cambio reciente. Al reproducir el caso con [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler), la request completa tardaba ~70 segundos, y el 99% de ese tiempo lo consumía un solo render: la cell del perfil del empleado, con 69,5 segundos y 569 queries SQL.

La intuición inicial apuntaba a los sospechosos de siempre: queries lentas, demasiados campos personalizados, algún cálculo pesado en la vista. El profiler descartó al primero de inmediato: solo el 0,4% del tiempo era SQL. El 99,6% restante era Ruby puro.

## El análisis: un flamegraph donde el protagonista era el Garbage Collector

El flamegraph obtenido con [stackprof](https://github.com/tmm1/stackprof) mostró algo inesperado:

- El 58% del tiempo era *garbage collection*: 43% *marking* y 15% *sweeping*.
- El 39% del tiempo pasaba por `Array#inspect`, que terminaba en `CanCan::Rule#inspect` (37%) y `ActiveRecord::Core::ClassMethods#inspect` (25%).
- Las 569 queries del render eran queries que nadie había escrito.

Es decir, casi todo el tiempo de la request no era trabajo de la página. Era Ruby serializando objetos que nadie iba a leer, y el GC limpiando las montañas de strings que esa serialización alocaba.

Con la evidencia anterior, aún era difícil de saber en dónde estaba exactamente el problema, así como también era difícil comprender qué cambio lo introdujo, puesto que en Buk se hacen cientos de commits al día

## La causa: un valor de retorno que ERB serializaba sin que nadie lo pidiera

Luego de tener toda la evidencia y entender que el problema estaba en Ruby en vez de la base de datos, ocupamos Claude para ver si nos facilitaba la parte más abstracta que era el análisis sobre qué parte del código era la involucrada y pudimos concluir lo siguiente:

La causa se podía dividir en tres partes:

1. Los métodos `item` de nuestros widgets de formulario terminaban en `@items << {}`, por lo que retornaban el array `@items` completo.
2. En ERB, `<%= widget.item do %>...<% end %>` llama `.to_s` sobre ese valor de retorno. Para un array, `.to_s` es `Array#inspect`: inspecciona recursivamente todo lo acumulado adentro.
3. Entre los objetos acumulados había reglas de autorización de [CanCanCan](https://github.com/CanCanCommunity/cancancan), cuyas condiciones son scopes de ActiveRecord. Inspeccionar cada regla materializaba sus scopes (las queries fantasma) y cargaba el schema de cada clase involucrada.

Nada de esto era visible leyendo el código. El `<%= %>` era idiomático, el `@items << {}` era idiomático, y las reglas de CanCanCan estaban donde debían estar. El problema solo existía en la combinación de los tres.

Por lo mismo, revertir no era una opción viable: no era rápido detectar si había un commit culpable que deshacer y teníamos a muchos clientes bloqueados por la lentitud. El único camino era resolverlo.

## La solución: retornar `nil`

La corrección fue agregar `nil` como último valor de retorno de los métodos `item`:

```ruby
def item(...)
  @items << { ... }
  nil
end
```

Con esto, `<%= widget.item do %>` retorna `nil.to_s`, que es un string vacío, sin gatillar ninguna inspección (`Array#inspect`). El contenido del bloque no se ve afectado: el mecanismo de captura (`capture(&block)`) opera independientemente del valor de retorno, y el widget sigue renderizando los ítems desde su `@items` interno.

El cambio completo fueron *2 líneas en 2 archivos*, omitiendo lo que sumó el hecho de sumarlo detrás de una *feature flag* para un rollout seguro.

## El resultado: de 70 segundos a 0,9

Luego de aplicar los cambios y volver a analizar, se obtuvo lo siguiente:

- La request completa bajó de ~70 segundos a ~0,9 segundos: 78 veces más rápido, una mejora de 7.700%.
- El render del perfil bajó de 69.498 ms a 95 ms, y sus queries de 569 a 28.

## Conclusiones

- **Analiza antes de optimizar.** Por lo general las hipótesis siempre parten sin evidencia y se inclinan por la base de datos o algún feature que ha ocasionado problemas en el pasado. Es importante ocupar las herramientas de profiling o monitoreo que se tienen disponibles. En este caso el profiler, el flamegraph y el *análisis de Claude* encontraron en minutos algo que en el pasado habría significado leer código, debugging y mucho trabajo manual 
- **Si el GC es el protagonista, busca quién aloca.** Un 58% de tiempo en *garbage collection* no es un problema del GC: es el síntoma de que algo está creando objetos de forma masiva. Aquí eran los strings de `inspect`.
- **Los valores de retorno implícitos de Ruby son API.** Un método que termina en `@items << {}` retorna el array completo aunque nadie lo pida. Si ese método se usa en ERB con `<%= %>`, ese retorno se serializa.
- **`inspect` no es gratis.** Sobre objetos que envuelven scopes de ActiveRecord, inspeccionar significa ejecutar SQL. Un simple `to_s` puede significar cientos de queries.
- **No te conformes con resolver, evita que vuelva a suceder.** Hace poco cambiamos de proveedor para medir performance en distintos módulos con datos de producción. Por lo tanto, luego de que esto sucedió se priorizó rehacer dashboards que miden explícitamente que el performance de la ficha esté en números saludables
