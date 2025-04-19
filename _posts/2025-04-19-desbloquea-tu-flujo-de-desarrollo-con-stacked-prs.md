---
layout: post
title: Desbloquea tu Flujo de Desarrollo con Stacked PRs
subtitle: Aprende a optimizar tu flujo de desarrollo con las PRs en pila
author: aboneto
tags: Git, Pull Requests, Stacking Workflow, Stacked PRs
images_path: "/assets/images/2025-04-19-desbloquea-tu-flujo-de-desarrollo-con-stacked-prs"
image: "/assets/images/2025-04-19-desbloquea-tu-flujo-de-desarrollo-con-stacked-prs/img-metadata.jpeg"
background: "/assets/images/2025-04-19-desbloquea-tu-flujo-de-desarrollo-con-stacked-prs/background.jpeg"
date: 2025-04-19 13:46 -0400
---
¿Te has encontrado alguna vez con una larga lista de cambios en un Pull Request (PR) que dificulta la revisión y retrasa la integración? ¡No estás solo! En el mundo del desarrollo de software, la complejidad a veces se acumula, y los PRs extensos pueden convertirse en un cuello de botella.

Es aquí donde entran en juego los **Stacked Pull Requests** (PRs apilados), una técnica poderosa para dividir cambios grandes y complejos en una serie de PRs más pequeños, independientes y fáciles de revisar.

## ¿Qué son los Stacked Pull Requests?

Los **Stacked Pull Requests** (PRs apilados) son una técnica de flujo de trabajo en el desarrollo de software que consiste en dividir un conjunto de cambios relacionados en una **serie de Pull Requests más pequeños e independientes** que se construyen uno encima del otro.

**Imagina una pila de panqueques:** cada panqueque individual es un PR. El primer PR (el de la base) contiene un conjunto de cambios. El segundo PR se construye encima del primero, incluyendo sus propios cambios y los cambios del PR anterior. El tercer PR se construye sobre el segundo, y así sucesivamente.

**La idea principal es descomponer un cambio grande y potencialmente complejo en partes más pequeñas y manejables.** En lugar de enviar un único PR masivo con cientos o incluso miles de líneas de código que abarca varias funcionalidades o refactorizaciones, se crean varios PRs más pequeños, cada uno enfocado en una parte lógica y coherente del cambio total.

## ¿Cuáles son los beneficios de adoptar Stacked PRs?

- **Revisiones de código más rápidas y efectivas:** Los PRs más pequeños son inherentemente más fáciles de entender y revisar. Los revisores pueden concentrarse en un conjunto de cambios más reducido y lógico, lo que permite una inspección más detallada y una retroalimentación más rápida y precisa. Esto reduce el tiempo de ciclo general y acelera la integración de código.

- **Menor riesgo de errores y regresiones:** Al integrar cambios más pequeños y enfocados, se minimiza la probabilidad de introducir errores complejos y difíciles de rastrear. Si surge un problema, es más fácil aislar la causa en un PR específico. Además, la revisión más exhaustiva de cada parte reduce la posibilidad de que los errores pasen desapercibidos.

- **Mejor colaboración y comunicación:** Los PRs más pequeños facilitan la discusión y el intercambio de ideas entre los desarrolladores y los revisores. Es más sencillo comentar sobre una parte específica del cambio sin sentirse abrumado por una gran cantidad de código. Esto fomenta una colaboración más fluida y constructiva.

- **Integración continua más fluida:** Los PRs más pequeños se integran más fácilmente en la rama principal o de desarrollo. Esto reduce los conflictos de merge, que suelen ser más comunes y complejos con PRs grandes. Una integración continua más fluida mantiene la base de código actualizada y reduce los dolores de cabeza al final del ciclo de desarrollo.

- **Mayor claridad en el historial del proyecto:** Cada PR en una pila representa un cambio lógico y coherente. Esto hace que el historial de Git sea más limpio y fácil de entender, ya que cada commit y cada PR tienen un propósito específico. Esto facilita la auditoría, la depuración y la comprensión de la evolución del proyecto a largo plazo.

- **Desbloqueo del desarrollo:** Cuando una tarea grande depende de varias subtareas, los Stacked PRs permiten avanzar en paralelo. Un desarrollador puede comenzar a trabajar en la siguiente subtarea basándose en un PR anterior que aún no ha sido mergeado. Esto evita el bloqueo y permite un flujo de trabajo más continuo.

- **Experimentación y refactorización más seguras:** Dividir una refactorización grande en PRs más pequeños y manejables permite validar cada paso y reduce el riesgo de romper la base de código. Si algo sale mal, es más fácil revertir un PR pequeño que un cambio masivo.

- **Mejora la moral del equipo:** Ver PRs más pequeños siendo revisados y mergeados rápidamente puede ser más gratificante para los desarrolladores que enfrentarse a la perspectiva de un PR gigante que permanece abierto durante mucho tiempo.

## Desafíos y Consideraciones al Implementar Stacked PRs

- **Mayor complejidad en la gestión de Git:** Requiere un buen entendimiento de Git y sus funcionalidades, especialmente el manejo de ramas, rebases y merges. Los desarrolladores deben ser competentes en mantener sus ramas locales sincronizadas y en resolver conflictos que puedan surgir al rebasar o mergear.

- **Comunicación y coordinación:** Es crucial una buena comunicación dentro del equipo para entender las dependencias entre los PRs y el orden en que deben ser revisados y mergeados. Si un PR base cambia significativamente, los PRs dependientes pueden necesitar ser actualizados, lo que requiere coordinación entre los desarrolladores involucrados.

- **Potencial para el "rebase hell":** Si la rama base cambia con frecuencia, los desarrolladores pueden encontrarse rebasando sus pilas de PRs repetidamente para mantenerlas actualizadas. Esto puede ser tedioso y propenso a errores si no se realiza con cuidado.

- **Curva de aprendizaje para el equipo:** La adopción de stacked PRs implica un cambio en el flujo de trabajo habitual. Los equipos pueden necesitar tiempo para adaptarse a esta nueva forma de trabajar y para comprender completamente los beneficios y las mejores prácticas.

- **Decidir el nivel de granularidad:** Encontrar el equilibrio adecuado al dividir los cambios en PRs es importante. PRs demasiado pequeños pueden ser triviales y aumentar la sobrecarga de gestión, mientras que PRs demasiado grandes aún pueden ser difíciles de revisar.

## ¿Cómo Implementar Stacked PRs?

### 1. Planificación y Descomposición de la Tarea

- **Divide la tarea grande:** Antes de empezar a codificar, analiza la funcionalidad o el cambio grande que necesitas implementar y divídelo en subtareas lógicas y coherentes. Cada subtarea debería ser lo suficientemente pequeña como para ser revisada fácilmente.

- **Define las dependencias:** Identifica qué subtareas dependen de otras. Esto te ayudará a determinar el orden en que se crearán los PRs. El primer PR en la pila contendrá los cambios base, y los siguientes se construirán sobre él.

### 2. Desarrollo con Ramas Locales

- **Crea una rama para la tarea principal:** Comienza creando una rama local para la funcionalidad general en la que estás trabajando (por ejemplo, `feature/nueva-autenticacion`).

- **Crea ramas para cada subtarea (PR):** Para cada subtarea identificada en el paso 1, crea una nueva rama local basándote en la rama del PR anterior (o en la rama principal para el primer PR). Por ejemplo:

  - `feature/nueva-autenticacion-modelo` (basada en master)
  - `feature/nueva-autenticacion-api` (basada en `feature/nueva-autenticacion-modelo`)
  - `feature/nueva-autenticacion-ui` (basada en `feature/nueva-autenticacion-api`)

- **Realiza los commits:** En cada rama de subtarea, realiza commits que representen unidades de cambio lógicas y enfocadas. Mantén los commits limpios y con mensajes descriptivos.

### 3. Creación de los Pull Requests

- **Crea el primer PR:** Desde la primera rama de subtarea (por ejemplo, `feature/nueva-autenticacion-modelo`), crea un Pull Request dirigido a la rama principal (por ejemplo, `master`).

- **Crea los PRs subsiguientes:** Para las ramas posteriores (por ejemplo, `feature/nueva-autenticacion-api` y `feature/nueva-autenticacion-ui`), crea los Pull Requests dirigidos a la rama del PR inmediatamente anterior. Por ejemplo:

  - El PR para `feature/nueva-autenticacion-api` tendrá como rama base `feature/nueva-autenticacion-modelo`.
  - El PR para `feature/nueva-autenticacion-ui` tendrá como rama base `feature/nueva-autenticacion-api`.

### 4. Gestión y Mantenimiento de la Pila de PRs

- **Actualización de ramas:** A medida que la rama base (por ejemplo, `master`) o un PR anterior en la pila se actualiza (ya sea por merges de otros PRs o por cambios), es importante rebasar tus ramas locales para mantenerlas actualizadas. Esto implica hacer un `git rebase <rama_base>` en cada una de tus ramas de subtarea, comenzando por la más antigua.

- **Resolución de conflictos:** Durante el rebase, pueden surgir conflictos que deberás resolver en cada rama afectada.

- **Actualización de los PRs:** Después de rebasar una rama local, deberás forzar el push de los cambios a la rama remota del PR (por ejemplo, `git push --force-with-lease`). ¡Ten cuidado con el uso de `force` y asegúrate de entender sus implicaciones! `force-with-lease` es una opción más segura.

- **Seguimiento de las dependencias:** Es importante tener claridad sobre qué PR depende de cuál. Las herramientas de soporte pueden facilitar la visualización y gestión de estas dependencias.

### 5. Integración de los PRs

Los PRs creados con la técnica de Stacked PRs pueden ser integrados en cualquier orden, respetando las dependencias. Lo recomendable es comenzar mergeando el PR base (el más antiguo) y avanzar a través de la pila. Si hacemos en un orden distinto, es importante entender y mantener la dependencia entre los PRs para que la integración se realice correctamente. Después de que el PR base es mergeado, los PRs que dependían de él ahora están "detrás" de la rama principal actualizada, eso facilita la integración de los PRs restantes. Este proceso se repite para cada PR en la pila, en el orden en que fueron creados (o en el orden lógico de las dependencias). Cada merge integra una parte adicional del cambio total en la rama principal.

#### Flujo Típico

Imagina una pila de PRs: `A` -> `B` -> `C` (donde `B` depende de `A`, y `C` depende de `B`).

1. Se revisa y aprueba el PR `A`.
2. Se mergea el PR `A` a la rama principal.
3. Se rebase la rama local de `B` sobre la rama principal actualizada. Se fuerza el push al PR `B`.
4. Se revisa y aprueba el PR `B` (que ahora incluye los cambios de `A`).
5. Se mergea el PR `B` a la rama principal.
6. Se rebase la rama local de `C` sobre la rama principal actualizada. Se fuerza el push al PR `C`.
7. Se revisa y aprueba el PR `C` (que ahora incluye los cambios de `A` y `B`).
8. Se mergea el PR `C` a la rama principal.

### Nos permite omitir la espera

Antes de Stacked PRs, deberíamos aguardar el merge de un PR antes de comenzar con el siguiente, lo que resulta en un flujo más lento y bloqueado.

![antes de stacked PRs]({{page.images_path}}/antes_de_stacked_prs.jpg)

Cuando utilizamos Stacked PRs, podemos omitir la espera de que un PR sea mergeado antes de comenzar con el siguiente. Cada PR puede ser revisado y mergeado en su momento, lo que reduce la espera y permite un flujo más fluido.

![después de stacked PRs]({{page.images_path}}/despues_de_stacked_prs.jpg)

## Cuando deberíamos ocupar Stacked PRs

Algunos casos donde su uso es altamente recomendable:

- **Desarrollo de funcionalidades complejas y grandes:** Cuando estás trabajando en una característica que requiere múltiples pasos lógicos o cambios en diferentes partes del código, dividirla en PRs apilados permite a los revisores entender y evaluar cada parte de forma incremental. Esto facilita la detección temprana de problemas y reduce la carga de revisión de un PR masivo.

- **Refactorización gradual:** Si necesitas refactorizar una parte grande del código, hacerlo en pequeños PRs apilados te permite avanzar paso a paso, asegurándote de que cada cambio individual no rompa la funcionalidad existente. Cada PR puede enfocarse en una tarea de refactorización específica, facilitando la revisión y minimizando el riesgo de introducir errores.

- **Exploración y prototipado iterativo:** Cuando estás explorando diferentes enfoques para una funcionalidad o construyendo un prototipo, los PRs apilados te permiten presentar cada iteración o cambio significativo para recibir retroalimentación temprana. Esto ayuda a validar ideas y a tomar decisiones informadas antes de invertir demasiado tiempo en una dirección equivocada.

- **Colaboración en paralelo en una misma funcionalidad:** Si varios desarrolladores están trabajando en diferentes aspectos de la misma funcionalidad, los PRs apilados permiten construir dependencias claras entre sus trabajos. Por ejemplo, un desarrollador puede crear la base de datos, otro la API y un tercero la interfaz de usuario, con cada PR dependiendo del anterior.

- **Mejora de la calidad del código paso a paso:** Puedes usar PRs apilados para introducir mejoras de calidad de código de forma incremental, como aplicar linters, formateadores o abordar code smells específicos. Cada PR puede enfocarse en un tipo de mejora, haciendo la revisión más manejable.

- **Documentación evolutiva:** Si la documentación de una nueva funcionalidad es extensa, puedes crear PRs apilados para cada sección o parte de la documentación. Esto permite a los revisores proporcionar retroalimentación a medida que la documentación se va construyendo.

- **Separación de concerns clara:** Cuando un cambio lógico se divide naturalmente en diferentes áreas de responsabilidad (por ejemplo, lógica de negocio, persistencia, presentación), los PRs apilados pueden reflejar esta separación, facilitando la revisión por expertos en cada área.

- **Aprendizaje y mentoría:** Para desarrolladores junior o aquellos que se están familiarizando con una nueva área del código, los PRs apilados permiten a los desarrolladores senior guiar el proceso de desarrollo paso a paso, revisando y proporcionando retroalimentación en cada etapa.

## Cuando no deberíamos usar Stacked PRs

Algunas situaciones en las que deberías considerar no aplicar PRs apilados:

- **Los cambios son pequeños y aislados:** Si tienes un cambio muy pequeño y que no depende de ningún otro, abrir un PR individual es más sencillo y rápido de revisar. Apilar un PR para un cambio mínimo añade complejidad innecesaria.

- **La urgencia del cambio es alta:** Por ejemplo, un hotfix. Si necesitas fusionar un cambio crítico rápidamente, tener varios PRs apilados que dependen unos de otros puede retrasar la implementación si surge algún problema en la cadena. En estos casos, simplificar el proceso con un PR directo puede ser más eficiente.

- **Los cambios introducen inestabilidad en la rama principal:** Si un PR intermedio en la pila introduce inestabilidad o funcionalidades incompletas en la rama principal (incluso temporalmente), esto puede ser problemático para otros desarrolladores que trabajan en paralelo.

## Conclusión

La técnica de Stacked PRs es una herramienta poderosa que puede desbloquear el flujo de desarrollo al permitir la descomposición de cambios grandes y complejos en partes más manejables. Al reducir la complejidad de los PRs, se facilita la revisión, la integración y la colaboración, lo que acelera el ciclo de desarrollo y reduce el riesgo de errores. Sin embargo, es importante entender los desafíos y considerar las implicaciones de la adopción de esta práctica, especialmente en equipos con requisitos específicos o herramientas de soporte limitadas.

Si bien presenta ciertos desafíos en la gestión de Git y la coordinación del equipo, los beneficios potenciales para la eficiencia y la calidad del desarrollo son significativos. Te animamos a explorar esta técnica, quizás comenzando con proyectos o funcionalidades más complejas. Experimentar con Stacked PRs puede ser el paso clave para desbloquear un flujo de trabajo más ágil y colaborativo en tu equipo.

