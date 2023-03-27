---
layout: post
title: Mob programming remoto en Buk
subtitle: Un pair programming pero ¡con esteroides!
author: Cristofer Robles | Meraioth Ulloa
tags: mob programming
date: 2022-06-13 11:33 -0300
images_path: "/assets/images/2022-06-13-mob-programming-en-buk"
background: "/assets/images/2022-06-13-mob-programming-en-buk/portada.jpg"
---
En el proceso de crecimiento de Buk donde se ha experimentado recientemente el aumento de contrataciones sobretodo en áreas de desarrollo, hemos podido recibir al mejor talento ([estamos buscando siempre](https://info.buk.cl/reclutamiento-buk-devs?hsLang=es-cl) 😜) y a pesar de que nuestro proceso de _onboarding_ se ha adaptado a este ritmo, hemos detectado oportunidades de mejora.

El caso para el presente artículo es el siguiente:

> Cuando más de un integrante nuevo necesita ayuda con un problema similar, lo usual es hacer reuniones 1 a 1 para ayudarlos. ¿Pero qué sucede cuando esto se hace más frecuente?

Cuando encontramos un problema también vemos una oportunidad para mejorar. La siguiente pregunta fue: ¿Qué pasaría si hiciéramos una sesión colaborativa donde abordamos temas que puedan enseñarle a todo el equipo en una sola sesión y trabajando sobre un caso práctico (código que luego será mezclado a la rama principal)? Como en muchas otras situaciones, no fue necesario reinventar la rueda. Alguien ya se había enfrentado a una necesidad similar y fue así como encontramos **Mob Programming**.

Comenzamos a leer y descubrimos que formaba parte de la metodología de **Extreme Programming** propuesto por [Agile Alliance](https://www.agilealliance.org/resources/experience-reports/mob-programming-agile2014/) el año 2014. En un primer acercamiento al **Mob Programming** hemos podido comprobar en carne propia las siguientes bondades:

- Esparcir más rápido el conocimiento en el equipo.
- Generar cohesión en el equipo.
- Generar empatía en cada integrante.
- Recuperar el trabajo colaborativo en modo [WFA](https://www.buk.cl/blog/nueva-pol%C3%ADtica-buk-wfa-work-from-anywhere).
- Reforzamos el no tener vergüenza de equivocarse y programar en frente de otros (que es algo común en Buk).

Ahora vamos a profundizar un poco más en detalle acerca de la metodología.

## ¿Qué es el Mob Programming?

Básicamente una forma de programación donde un grupo de desarrolladores **trabajan sobre la misma tarea** o funcionalidad **al mismo tiempo**. Es muy similar a un _Pair Programming_ pero con más participantes.

![Qué es el Mob Programming]({{page.images_path}}/mob-programming-meme-1.png)

## ¿Y cómo funciona?

Lo primero es definir dos roles: **driver** _(conductor)_ y **navigator** _(navegante)_, los cuales irán rotando en el transcurso de la sesión. La principal tarea del _conductor_ es tomar el teclado y “conducir” el avance del código, pero siempre siguiendo las indicaciones del _navegante_; el _conductor_ no puede tomar decisiones de forma unilateral. Por su parte, el _navegante_ tiene la responsabilidad de dar indicaciones explícitas al _conductor_ como indicar qué y dónde debe escribir mientras escucha las opiniones del resto del equipo, y cuando hayan dudas de cómo continuar con el código, debe generar discusión para lograr un consenso y continuar avanzando.

## ¿Cómo lo implementamos en Buk?

**Previo a la actividad:**

- Se define la tarea sobre la cual se va a trabajar, idealmente un _feature/tarjeta_ de tu sprint en curso.
- Se agenda una reunión con tiempo suficiente para el desarrollo de la actividad:
  - ⏱ 5 o 10 mins. de contextualización y objetivo.
  - ⏱ 10 o 15 mins. por cada participante.
  - 🎙 Margen extra para discusión.

> Por ejemplo: 4 participantes, 10 mins. de contexto, 15 mins. de código para cada uno, 70 mins. en total y se puede considerar un margen extra de 15 mins. para las discusiones.

**Durante la actividad:**

- Se presenta la _tarea/feature_ sobre la cual se va a trabajar: se entrega el contexto, los casos de uso (si aplica) y cuál es el objetivo que queremos alcanzar. Esto es muy importante y deben quedar muy claros los alcances.
- Inicia un participante siendo _conductor_ y otro como _navegante_.
- Con el contexto y objetivos ya conocidos, el _navegante_ debe empezar a dar las indicaciones al conductor sobre lo que debe ir agregando o editando en el código. Recordemos que solo el _conductor_ puede editar los archivos y siempre siguiendo las indicaciones del _navegante_.
- Los demás participantes aportan sugerencias al navegante y apoyan validando o levantando dudas que puedan aparecer mientras se avanza en el desarrollo del _feature_.
- Frente a dudas de cómo continuar la implementación es ideal que se pueda generar la discusión a nivel de equipo. Se deja de escribir código hasta que haya consenso y luego el _navegante_ indicará al _conductor_ cuándo retomar.
- El _conductor_ puede participar de las discusiones, pero no puede escribir código por iniciativa propia, solo lo que el navegante le indique.
- Después de 10 o 15 mins. el _navegante_ pasa al rol de _conductor_ y otro participante pasa a ser _navegante_.
- Se repite el paso anterior hasta que todos participen en ambos roles.
- Los nuevos miembros del equipo participan de oyentes durante un tiempo, hasta que se sientan seguros para poder participar. Este punto es importante para evitar agregar dudas o confusión innecesaria a los nuevos miembros del equipo.

![Mob Programming illustration]({{page.images_path}}/mob-programming-illustration.png)

## ¿Qué necesitamos para nuestro Mob Programming?

- **Timer**: Cualquier reloj con timer servirá, pero un participante se debe encargar de controlar el tiempo e indicar cuando corresponda cambiar los roles y pausar cuando haya discusiones muy largas. Nuestro equipo en Buk usa [Standup Timer App](https://standuptimer.app/)
- **Editor de código en tiempo real**: Cualquier editor que permite editar código de forma colaborativa en tiempo real servirá, en nuestro caso **VS Code** con [Live Share](https://code.visualstudio.com/learn/collaboration/live-share) o **RubyMine** con su funcionalidad de _Code With Me_ han funcionado muy bien. Es importante que la herramienta tenga la funcionalidad para que los participantes puedan _seguir_ el cursor del _conductor_ y así estén todos en el mismo segmento de código todo el tiempo.
- **Comunicación en tiempo real**: es fundamental para poder llevar adelante las discusiones del equipo y las instrucciones que da el navegante al conductor. En nuestro caso [Gather](https://www.gather.town/) y **Google Meet** son nuestros aliados.

## ¿Y cómo ha sido nuestra experiencia de equipo?

Tomamos esta metodología para trabajar durante todos los _sprints_ (una vez en cada _sprint_), donde abordamos una tarjeta de nuestro tablero de **Jira**. Decidimos hacerlo de esta forma para generar un hábito, lo que no quita la posibilidad de que exista _Pair Programming_ entre desarrolladores.

### Puntos que 👍🏻

- El trabajar tarjetas con casos de usos complejos ha ayudado a aumentar el conocimiento del equipo de forma transversal.
- Ha disminuido el tiempo de _onboarding_, ya que esta metodología le enseña de forma práctica a los nuevos miembros cómo trabaja el equipo.
- Los miembros con menos experiencia han perdido el miedo a programar frente al resto de sus compañeros.

### Puntos que 👎🏻

- Dado que trabajamos sobre una tarjeta del _sprint_ en curso, si en la sesión no participa al menos un miembro _senior_ del equipo que sirva de soporte en el contexto de la tarjeta y/o funcionamiento de la aplicación se puede perder tiempo al iniciar con las primeras líneas de código.
- Es una sesión con un alto costo en tiempo (usualmente de 1 a  1:30 hrs. de cada integrante del equipo), pero creemos que es en el fondo es una muy buena inversión del tiempo de cada uno.

## Conclusiones

Los beneficios e impacto de **Mob Programming** cobran especial relevancia para el equipo cuando contamos con un equipo diverso en _seniority_, tanto desde el punto de vista técnico como desde el conocimiento del negocio.

Atreverse a nuevas cosas siempre es un desafío y trae cierto esfuerzo adicional al inicio, pero desde nuestra experiencia vale la pena el esfuerzo cuando generamos instancias donde el equipo está trabajando, compartiendo y aprendiendo unos de otros y fortaleciendo la comunicación y relación del equipo.

![Conclusiones]({{page.images_path}}/mob-programming-meme-2.png)
