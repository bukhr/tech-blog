---
layout: post
title: 'Cuando el calendario legal dejó de mandar: cómo Remuneraciones Perú estabilizó su operación'
subtitle: Pasamos de detener el delivery cada vez que tocaba pagar la CTS a una operación predecible. La clave fue entregar menos durante un tiempo para adelantarnos a cada hito legal.
author: cbecerra | rlira
tags: [buk, remuneraciones, peru, operacion, deuda-tecnica, producto, ingenieria]
images_path: "/assets/images/2026-10-08-cuando-el-calendario-legal-dejo-de-mandar"
date: 2026-10-08 10:00 -0300
---

En mayo de 2024 el equipo de Remuneraciones Perú recibió 43 tickets en un solo mes. Mayo es mes de pago de la CTS, y ese año, como en los anteriores, la CTS ganó: dejamos de lado las misiones en curso y todo el equipo se puso a atender operación hasta que el pago salió.

No era la primera vez. En 2023 habíamos cerrado el año con 395 tickets derivados a ingeniería, y cada hito del calendario laboral peruano traía su propia ola. Este post cuenta cómo salimos de ese ciclo. Hoy el equipo atiende unos 30 tickets por trimestre con muchos más clientes que en 2023, y entrega sin reservar la mitad de su capacidad para apagar incendios.

## Vivir al ritmo del calendario legal

Para quien no trabaja con nómina peruana, el contexto es este. Además del pago mensual, la ley exige varios pagos y cálculos con fecha fija:

- **CTS** (Compensación por Tiempo de Servicios), en mayo y noviembre.
- **Gratificaciones**, en julio y diciembre.
- **Reparto de utilidades**, entre marzo y abril.
- **Renta de quinta categoría**, el impuesto que se retiene y proyecta cada mes y se regulariza al cierre del año.

Cada uno tiene reglas propias: qué remuneraciones son computables, cuántos días cuentan como efectivamente laborados, cómo se promedian los ingresos variables. Y la fiscalización (SUNAFIL) no da margen para "lo corregimos el próximo mes".

En 2023 cada uno de esos hitos llegaba con una ola de tickets. Solo la CTS generó 65 en el año. El primer trimestre, que junta utilidades y el cierre anual, sumó 135. El equipo vivía en dos modos: las semanas tranquilas, en las que avanzaba el roadmap, y las semanas de pago, en las que no se avanzaba nada más.

## Entregar menos para adelantarnos

Las paradas por la CTS fueron las que forzaron la conversación. Andrés Howard, Engineering Manager del equipo en ese momento, y Ricardo Lira, entonces Product Manager de Perú, llegaron a la misma conclusión desde lados distintos. Seguir atendiendo cada ola cuando llegaba nos costaba más capacity (capacidad del equipo) que corregir los cálculos antes de que llegara.

El acuerdo fue explícito: durante un tiempo el equipo iba a entregar menos funcionalidades nuevas, y esa capacidad iría a misiones de estabilización de cada beneficio social. Les pusimos un nombre que no deja dudas sobre el objetivo: **Adelantémonos a X**, con X igual a CTS, Gratificación o Utilidades.

La primera fue "Adelantémonos a la CTS Noviembre 2024". El discovery partió a fines de agosto, con el pago a tres meses de distancia. En la planificación de septiembre, tres ingenieros quedaron dedicados a esa misión, la misma cantidad que la misión más grande en curso, y uno más a la guardia de tickets. El alcance salió de los tickets del semestre anterior y de entrevistas con consultores de soporte y con el negocio:

- Calcular la remuneración variable complementaria según los meses efectivamente laborados.
- Considerar la información histórica del colaborador en el cálculo.
- Corregir el reporte predefinido de CTS para que tome los bonos vigentes en el periodo.

El documento de negocio se compartió en un canal abierto con las áreas interesadas, para recibir comentarios antes de escribir código, y la parte más riesgosa quedó detrás de una configuración que permitía hacer rollback (volver atrás) por cliente.

"Entregar menos" también significó decir que no. A fines de octubre de 2024 descartamos la misión de mejoras de gratificación que apuntaba al pago de diciembre. No había capacity para sostenerla junto con la CTS y los otros compromisos de fin de año.

## La primera prueba

El pago de CTS de noviembre de 2024 dejó cinco tickets relacionados. Solo uno afectaba el cálculo, un caso atípico de permisos de media jornada rechazados. Los otros cuatro eran de reportería.

Un mes después llegó la gratificación de diciembre, la que habíamos dejado fuera. A mitad de mes ya teníamos más tickets que en todo diciembre de 2023, y cerramos el mes con 25 frente a una meta de 16. Fue la comparación más clara que podíamos pedir: el hito que preparamos pasó casi sin ruido y el que no preparamos se comportó como siempre.

Desde ahí, adelantarse dejó de ser un experimento y pasó a ser la forma de planificar. Cada semestre la estrategia del equipo parte por mirar qué hitos legales vienen y qué tickets dejó el anterior.

## Qué significa adelantarse en la práctica

Adelantarse a un pago no es solo empezar antes. Las misiones funcionaron porque cambiamos cómo construimos y cómo liberamos los cambios en cálculos.

**Corregir en el código, no en la consola.** Antes, una parte de los tickets se cerraba con un script ejecutado por consola sobre los datos del cliente. El problema quedaba resuelto para ese cliente y volvía a aparecer en el siguiente. Hoy más del 90% de los tickets termina en un Pull Request mergeado en el repositorio principal. Si un cálculo está mal, se corrige el cálculo.

**Validar sin activar.** Para las migraciones grandes de lógica de cálculo construimos jobs que ejecutan el cálculo nuevo y el antiguo sobre los datos reales de cada cliente, sin activar nada, y reportan los descuadres. Eso nos dejó corregir diferencias antes del rollout (despliegue progresivo) y no después de que el cliente las viera. Más de una vez esa validación encontró bugs en código que ya estaba en producción, no solo en el cambio que estábamos validando.

**Todo cambio en cálculos se puede apagar.** Liberamos los cambios detrás de feature flags (interruptores de funcionalidad) o configuraciones por cliente. En octubre de 2024 un ticket urgente necesitaba un fix cuyo pipeline no iba a terminar dentro del SLO (objetivo de tiempo de respuesta). Apagamos la funcionalidad para ese cliente, lo destrabamos a tiempo y mergeamos la corrección de raíz después, sin presión. En 2025, una estrategia de rollback preparada de antemano nos permitió revertir el rollout de un cambio en el cálculo de liquidaciones (finiquitos) antes de que se generara una sola liquidación con error.

**Tests que cubren el flujo completo.** Agregamos tests de integración que recorren el cálculo de un finiquito de punta a punta. Detectaron varios bugs antes de que empezara el rollout de una migración del cálculo de liquidaciones. Y quedó como regla del equipo que, en remuneraciones, casi cualquier cálculo se puede representar en un test, así que la prueba manual es el último recurso.

**Tiempo reservado para deuda técnica.** Los martes de deuda técnica se volvieron un bloque fijo para limpiar flaky tests (tests inestables), agregar tipos con Sorbet y retirar feature flags viejas. Durante buena parte de 2025 el equipo mantuvo cero flaky tests.

**Mirar los tickets juntos.** Cada dos semanas revisamos los tickets de la guardia con producto, con su origen y tipo de solución. De esa revisión salen las tareas que corrigen la causa y, cada semestre, las misiones "Adelantémonos" del siguiente hito.

## Los meses que dejaron de dar miedo

En mayo de 2025 la CTS dejó 15 tickets en el mes. Un año antes habían sido 43. Abril cerró con 8 tickets, la mitad de la meta mensual. En septiembre completamos la activación de las correcciones de quinta categoría en liquidaciones sin un solo ticket asociado, y hubo una quincena con un único ticket en total.

No todo salió a la primera. En julio de 2025 una de las misiones de gratificación tuvo errores y solo pudimos liberar una parte antes del pago. Seis meses después, la gratificación de diciembre pasó sin ruido, a pesar de que cambiamos la metodología de cálculo del periodo. Esa vez la activamos antes del pago y ningún cliente reportó errores.

## Dónde estamos hoy

| Año | Q1 | Q2 | Q3 | Q4 | Total |
|-----|----|----|----|----|-------|
| 2023 | 135 | 110 | 95 | 55 | 395 |
| 2024 | 76 | 83 | 66 | 62 | 287 |
| 2025 | 54 | 36 | 38 | 41 | 169 |
| 2026 | 30 | 31 | 29 | | 90 |

*Tickets derivados a ingeniería por trimestre. Datos de 2026 al 11 de septiembre.*

En el mismo periodo la base de clientes creció varias veces, así que la tabla se queda corta: medidos por cliente, los tickets bajaron un 93%.

El número que más nos importa no está en la tabla. La operación dejó de decidir el roadmap. La carga se mueve en una banda de 10 a 15 tickets al mes, que la guardia absorbe sin sacar gente de las misiones. En octubre de 2025 el equipo tuvo su mejor mes de delivery, con 58 tareas entregadas, y ese mismo mes terminamos el último de los proyectos de liquidaciones que veníamos trabajando desde 2024.

Los hitos legales siguen generando más conversación. En noviembre de 2025 la CTS volvió a subir los tickets y superamos la meta del mes por uno. La diferencia es qué tipo de tickets llegan: ese mes fueron sobre todo solicitudes de cambios de datos, no errores de cálculo.

## Lo que aprendimos

- **La estabilidad se negocia.** Nada de esto habría pasado sin un acuerdo explícito entre producto e ingeniería para entregar menos durante un tiempo. Que el acuerdo tuviera nombre y fecha ("Adelantémonos a la CTS Noviembre 2024") ayudó a que nadie lo viera como una pausa indefinida.
- **El calendario es una ventaja.** Sabemos con meses de anticipación cuándo va a llegar cada ola. Planificar alrededor de esas fechas es más barato que reaccionar a ellas.
- **Decir que no también enseña.** La gratificación de diciembre de 2024 nos mostró, con números, cuánto cuesta no adelantarse.
- **Un cambio en cálculos se tiene que poder probar sin activarlo y apagar sin un deploy.** Las validaciones en solo lectura y las feature flags nos dieron esa red.

## Lo que viene

Los tickets que siguen llegando tienen otra forma. Los flujos estándar están estables, y lo que queda son combinaciones poco frecuentes: el régimen de Remuneración Integral Anual con gratificaciones mensualizadas, cambios de cobertura de salud justo en un mes de gratificación o ceses con remuneraciones variables altas en el último trimestre. Para esos casos queremos una suite de tests de regresión que simule combinaciones de regímenes.

Otra parte de los tickets no son bugs, sino solicitudes operativas, como desbloquear la ficha de un colaborador después de su cese. El siguiente paso es que el equipo de soporte pueda hacer esas acciones por su cuenta, con herramientas internas guiadas y seguras, sin pasar por ingeniería.

Y el primer trimestre, con utilidades y la regularización anual de quinta, sigue siendo el de mayor volumen. Ya sabemos qué hacer con eso: adelantarnos.
