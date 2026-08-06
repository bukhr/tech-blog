---
layout: post
title: Pair programming flujo completo
subtitle: Cómo aplicar el pair programming no solo en el código
author: Maximiliano Garcia
date: 2024-06-13 10:22 -0400
tags:
- Agile
images_path: "/assets/images/2024-06-20-pair-progaming-flujo-completo"
background: "/assets/images/2024-06-20-pair-progaming-flujo-completo/chocar-puños.jpg"
---
En Buk siempre promovemos nuevas formas de trabajo y aprendizaje en equipo. Siempre utilizamos las propuestas de la literatura, como el pair programming o el mob programming, que mencionamos en el artículo [Mob programming en Buk](https://buk.engineering/2022/06/13/mob-programming-en-buk.html). Sin embargo, como se menciona en ese artículo, no solo se trata de aplicar estas prácticas en nuestro trabajo diario, sino de ir un poco más allá y adaptarlas a las realidades de nuestro entorno laboral. Por eso, en este artículo veremos cómo aplicamos el pair programming en un flujo completo de una tarjeta en Buk.

## ¿Qué es el Pair Programming?

Primero, es importante explicar qué es el Pair Programming. Es una metodología de programación en la que dos programadores trabajan juntos en una misma tarjeta y en un mismo ordenador (o con videollamada usando la extensión de VScode [Live Share](https://code.visualstudio.com/learn/collaboration/live-share)). Uno de los programadores es el piloto, quien escribe el código, y el otro es el copiloto, quien revisa el código y piensa en la solución del problema. Ambos programadores intercambian roles constantemente.

![Pair programming]({{page.images_path}}/pair-programming.jpg)

Esta metodología tiene muchas ventajas, tales como:

- Mejora la calidad del código, ya que se revisa constantemente.
- Aumenta la productividad, ya que dos personas trabajando en el problema lo resuelven más rápido y la corrección de PR también.
- Fomenta la comunicación y la colaboración, ya que se está constantemente hablando de la solución del problema.
- Aumenta el aprendizaje y la transferencia de conocimiento, ya que se está constantemente aprendiendo del otro programador.

A pesar de esto, siempre se debe adaptar a las realidades de cada equipo y de cada empresa. Esto es porque somos personas que trabajan con estas prácticas y no robots, por lo que se recomienda adaptar esta metodología, o simplemente no usarla si no se acomoda a tu empresa. Sin embargo, es muy importante al menos intentarlo.

## ¿Cómo lo implementamos en Buk?

Como explicamos en un post anterior [Agilidad + Onboarding = Hold My Beer!](/2022/04/01/agilidad-onboarding-hold-my-beer.html), en Buk trabajamos con épicas, ahora llamadas misiones (suena más cool 😎). Estas misiones son un conjunto de tarjetas que tienen un objetivo en común, sacar una nuevo feature. Por ejemplo, una misión puede ser "Mejorar la velocidad de carga de la página de inicio", y esta misión tiene tarjetas como "Optimizar las imágenes de la página de inicio", "Optimizar el código de la página de inicio", etc.

Además, para cada misión le asignamos un champion 🦸‍♂️, que es un desarrollador del equipo que se encarga de que la misión se cumpla. Su principal rol es diseñar la solución técnica de la misión, crear las tarjetas, agregar los criterios de aceptación de cada tarjeta, las pruebas, etc. Básicamente es el gestor de la misión, pero del lado técnico.

### El problema

Como dijimos, uno de los roles del champion es encargarse de la gestión a nivel técnico de toda la misión. Esto implica muchas responsabilidades y dificultades, porque no es fácil encargarse de la gestión de la misión por completo, además de pensar en cada tarjeta, cada criterio de aceptación, sus casos de prueba, etc. Esto resultaba muy agotador para el champion, generando incluso a veces la sensación de _burnout_ en él.

Esta forma en un principio nos funcionaba "bien", pero el champion perdía mucho tiempo en esto ademas no le daba tiempo para desarrollar alguna tarjeta de la mision que esta liderando. También, era solo una persona a cargo de resolver el problema en su totalidad (aunque había ayuda, en general, era solo uno), lo que aumentaba la probabilidad de cometer algún error.

Pero nuestro principal problema surgía cuando un desarrollador o un equipo en pair tomaba la tarjeta. El champion, al estar a cargo de toda la gestión de la misión, tenía muy claro cómo quería la solución de cada tarjeta, pero el equipo que tomaba la tarjeta **no**. Tenían que leer la tarjeta, analizarla y tomar toda la carga cognitiva que hizo el champion en pensar la tarjeta para recién empezar a realizarla, para después de terminarla que el champion vuelva a validarla. Esto provocaba que se perdiera mucho tiempo en entender la tarjeta, aumentando el tiempo de desarrollo y, por consecuencia, el tiempo de entrega de la misión.

### La solución

Al ver este problema, decidimos buscar una solución y en una de tantas iteraciones y lluvias de ideas, dijimos como equipo: _"hey.. y ¿si aplicamos esto de pair programming mucho antes?"_. Por esto llegamos a la propuesta de que el pair se realice desde que se defina la tarjeta hasta que se suba a producción.

### Pero, ¿qué implica esto?

El champion sigue pensando la solución de manera más macro y define las tarjetas de manera muy general, solo los títulos. Luego presenta la solución al equipo con esta idea macro y cómo debería ser el resultado final.

Luego, en el desarrollo de la misión, el champion decide qué tarjetas se trabajan en cada sprint, en base a la capacidad del equipo. Se designa una pareja de desarrolladores para que trabajen en alguna tarjeta en pair. Esta pareja tiene que definir la historia de usuario, los criterios de aceptación, cómo se debería probar y validarla con producto, diseño y el champion. Luego de validarla con el champion, esta misma pareja comienza el desarrollo inmediato de la tarjeta.

Esta forma de hacer pair programming trae muchos beneficios:

- Se reduce el tiempo de entendimiento de la tarjeta, incluso de la misión completa, ya que la pareja que la va a desarrollar era la que la había creado.
- Mayor entendimiento del equipo de la misión, además de hacerlos mucho más parte de la solución del problema.
- Se reduce el tiempo de desarrollo de la tarjeta, ya que al hacer la tarjeta por ellos mismos, ya vienen con una idea clarar de como desarrollarla .
- Se reduce el tiempo de revisión de la tarjeta, ya que al tener más contexto del problema, es más probable que tenga menos errores.
- El champion tenía más tiempo también para desarrollar en la misión, además de que tenía más tiempo para pensar en cómo resolver el problema de manera más macro, incluso teniendo tiempo de hacer algún pair con un compañero.
- Involucras a mas personas en la solución de una misión, porque antes el champion pensaba la solución solo, y con esta metodología hay más personas pensando en la solución.

## Bueno... ¿y esto funciona?

Como dije en un principio, todas estas prácticas siempre se tienen que adaptar para cada realidad de trabajo o equipo. Pero para ver que funciona hay que medirlas y nosotros las medimos y funcionó. A continuación, les muestro un gráfico de [Cycle Time](https://en.wikipedia.org/wiki/Cycle_time_(software)) de una disitintas tarjetas que se desarrollaron en pair programing con esta metodologia.

![CycleTime de los primeros 3 meses de implementación]({{page.images_path}}/cycle-time-primero-3-meses.png)

Si se fijan, en los primeros 3 meses de implementación el promedio fue de 6 días de ciclo de vida de la tarjeta (desde que se crea hasta que está en staging), lo cual era lo "común" en nuestro equipo cuando se hacia un pair programing. Pero en el gráfico se ve la tendencia a la baja, lo que significa que el equipo está mejorando en la forma de trabajar y en la eficiencia de la misma con los primeros meses de esta nueva forma de hacer pair programming.

![CycleTime de los siguientes 3 meses de implementación]({{page.images_path}}/cycle-time-siguientes-3-meses.png)

Luego, en los siguientes 3 meses, aquí ya es otra historia: el promedio de ciclo de vida de la tarjeta bajó a 4 días, lo que significa que el equipo está mejorando en la forma de trabajar y en la eficiencia de la misma. Esto demuestra que la nueva forma de hacer pair programming funciona y estamos mejorando en la eficiencia del trabajo.

![Celebración]({{page.images_path}}/celebrate.gif)

## Conclusión

El pair programming es una gran práctica que se puede adaptar a cualquier realidad de trabajo. En este caso, lo adaptamos a un flujo completo de trabajo y nos dio muy buenos resultados. Siempre es importante probar nuevas formas de trabajo y adaptarlas a nuestras realidades, porque si uno no las prueba, nunca sabrá si le van a funcionar o no. Por otro lado uno siempre pueden mejorar los tiempos de entrega y la calidad del trabajo, pero para lograrlo hay que hacer cambios a la forma de trabajar. Es importante destacar que esta es una de las tantas formas que usamos en Buk para hacer un trabajo más ágil, eficiente y de excelencia, los resultados que mostramos no solo son por esta practica tambine son por muchas otras prácticas que tenemos en Buk, pero eso es tema para otro artículo 😏.
