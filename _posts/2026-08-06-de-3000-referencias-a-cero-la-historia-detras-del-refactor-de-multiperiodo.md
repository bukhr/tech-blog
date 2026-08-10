---
layout: post
title: 'De 3.000 referencias a 0: la historia detrás del refactor de Multiperiodo'
subtitle: Cómo erradicamos un método con más de 3.000 referencias en el codebase, y lo que aprendimos en el camino sobre feature flags, análisis estático y compound engineering con IA.
author: ftorres
tags: [buk, deuda-tecnica, refactor, feature-flags, ruby-on-rails, arquitectura, multiperiodo]
background: "/assets/images/2026-08-06-de-3000-referencias-a-cero-la-historia-detras-del-refactor-de-multiperiodo/background.png"
date: 2026-08-06 12:00 -0300
---

*¿Oye pero este proyecto sale en 6 meses o no?* Plot twist: tarda 3 años. Esto es lo que ocurre cuando postergamos la solidez arquitectónica en favor de la velocidad del momento.

En Buk nos mueve construir un producto sólido, estable y confiable a largo plazo. Sin embargo, para llegar a operar en 5 países, muchas veces hemos tenido que crecer rápido. En ese camino de escala, es fácil caer en la tentación de aplicar parches o soluciones dinámicas en lugar de hacer el trabajo pesado de rediseñar desde el origen.

Desde sus inicios en el año 2017 Buk nace como una plataforma de gestión de personas chilena, diseñada de raíz con un motor de pago mensual. Unos años después, la expansión a Colombia y luego a México sacó a la luz un segmento de mercado importante: hay empresas que manejan distintas frecuencias de pago dentro de una misma organización — mensual, quincenal, semanal. El verdadero desafío no era solo soportar cada frecuencia por separado, sino que un cliente pudiera operar con todas ellas desde **una sola URL de Buk**. Sin esa capacidad, una empresa con colaboradores de distintas frecuencias necesitaba manejar 2 o 3 tenants (clientes independientes) separados.

Al principio, parecía una iteración más: adaptar la app y salir al mercado en unos meses. ¿El problema? Nuestro "villano" silencioso. Existía un método de clase llamado `variable abierta` que asumía una sola frecuencia de pago, mensual por defecto. Este método estaba fuertemente acoplado en toda la aplicación, sumando más de 3.000 referencias en el codebase (base de código). El acoplamiento era tan tóxico que rompía los límites de dominio: módulos que nada tenían que ver con sueldos —como Talento o Beneficios— se veían forzados a depender de la apertura de un periodo de pago para poder operar. Habíamos construido un producto gigante sobre un cimiento de una sola frecuencia de pago, y ahora necesitábamos que soportara semanas y quincenas, y más de una a la vez.

Para ponerlo en palabras simples: `Variable.abierta` era el método que le decía a toda la aplicación *"¿en qué período de pago estoy trabajando ahora?"* — y ese supuesto estaba sembrado en más de 3.000 lugares.

Ese es el inicio del proyecto Multiperiodo, el cual tenía como máxima permitir que un cliente con colaboradores a quienes se les paga con distinta frecuencia en su empresa pueda operar con todos ellos en una misma URL de Buk.

## La ilusión del MVP y el alto precio de las realidades paralelas

Esta iniciativa comienza a funcionar para cubrir ese dolor priorizando el mercado mexicano, que era el que más lo necesitaba. Por esto, nace un equipo que comienza a trabajar "rompiendo" la aplicación cuando se agrega más de una frecuencia de pago y corrigiendo todos los problemas que se levantaban en el camino con el objetivo de lograr un MVP (producto mínimo viable) para los clientes mexicanos.

Durante el proyecto, para habilitar a México se hicieron muchos desarrollos bajo **Feature Flags** (FF) [^1] sin un plan claro de lanzamiento al mercado. Lo importante era salir en México; total, después vemos qué hacemos para limpiar el código legacy (heredado) bajo FF.

Como es de esperarse, esconder la deuda técnica "bajo la alfombra" nos pasó factura. Utilizar Feature Flags de larga duración sin un plan de retiro explícito creó realidades paralelas dentro de nuestro código. Mantener múltiples versiones de la aplicación desató una reacción en cadena, que se puede representar de la siguiente forma:

![Divergencia exponencial de código por Feature Flags. Cada nueva FF (N) duplica el número de versiones y caminos lógicos (V = 2^N) que conviven en producción](/assets/images/2026-08-06-de-3000-referencias-a-cero-la-historia-detras-del-refactor-de-multiperiodo/divergencia-exponencial-feature-flags.png)

Esto trae varios problemas, entre los cuales cabe destacar:

- Aumento de carga cognitiva para cualquier persona que trabaja alguna parte del código condicionada por la FF, al tener que entender el funcionamiento con y sin la feature (funcionalidad).
- Si se tiene que implementar una nueva funcionalidad, tiene que convivir con ambos estados de la FF, por lo que se debe tener una solución pensada para ambos casos.
- Dificultad para debuggear (depurar) errores: ante cualquier problema levantado, se tiene que abordar teniendo en cuenta la "versión" de la aplicación que tiene el cliente, es decir, qué FFs tiene activas para entender qué flujo está usando.
- Alta complejidad de soporte para áreas como SAC y Proyectos: cualquier ticket de un cliente requería saber primero qué versión de la aplicación tenía activa antes de poder investigarlo.

Estos se amplifican cuando existen múltiples equipos en la organización, donde cada uno multiplica las versiones de la aplicación cuando está implementando features. Por esto, la convivencia de varias versiones de código debe vivir por un periodo de tiempo lo más corto posible, es decir, cada versión nueva debe tener un plan de salida para la anterior.

En el caso de Multiperiodo, se logró el MVP para México pero se usaron FFs que estaban muy enraizadas en funcionamientos "core" (fundamentales) de la aplicación, como ítems y trabajos. Las respectivas FFs de aquellos flujos estuvieron viviendo en la app por más de un año hasta que tuvieron un plan de salida (que no fue simple). Al estar en flujos tan fundamentales de Buk, dificultaban el desarrollo de nuevas features y la corrección de errores. Además, muchas de esas FFs habían sido pensadas para un país específico, por lo que al expandirse a un nuevo mercado no siempre eran compatibles. Hoy en día es un lineamiento conocido en Buk que las FFs deben tener un periodo corto de vida y que deben nacer con un plan de eliminación.

## De soluciones locales a un refactor arquitectónico

Tras el MVP en México, caímos en la tentación de replicar la fórmula directa para el siguiente mercado, Colombia. Trabajamos casi seis meses aplicando "soluciones locales" para habilitar el país, hasta que nos dimos cuenta de lo que estábamos haciendo.

Mantener Feature Flags activas y seguir parchando código alrededor de `variable abierta` significaba que cada nuevo país multiplicaba exponencialmente la deuda técnica. No estábamos construyendo una plataforma escalable; estábamos creando versiones paralelas e incompatibles de Buk.

![Versiones paralelas e incompatibles de Buk, con parches y feature flags distintas por país alrededor del método variable abierta](/assets/images/2026-08-06-de-3000-referencias-a-cero-la-historia-detras-del-refactor-de-multiperiodo/versiones-paralelas.png)

Continuar por ese camino era insostenible. Tuvimos un momento de lucidez arquitectónica y tomamos la decisión más difícil pero acertada: frenar la expansión por un momento, dar un paso atrás y apostar por la opción más "aburrida" pero correcta: extirpar el código legacy de raíz. El objetivo ya no era "habilitar Colombia", sino erradicar definitivamente el método `variable abierta` de toda la aplicación. El proyecto pasó de ser una iniciativa de un solo equipo a convertirse en una gran cruzada transversal que involucraría a gran parte de ingeniería de Buk.

## Escalando el refactor: alineación organizacional y Compound Engineering con IA

Este último tramo del proyecto significó involucrar a múltiples equipos para apoyar con la eliminación de los muchos usos que teníamos de este método en los flujos de los que cada equipo era dueño. Los desafíos que teníamos dejaron de ser de hacernos cargo de los problemas que dejamos bajo la alfombra, pasando a ser la gestión de los usos del método `variable abierta` pendientes y la coordinación con los diferentes equipos para resolver estos usos.

Cuando los equipos se involucraron en esta cruzada a fines de 2025, aún quedaban alrededor de 500 usos del método. Quedaba mucho trabajo por hacer, con muchas personas involucradas. Así, un proyecto de gran envergadura como este requería comunicación y coordinación constante, por lo que se comenzó trazando la línea de qué equipos abordarían qué usos.

Para lograr alineación total en la organización, establecimos la erradicación del método como un OKR de Ingeniería para el primer semestre de 2026. Tener una métrica transparente y compartida transformó una "tarea pesada de refactor" en un objetivo visible por toda la empresa.

Se tuvieron que involucrar muchos equipos para que resolvieran usos del método en sus flujos, entre los cuales había equipos para los que no era tan claro que este proyecto "les moviera la aguja". En ese sentido, para motivar el avance era clave hacer hincapié en por qué era positivo para ellos apoyar y priorizar en sus agendas la iniciativa, además de que tuvieran claro de qué les servía a ellos que dejáramos de depender del método `variable abierta` cuando parecía que hacerlo no les sumaba.

Cuando múltiples equipos se encontraban trabajando en la iniciativa, notamos dos puntos en el ámbito de gestión que fueron fundamentales para el avance de esta considerando su envergadura:

1. **Comunicación constante y pública.** Estar coordinados con los equipos, estar al tanto de su avance y de posibles apoyos que pudieran necesitar fue clave. Además, mantener un aviso semanal mencionando los equipos con más usos pendientes a resolver ayudó a mantener conciencia del avance total y a que los equipos avanzaran con sus usos.
2. **Deadlines (plazos) ajustados, claros y documentados.** Todo proyecto que involucre coordinación a mayor escala debe mantenerse así. Mientras más personas y equipos involucrados haya, más probables son los retrasos en la agenda.

Por el lado más *tech*, nos llevamos múltiples aprendizajes. Especialmente considerando que gran parte del proyecto se desarrolló en pleno boom de IA.

Al sumarse más equipos, chocamos con un cuello de botella evidente: los ingenieros conocían el dominio de sus módulos, pero no sabían cómo resolver el caso a caso de los usos de `variable abierta`. Para evitar que cada desarrollador gastara días descifrando el mismo patrón, decidimos aplicar el principio de *Compound Engineering* (ingeniería compuesta): construir herramientas e infraestructura que potencien exponencialmente el trabajo futuro.

Nuestra primera iteración antes de que los equipos se involucraran había sido un Playbook estático con patrones para resolver casos comunes (como los CRUDs en el frontend); si te interesa el tema, recomiendo leer [Acelerar la ingeniería de producto: por qué un playbook vale más que un framework de moda](/2026/04/09/acelerar-la-ingenieria-de-producto-por-que-un-playbook-vale-mas-que-un-framework-de-moda.html). Pero sabíamos que podíamos ir más lejos. Convertimos ese conocimiento estático en un *harness* (arnés) dinámico creando una *skill* (habilidad) de Claude. Esta *skill* no solo leía el Playbook, sino que incorporaba el contexto de nuestro codebase, reglas de arquitectura y ejemplos de refactorizaciones previas exitosas. Con este *harness*, los equipos no necesitaban adivinar: trabajaban codo a codo con la *skill* ajustada a nuestra realidad, que resolvía las partes mecánicas del refactor, retroalimentándose continuamente con cada nuevo caso de borde que encontrábamos.

## El enemigo (in)visible: UX, análisis estático y delegates

A medida que los equipos avanzaban, chocamos con otro frente crítico: el impacto directo en los clientes. Cambiar el motor de pago no era solo refactorizar código backend; implicaba alterar selectores, tablas y flujos visuales a los que miles de administradores de RRHH ya estaban acostumbrados en su rutina diaria.

Ahí entendimos que cualquier transformación estructural que altere la UX (experiencia de usuario) exige una planificación igual de rigurosa que la arquitectura del código: comunicar de forma efectiva los cambios importantes con anticipación y evitar superponer grandes lanzamientos para mantener la fricción al mínimo.

Un aprendizaje importante fue el uso de pruebas de concepto (POC, por sus siglas en inglés). Tuvimos casos donde avanzando con el proyecto nos encontramos con problemas que no habíamos detectado al momento de eliminar FFs de desarrollos ya concluidos, siendo que podríamos haberlos encontrado antes con pruebas de concepto. Además, como la forma de listar los usos del método `variable abierta` era a través de un cop personalizado de RuboCop, muchas veces la revisión estática de código quedó corta. En el camino fuimos descubriendo nuevos usos del método que el cop no detectaba. Por ejemplo, usos "hardcodeados" (escritos a mano en duro) en base de datos que se evaluaban en tiempo de ejecución, u otros que el cop no detectaba al funcionar escaneando el **Abstract Syntax Tree** (AST) [^2] con *node matchers* definidos. Esos usos del método estaban escondidos en casos puntuales de nombres de variables distintos a los buscados por el cop, o cadenas de código muy largas que el cop no tenía en su lógica de búsqueda.

El golpe definitivo al análisis estático fueron los `delegate` de Rails. El macro `delegate` permite que un objeto reenvíe llamadas de métodos a sus asociaciones (actuando como un patrón Wrapper o Facade). Cuando un modelo delegaba el método que utilizaba `variable abierta` a otro objeto, la llamada explícita desaparecía de la vista de RuboCop, escondiendo cientos de usos dinámicos detrás de interfaces aparentemente inofensivas. Esto en Rails se ve más o menos así:

```ruby
# --- Lo que RuboCop veía al escanear el proyecto ---
# En cualquier Controller, Service o Cell:
e = Employee.first
area = e.area  # Inocente. El cop no ve nada flageable aquí.

# --- La trampa estaba en el delegate del modelo ---
class Employee < ApplicationRecord
  ...
  has_many :jobs
  delegate :area,
           :empresa,
           to: :open_period_job_or_last_job,  # <-- el "villano" estaba en el to:

  has_one :open_month_job,
          -> { last_job_in_period(Variable.abierta.start_date, Variable.abierta.period_type) },
          class_name: 'Job'
          # Problema raíz: el scope ejecuta SQL usando Variable.abierta

  # --- Método intermedio ---
  def open_period_job_or_last_job
    open_month_job || last_job
  end
end
```

En el ejemplo, la cadena de llamados es:

```text
e.area
  -> e.open_period_job_or_last_job   (método en Employee)
       -> e.open_month_job           (has_one en Employee)
            -> Job.last_job_in_period(Variable.abierta.start_date, ...)  # SQL scope en modelo Job que usa variable abierta, problema!
```

Este punto ciego nos costó alrededor de 3 meses de trabajo no planificado y nos enseñó una lección invaluable: el análisis estático no es suficiente para estimar de forma precisa y completa deuda técnica profunda.

Todo esto demostró que no podíamos confiar en la revisión estática de código para lo que necesitábamos. Ahí es donde entran las pruebas de concepto: habiéndose ejecutado con anticipación, podríamos haber detectado problemas antes. Desde que tuvimos el primer caso no detectado, comenzamos a mantener POCs constantes para los diferentes proyectos que teníamos andando dentro de la iniciativa Multiperiodo, de forma de no volver a tener inconvenientes pasando desapercibidos que nos atrasaran, y así fue.

## Las cicatrices: 6 aprendizajes de un refactor estructural

Con el involucramiento de los demás equipos pudimos llegar a la meta de erradicar el uso del método en la aplicación. Esta gran iniciativa significó muchos aprendizajes para Buk, donde muchos son aplicados en proyectos que se llevan a cabo hoy en día. Me gustaría dejar los más fundamentales, algunos de los cuales me he referido y otros a los que no, brevemente enumerados:

- **Implementar OKRs nos proporciona un objetivo visible y una dirección clara.** Aunque la métrica perfecta no existe (caso de POCs), medir el progreso resulta fundamental para entender dónde estamos, poder ajustar el rumbo y saber hacia dónde nos dirigimos. Esta visibilidad mantiene al equipo alineado, enfocado y motivado al ver el impacto real de su trabajo día a día.
- **Modificaciones en la UX a la que el usuario ya está acostumbrado exigen una planificación rigurosa y una comunicación previa transparente.** Dado que los clientes son especialmente sensibles a los cambios en su rutina, es vital dosificar estas actualizaciones y evitar superponer varias transformaciones grandes dentro de la app. Al respetar su ritmo y anticipar las novedades, minimizamos la fricción y garantizamos una transición fluida y positiva.
- **Aplicar *Compound Engineering* mediante el uso de *harnesses* exige poner herramientas a disposición tanto de personas como de máquinas lo antes posible, manteniéndolas en constante evolución.** En nuestro caso, este concepto se concretó en la creación de una *skill* clave, demostrando que habilitar capacidades a tiempo e iterar sobre ellas continuamente potencia tanto el trabajo del equipo como la eficiencia de nuestros sistemas.
- **Usar Feature Flags sin un plan de eliminación crea "versiones paralelas" de la aplicación.** Esto dispara la carga cognitiva del equipo, complica el debugging exponencialmente y fuerza a que cada nuevo desarrollo tenga que contemplar múltiples estados del código.
- **La revisión estática de código no es suficiente para estimar de forma precisa deuda técnica profunda.** Para refactorizaciones estructurales, confiar ciegamente en el código estático deja alcance invisible. Las pruebas de concepto pueden ser un gran apoyo.
- **Visión macro por encima de soluciones locales.** Resolver dolores inmediatos de un mercado (como habilitar un país a la vez) sin abordar el problema de raíz termina multiplicando la deuda técnica. Reconocer cuándo frenar las soluciones temporales para encarar la solución estructural suma a la escalabilidad a largo plazo.

Erradicar `variable abierta` no fue un proyecto vistoso ni lleno de arquitectura ostentosa. Fue una maratón de años de limpieza, coordinación transversal, estandarización de código e infraestructura de soporte.

Hoy, extender la lógica de pagos a nuevas frecuencias o mercados ya no exige ser un "arqueólogo del código", sino construir sobre reglas claras y una arquitectura mucho más predecible. Así es como construimos en Buk: prefiriendo la solidez y la mantenibilidad a largo plazo por sobre la falsa velocidad de los atajos. Pagar la deuda técnica de raíz es lo que nos permite seguir iterando con confianza.

Al final, de eso se trata: *The beauty of boring tech*.

Si te interesa trabajar en problemas como este, [postula aquí](https://www.takealuk.com/empleos-buk?q%5Bname_cont%5D=&countries%5B%5D=Chile).

---

[^1]: [Feature Flag (FF)] Técnica de desarrollo de software que permite que equipos enciendan y apaguen funcionalidades en tiempo de ejecución sin tener que desplegar nuevo código.
[^2]: [Abstract Syntax Tree (AST)] Estructura de datos jerárquica que representa la estructura lógica y sintáctica del código fuente.
