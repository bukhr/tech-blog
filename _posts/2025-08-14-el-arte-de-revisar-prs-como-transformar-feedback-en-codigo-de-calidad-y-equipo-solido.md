---
layout: post
title: 'El arte de revisar PRs: cómo transformar feedback en código de calidad y fortalecer la colaboración del equipo'
subtitle: Más que un paso técnico, la revisión de PRs es una oportunidad para aprender, crecer y construir juntos.
author: Rony Velásquez
tags: 
   - Revisión de Código
   - Pull Request
   - Mejores Prácticas de Desarrollo
date: 2025-08-08 14:38:27 -0500
background: "/assets/images/2025-08-08-el-arte-de-revisar-prs-como-transformar-feedback-en-codigo-de-calidad-y-equipo-solido/background.png"
---

En Buk, siempre nos motiva crear un producto de excelencia para nuestros clientes. Detrás de cada funcionalidad que entregamos hay muchas horas de trabajo colaborativo, debates técnicos y, sobre todo, revisiones de código que nos ayudan a mantener un estándar alto. Los Pull Requests (PRs) no son solo una herramienta para integrar cambios: son un espacio de conversación técnica, aprendizaje compartido y mejora continua. Pero aquí surge la pregunta:

***¿Cómo logramos que una revisión de PR no sea una simple formalidad, sino un proceso que realmente aporte valor y fortalezca al equipo?***

En este post quiero compartir contigo algunas de las prácticas que seguimos en Buk para que cada revisión sea efectiva, colaborativa y formadora. Son pinceladas que hemos ido aprendiendo con la experiencia, a veces a base de prueba y error, y que hoy forman parte de nuestro ADN como equipo.

## La importancia de revisar PRs

Revisar un PR es mucho más que validar que el código “funcione”. Es un punto de control de calidad, pero también un espacio para transmitir conocimiento y alinear criterios técnicos.

En Buk creemos que un buen código no solo resuelve un problema puntual, sino que también sienta las bases para que el sistema sea escalable, mantenible y entendible por cualquier miembro del equipo, incluso meses después. Por eso, revisar PRs no es un trámite: es una inversión en el futuro del proyecto y de las personas que lo construyen.

### 1. Comprender el propósito del Pull Request

Antes de lanzarte a leer el código línea por línea, tómate un momento para entender qué busca el PR. Ese pequeño paso inicial puede ahorrarte mucho tiempo y evitar malentendidos innecesarios. Empieza revisando la descripción: identifica si se trata de una nueva funcionalidad, la corrección de un bug o un refactor. Luego, piensa en el contexto, en cómo estos cambios podrían impactar al resto del sistema.

Finalmente, evalúa el tamaño, un PR enorme no solo es más difícil de revisar, sino también más propenso a errores. En estos casos, puede ser una buena idea dividirlo en partes más pequeñas y manejables. Una técnica muy útil para esto es el uso de Stacked PRs, que permite encadenar cambios de forma ordenada y revisarlos en etapas. Si quieres profundizar en este enfoque, te recomiendo leer nuestro post [Desbloquea tu flujo de desarrollo con Stacked PRs](https://buk.engineering/2025/04/19/desbloquea-tu-flujo-de-desarrollo-con-stacked-prs.html)

### 2. Revisar el código

La revisión del código es, sin duda, el corazón del proceso. En esta etapa, el objetivo es evaluar tanto la visión general como los detalles más finos del cambio propuesto.

En la revisión general, el primer paso es echar un vistazo a los archivos que han sido modificados. Esto te dará una idea rápida del alcance del PR. Luego, reflexiona sobre el impacto que estos cambios pueden tener en la arquitectura general del sistema: ¿alteran algún flujo crítico?, ¿introducen dependencias nuevas?, ¿afectan módulos ya consolidados? Esta perspectiva amplia permite anticipar posibles problemas antes de sumergirse en los detalles.

En la revisión detallada, el enfoque cambia hacia la calidad intrínseca del código. Aquí es donde analizas si es claro y fácil de entender, si sigue las guías de estilo acordadas por el equipo y si es lo suficientemente modular como para ser reutilizado en otros contextos. También es el momento de buscar errores lógicos, redundancias o casos no contemplados que puedan generar fallos en el futuro. Por ejemplo, en este fragmento:

```ruby
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

un comentario constructivo podría ser:
*"Buen trabajo agregando validaciones. Quizá podrías manejar también la unicidad del email para evitar registros duplicados."*

### 3. Probar el código localmente

Nunca subestimes el valor de probar un PR en tu propio entorno. Este paso es crucial para confirmar que el cambio realmente hace lo que promete y que no introduce errores inesperados en otras partes del sistema. Comienza validando la funcionalidad principal: ¿cumple exactamente con lo que se planteó en la descripción del PR?

Antes de empezar, revisa que el Pull Request(PR) incluya instrucciones claras sobre cómo probar los cambios. Esto puede ser tan simple como una lista de pasos o comandos a ejecutar. Si esta información no está presente, solicita al desarrollador responsable que la agregue, esto no solo agiliza la revisión, sino que evita suposiciones y posibles errores durante las pruebas.

Luego, verifica que las pruebas de integración cumplan su propósito asegurando que no se rompa ningún flujo ya existente. Por último, no olvides explorar casos límite, esos escenarios extremos que a menudo revelan fallos ocultos.

Por ejemplo, si el PR introduce un nuevo endpoint como:

```ruby
get '/users/:id', to: 'users#show'
```

sería recomendable verificar que, para IDs válidos, la respuesta sea la correcta y que, en cambio, para IDs inexistentes, el sistema devuelva un 404. Estos chequeos sencillos pueden marcar la diferencia entre un despliegue estable y una producción llena de sorpresas.

### 4. Proporcionar retroalimentación constructiva

Los comentarios en un PR son como pinceladas que, poco a poco, dan forma a la obra final. Cada uno aporta algo: una mejora técnica, una idea más eficiente o simplemente un reconocimiento al buen trabajo. Por eso, es importante que, antes de afirmar, preguntes, una simple frase como _"¿Consideraste usar pluck para mejorar la eficiencia?"_ abre el diálogo y fomenta la colaboración. No olvides reconocer lo positivo, por ejemplo: _"Buena elección al usar scopes para mantener consultas organizadas."_

Cuando detectes algo que puede mejorarse, sugiérelo con claridad y de forma concreta: _"Podrías mover esta lógica a un servicio para mantener el controlador limpio."_ Y, sobre todo, cuida el tono; en lugar de decir _"Esto está mal"_, opta por un enfoque constructivo como _"Creo que esta implementación podría optimizarse usando ActiveRecord"_. El objetivo no es solo mejorar el código, sino construir un equipo más unido, con una comunicación sólida, confianza mutua y un flujo constante de aprendizaje compartido.

### 5. Considerar el impacto en el proyecto

No te quedes únicamente en el aspecto técnico del cambio; una buena revisión también implica pensar en el futuro del proyecto. Pregúntate si el código introduce problemas de rendimiento, si será capaz de escalar cuando aumente el número de usuarios o datos, y si será lo suficientemente mantenible como para que otro desarrollador pueda entenderlo y modificarlo sin dificultad.

Un ejemplo claro está en el manejo de consultas a la base de datos. Imagina que encuentras algo como:

```ruby
users = User.all
users.each do |user|
  puts user.posts.count
end
```

Este enfoque “funciona” en el sentido de que cumple su objetivo, pero lo hace de manera ineficiente: cada vez que se accede a `user.posts.count`, se genera una consulta separada a la base de datos, provocando el problema conocido como **N+1 queries**. Esto puede pasar desapercibido en un entorno de desarrollo o con pocos datos, pero en producción y con grandes volúmenes de información, su impacto en el rendimiento puede ser muy significativo.

Con un pequeño ajuste, podemos optimizarlo así:

```ruby
users = User.includes(:posts)
users.each do |user|
  puts user.posts.size
end
```

En este segundo enfoque, cargamos en memoria las publicaciones de cada usuario en una sola consulta anticipada (*eager loading*), evitando múltiples idas a la base de datos. Esto no solo mejora el rendimiento, sino que también prepara mejor el sistema para escalar a futuro.

La diferencia entre ambos enfoques es clara: el primero prioriza la solución inmediata sin considerar el costo a largo plazo, mientras que el segundo busca un equilibrio entre funcionalidad y eficiencia, pensando en la salud y sostenibilidad del proyecto.

### 6. Herramientas de soporte

Contar con herramientas de soporte puede marcar una gran diferencia en la calidad y velocidad de las revisiones. Los linters, como [RuboCop](https://rubocop.org/), ayudan a mantener la consistencia del código y a detectar errores comunes antes de que lleguen a revisión. Las *pruebas automatizadas* ofrecen una capa extra de seguridad, asegurando que nuevas funcionalidades no rompan lo ya existente. Por su parte, el análisis estático es ideal para identificar vulnerabilidades y problemas de rendimiento sin necesidad de ejecutar el código.

Y aunque la revisión debe ser exhaustiva, es importante encontrar un equilibrio entre profundidad y tiempo. No todo tiene que resolverse en un solo PR; prioriza lo crítico y deja los detalles menores para futuros ajustes. Este enfoque mantiene el flujo de trabajo del equipo ágil, sin sacrificar la calidad del producto final.

### Conclusión

Revisar PRs es una de esas tareas que pueden pasar desapercibidas… hasta que empiezas a hacerlo bien y te das cuenta de su verdadero impacto. No es solo encontrar errores: es guiar, enseñar y aprender.

En Buk hemos aprendido que cada comentario bien planteado, cada sugerencia clara y cada prueba extra que hacemos, deja el código un poco mejor de lo que estaba, y eso se acumula con el tiempo. Es como pintar un cuadro colectivo: cada quien aporta su trazo, pero el resultado final es una obra que representa el esfuerzo y la visión de todo el equipo.

Si quieres llevar tus revisiones de PR al siguiente nivel, no pienses en ellas como un filtro para “aprobar” cambios, sino como una oportunidad para dejar huella en el código y en las personas con las que trabajas. Y recuerda: el mejor PR no es el que se aprueba más rápido, sino el que deja el sistema más sano y al equipo más fuerte.

_Si te apasiona el desarrollo de software, disfrutas trabajar en un entorno donde la colaboración y la calidad del código son prioridad, y te motiva la idea de contribuir desde cualquier lugar —ya sea en formato remoto o híbrido—, en Buk siempre buscamos personas con ganas de aprender, aportar y crecer junto al equipo._

[**Postula aquí y construyamos juntos el futuro.**](https://buk.buk.cl/trabaja-con-nosotros)