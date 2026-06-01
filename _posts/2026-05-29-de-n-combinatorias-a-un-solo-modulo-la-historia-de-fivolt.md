---
layout: post
title: 'De N combinatorias a un solo módulo: la historia de FIVOLT'
subtitle: Cómo mapeamos, simplificamos y homologamos el módulo de vacaciones en 5 países sin perder la cordura en el camino.
author: mgarcia
tags: [buk, deuda-tecnica, vacaciones, ruby-on-rails, arquitectura, escalabilidad]
image: "/assets/images/2026-05-29-de-n-combinatorias-a-un-solo-modulo-la-historia-de-fivolt/img-metadata.png"
date: 2026-05-29 12:00 -0300
---

Hay un tipo de deuda técnica (technical debt) que no nace de la negligencia. Nace de la velocidad. En Buk somos una empresa que opera en 5 países y, para llegar hasta acá, tuvimos que crecer rápido. Muy rápido. Y cuando creces rápido, a veces la solución más pragmática es adaptar lo que ya existe en lugar de rediseñar desde cero.

Así fue como el módulo de vacaciones terminó siendo, en la práctica, varios módulos distintos conviviendo bajo el mismo techo. Y en algún punto del camino tomamos una decisión: en lugar de seguir parcheando país por país, íbamos a hacer un gran arreglo de una sola vez y dejar todo en la misma versión. Solo una vez. De ahí nació el nombre **FIVOLT**: *Fix Vacation One Last Time*.

## El punto de partida: un módulo, muchos países, N realidades

Las vacaciones parecen simples desde afuera, pero cada país tiene su propia legislación, sus propios ciclos, sus propias reglas de devengo (acumulación de días). México no es Chile. Brasil no es Colombia. Perú tiene sus particularidades. Y así, a medida que Buk fue expandiéndose, el módulo de vacaciones fue acumulando variantes: flags (banderas) de activación por país, lógicas condicionales, y capas de configuración que se fueron apilando con el tiempo.

El resultado era funcional, pero frágil. Cada vez que llegaba un error, el primer paso no era entender el bug en sí, sino hacer un diagnóstico previo: ¿en qué país ocurrió? ¿Qué combinación de features (funcionalidades) estaba activa para ese tenant (cliente)? Solo con esa información era posible reproducir el problema en local y empezar a investigar.

Y arreglar tampoco era simple. Una corrección que funcionaba perfectamente para Chile con ciertas features activas podía romper silenciosamente otra combinación de país y configuración que nadie había pensado testear. El espacio de posibilidades era enorme, y cubrirlo todo manualmente era inviable.

![Estado del módulo de vacaciones antes de FIVOLT](/assets/images/2026-05-29-de-n-combinatorias-a-un-solo-modulo-la-historia-de-fivolt/problema-actual.png)

## El mapa del problema: ¿cuántas combinatorias teníamos?

El primer paso fue honesto y necesario: sentarnos a mapear. No asumir que sabíamos cuántas variantes había, sino contarlas.

El resultado fue revelador en dos sentidos. Por un lado, teníamos features que vivían en distintos estados según el país: algunos completamente activos, otros parcialmente desplegados, otros inexistentes. Y entre ellos existían dependencias implícitas, es decir, feature B asumía que feature A estaba activo, pero eso no estaba documentado en ningún lado. Solo lo sabía quien había escrito el código.

Por otro lado, y quizás lo más importante: al mapear con detalle cómo cada país calculaba sus vacaciones, nos dimos cuenta de que la lógica de fondo no era tan diferente entre ellos. Los plazos legales varían, los nombres cambian, pero el modelo de cálculo es esencialmente el mismo. Tener tantas versiones paralelas no solo era costoso de mantener — en gran medida, tampoco tenía sentido. No estábamos modelando realidades tan distintas como creíamos; estábamos repitiendo la misma lógica de formas ligeramente distintas, fragmentadas por país.

Con todo eso sobre la mesa — las dependencias implícitas, las combinatorias sin control y la confirmación de que el modelo podía ser uno solo — quedó claro qué había que construir. Las iniciativas que componen FIVOLT son:

- **Vacaciones V2** — Un nuevo motor que reemplazó la lógica original. En lugar de un tipo de vacación fijo, V2 introduce tipos de vacaciones configurables, cada uno con sus propias reglas de devengo. Esto nos dio la flexibilidad que necesitábamos para modelar las distintas realidades legales de cada país.

- **Cálculo Iterativo** — Cambió la forma en que calculamos el saldo disponible. En lugar de recalcular desde cero en cada consulta, cada evento relevante (como una solicitud de vacaciones aprobada) genera una transacción que se acumula. Esto hizo el sistema más predecible y más fácil de auditar.

- **Reasignación** — Flexibilizó la forma en que se asignan las políticas de vacaciones a los empleados, desacoplando esa lógica de estructuras que resultaron ser innecesariamente rígidas.

- **Multiperiodo** — Hizo que los flujos de vacaciones sean independientes del periodo contable abierto, eliminando una restricción que generaba fricción operacional.

Cada uno de estos features tenía un estado distinto en cada país. Al cruzar 4 features con 5 países más sus variantes intermedias ("en rollout", "parcial", "pendiente"), el tablero de combinaciones era considerable.

Y sobre esta capa principal existían otras variantes menores: pequeñas adaptaciones, flags específicos por tenant, comportamientos que algún equipo había parchado puntualmente para un mercado. No tenían el mismo impacto que los features de FIVOLT, pero sumaban ruido y ampliaban el espacio de posibilidades que había que considerar ante cualquier cambio.

![Mapa del problema con los features y países](/assets/images/2026-05-29-de-n-combinatorias-a-un-solo-modulo-la-historia-de-fivolt/mapa-problema.png)

## La decisión: dependencias explícitas y orden de migración

Una vez que teníamos el mapa, el siguiente paso fue hacer explícitas las dependencias entre features. Esto fue clave. En lugar de dejar ese conocimiento en la cabeza de las personas, lo formalizamos: Cálculo Iterativo requiere V2. Multiperiodo requiere V2 y Reasignación. Sin ese orden, una migración podía dejar a un país en un estado inconsistente.

Con el mapa de dependencias claro, pudimos definir el orden de rollout (despliegue gradual) por país de forma mucho más deliberada.

## El dilema de la experiencia de usuario

Había una tensión real en la estrategia de migración. La opción conservadora era mover a cada país de un feature a la vez: primero V2, luego Cálculo Iterativo, luego Reasignación, y así sucesivamente. Eso era técnicamente más sencillo de implementar y de hacer rollback (revertir) si algo salía mal.

Pero desde la perspectiva del usuario, esa opción tenía un costo importante: significa que los administradores de RRHH verían cambios en la interfaz y en los flujos de vacaciones no una, sino varias veces en pocos meses. Cada migración parcial implica una nueva curva de aprendizaje, nueva documentación, nuevas preguntas al soporte.

La decisión fue clara: cuando migrábamos un país, la meta era hacerlo con la mayor cantidad de features posibles de una sola vez. No porque sea más fácil — es técnicamente más exigente en coordinación y testing — sino porque el cambio de experiencia para el cliente es mucho más limpio. Si vas a pasar de una versión a la siguiente, y luego a la siguiente, en el transcurso de pocos meses, el usuario siente cada transición: nueva interfaz, nueva documentación, nueva curva de aprendizaje, nuevas preguntas al soporte. En cambio, un solo cambio grande, aunque más complejo de ejecutar, se percibe como una sola mejora. El esfuerzo técnico mayor compra una experiencia de usuario mucho más cómoda.

Esta fue la decisión correcta para FIVOLT, dado que los features tenían dependencias claras entre sí y el objetivo era precisamente eliminar los estados intermedios. Pero no es una regla universal: en otros contextos, una migración incremental y de a poco puede ser igualmente válida, especialmente cuando los cambios son más independientes o el riesgo de una transición grande es difícil de acotar. Lo importante es que la estrategia de rollout sea una decisión consciente, no una consecuencia de no haber pensado en las alternativas.

## El resultado: de variantes a un estándar

Hoy, todos los features de FIVOLT están al 100% en los 5 países. Vacaciones V2 es el comportamiento por defecto. El Cálculo Iterativo, Reasignación y Multiperiodo también están completamente desplegados. No hay país en un estado intermedio, no hay combinatoria pendiente. La promesa del nombre se cumplió.

El módulo de vacaciones sigue siendo complejo, porque la legislación de cada país es compleja. Pero esa complejidad ahora está modelada explícitamente en la configuración de cada tipo de vacación, no escondida en condicionales dispersos por el código. La diferencia entre un bug en Chile y uno en Colombia ya no requiere un arqueólogo del código para entenderla.

## Lo que aprendimos

Si tuviéramos que resumir el aprendizaje en cuatro ideas:

**1. La deuda técnica por velocidad es inevitable en una startup, pero tiene que ser consciente.** El problema no fue crecer rápido ni adaptar el código por país. El problema fue no documentar las dependencias y dejar que el conocimiento quedara implícito.

**2. Mapear antes de migrar.** Sin un inventario honesto del estado de cada feature en cada país, cualquier plan de migración está construido sobre suposiciones. El trabajo de mapeo fue más valioso de lo que parecía al principio.

**3. El esfuerzo técnico mayor puede ser la mejor experiencia para el usuario.** Migrar todo de una vez fue más difícil de coordinar, pero produjo un cambio más claro y más cómodo para quienes usan el producto todos los días. A veces la simplificación para el equipo de ingeniería va en contra de la experiencia del cliente, y vale la pena asumir la complejidad técnica para proteger esa experiencia.

**4. Pagar la deuda técnica sí tiene retorno concreto.** Antes de FIVOLT, cuando el equipo construía una mejora en el módulo de vacaciones, la pregunta inevitable era: ¿a quién le llega esto? ¿A Chile? ¿A México también? ¿O tiene que esperar a que termine la migración? Muchas veces la respuesta era que algunos países recibirían la mejora y otros no, al menos por un tiempo. Hoy, con un solo modelo consolidado, cualquier feature nuevo que construimos llega a todos los países al mismo tiempo. El módulo de vacaciones tiene ownership (control total) sobre sus propias capacidades: podemos iterar, corregir y mejorar con la certeza de que el impacto es universal y predecible. Esa velocidad de ejecución no habría sido posible sin haber ordenado primero la casa.

FIVOLT no terminó de un día para otro. Fue un esfuerzo sostenido de varios equipos, con muchas iteraciones y más de algún bug inesperado en el camino. Pero hoy tenemos un módulo de vacaciones que podemos entender, mantener y extender con mucho más confianza. Y eso, en un sistema que toca los días libres de miles de personas, no es poca cosa.
