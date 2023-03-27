---
layout: post
title: Agilidad + onboarding = hold my beer!
subtitle: En octubre del 2021 entré a Buk como desarrollador de software. Aquí te cuento cómo durante las primeras semanas ¡ya aportaba al código de la plataforma!
author: Maximiliano Garcia Roe
tags: [buk, metodología]
date: 2022-04-01 09:30 -0300
images_path: "/assets/images/2022-04-01-agilidad-onboarding-hold my-beer"
background: "/assets/images/2022-04-01-agilidad-onboarding-hold my-beer/cerveza.jpeg"
---
## ¿Por qué es importante todo esto?
En octubre del 2021 entré a Buk como desarrollador de software. Jamás había trabajado en una gran empresa, por lo que al ingresar lo primero que hice fue cuestionarme ¿cómo ingresar código a una misma plataforma junto a otros 50 desarrolladores sin arruinar nada? ¿Cómo es que todos saben qué y cómo hacer las cosas sin titubear?

![primer día de trabajo]({{page.images_path}}/first-day-at-work.png)

Pero la incertidumbre desaparece la primera semana durante el onboarding, que es básicamente el proceso que usan las empresas para que los nuevos colaboradores se adapten lo mas rápido posible a su nuevo rol. Al comenzar a trabajar me mostraron su metodología de desarrollo, que permite que cada programador pueda aportar al código sin miedo a arruinar nada.

De manera guiada, semana a semana es notoria la evolución de la participación dentro del área, siendo posible realizar cambios incrementales, permitiendo que dentro del primer mes ya se pueda aportar en diferentes **features** [^1] que entregan valor a nuestros clientes.

## Pero... ¿qué es una metodología de desarrollo de software?
Una metodología de desarrollo de software es una forma de mejorar, trabajar o arreglar un software ya existiente. No son cambios al azar dónde quien ingrese más cambios al código gana. Muy por el contrario, **cada cambio tiene una razón de ser, una lógica y un proceso correspondiente**.

Como sabemos, los clientes constantemente tienen nuevos requerimientos o reportes de problemas con el software. Para poder atender esas solicitudes, es recomendable poseer una metodología particular al momento de responder a cada imprevisto que pueda presentarse. El motivo detrás de esto es encontrar la raíz del incidente, y de esta forma solucionarlo. Al inventar soluciones no definitivas (también conocidas como parches 😂), estas pueden generar un cúmulo de problemas, los que a la larga pueden ser más perjudiciales que el inconveniente que se presentó en primera instancia. La clave es priorizar en todo momento las necesidades del cliente.

Son estas y muchas otras razones las que fundamentan la creación de metodologías de desarrollo de Software. En la literatura se ha probado y demostrado que hay diversas formas de llevarlo a cabo, describir todas y cada una de estas resultaría el equivalente a escribir un libro, por lo que explicaré a continuación a grandes rasgos el funcionamiento de Buk, y la forma en que este fue un apoyo clave al momento de mi **onboarding**, agilizando de manera notable todo el proceso. 

## Metodología en Buk
A grandes rasgos, BUK utiliza una metodología ágil [Scrum](https://es.wikipedia.org/wiki/Scrum_(desarrollo_de_software)). El trabajo se estructura a través de épicas divididas en distintas tarjetas, las cuales son realizadas dependiendo de su prioridad. Además, es necesario considerar otros requerimientos urgentes que puedan estar emergiendo en la aplicación.

A continuación, se realizará un desglose y una explicación un poco más detallada de lo descrito anteriormente.

### Épicas
Por lo general, una épica representa un feature de gran tamaño, que debe ser dividida en varias partes más chicas para poder ser desarrollada. Estas nacen según las diversas necesidades de los clientes, o bien de las expectativas de las empresas, pero siempre en base a una investigación previa, contando con el correcto análisis sobre cómo abordar dichas expectativas o necesidades.

### Tarjetas
Las épicas se dividen en tarjetas, o bien, ["historias de usuarios"](https://www.atlassian.com/es/agile/project-management/user-stories#:~:text=usuario%20del%20software.-,Una%20historia%20de%20usuario%20es%20una%20explicaci%C3%B3n%20general%20e%20informal,un%20valor%20particular%20al%20cliente.). Estas ayudan, en primer lugar, a separar un gran feature en tareas más pequeñas. Cada tarea debe ser **específica**, siempre considerando el enfoque esperado por el cliente, contando con una prioridad determinada y una estimación de horas/puntos/otros. Además, cada tarjeta debe cumplir con todo un flujo que implica revisión de código, pruebas, QA, entre otros, garantizando así que se cumplan todos los requerimiento de la tarjeta antes de que se integre finalmente con el producto.

![epica-tarjetas]({{page.images_path}}/epica-tarjeta.png)

### Proceso
Entonces, comprendiendo los conceptos anteriores y la forma en que las épicas se dividen en un gran número de tarjetas, es necesario generar una división estratégica del trabajo. Es por esto que el desarrollo se divide en **Sprints**, períodos de tiempo (dos semanas en nuestro caso) cuyo enfoque es abarcar la mayor cantidad de tarjetas según las horas o puntos disponibles. El propósito del equipo es finalizar todas sus tarjetas, logrando el tan esperado fin del sprint sin tarjetas.

![tablero-sprint]({{page.images_path}}/sprint.png)

La gran ventaja de esta metodología de trabajo es la forma en que produce un dinamismo en el desarrollo, además de objetivos alcanzables a corto plazo, los cuales paulatinamente se acercan al objetivo final: completar la épica. Al mismo tiempo, se genera una mayor motivación a los desarrolladores, ayudándolos a poseer una idea clara sobre su objetivo y las restricciones que se presentan en su área de desarrollo.

Sumado a lo anterior, los desarrolladores cuentan con una metodología para el control de versiones, llamada [GitFlow](https://www.atlassian.com/es/git/tutorials/comparing-workflows/gitflow-workflow#:~:text=Gitflow%20es%20un%20modelo%20alternativo,vez%20y%20quien%20lo%20populariz%C3%B3.), que junto a una buena [estrategia para mantener las historias ordenadas](https://buk.engineering/2021/03/30/manteniendo-la-historia-ordenada.html) aportan para un mejor proceso de desarrollo de la aplicación.

A simple vista, el ejecutar todas estas acciones puede parecer un proceso engorroso, pero en realidad generan un gran aporte para mantener el orden y facilitar la comprensión del desarrollo. Ninguna acción es al azar, siempre poseen el objetivo de aportar de forma positiva a la aplicación, previniendo posibles futuros errores. **Si todo el equipo trabaja con esta filosofía, la utilización de estos procesos para el desarrollo prácticamente se automatiza**.

![tablero-sprint]({{page.images_path}}/tablero-sprint.png)

## Resumiendo

Cada tarjeta posee una prioridad y horas de estimación y existen muchas tarjetas, las cuales se van renovando cada cierto tiempo. Entre todas las tarjetas existentes, hay algunas que poseen una baja prioridad, ya que se considera que su aporte no es tan determinante para nuestros clientes, o bien no les afecta de manera directa, pero independiente del grado de importancia de la tarjeta asignada, es fundamental terminarla, lo que implica una interacción directa con la aplicación.

## Por qué esto me ayudó a tener un buen onboarding

Al momento de contratar nuevos desarrolladores se busca que su interacción sea lo más pronta posible. Gracias a lo explicado anteriormente, se logra que en corto tiempo los nuevos integrantes se familiarización con la aplicación, tengan una mejor comprensión de la metodología de trabajo, disminuyan el miedo inicial que produce trabajar en una aplicación desconocida al momento de ingresar, sientan que son un aporte dentro de la aplicación, entre otros.

En fin, ese es un resumen tanto de mi experiencia como de muchos otros compañeros al momento de comenzar a trabajar en BUK, quienes ya a la primera semana estaban aportando con cambios y desarrollos a la aplicación, siguiendo una metodología de desarrollo ágil y ordenada que ha hecho de estos seis meses que tengo en BUK una experiencia extraordinaria.

![nice]({{page.images_path}}/thumbs-up-kid.gif)

Si quieres tener una experiencia como esta y trabajar con nosotros con una buena metodología de software postula en el siguiente [link](https://info.buk.cl/reclutamiento-buk-devs?utm_source=blog-eng&utm_medium=link&utm_campaign=outreach).


---

[^1]: [feature] Unidad funcional de un sistema de software que satisface un requisito, representa una decisión de diseño, y puede generar una opción de implementación.
