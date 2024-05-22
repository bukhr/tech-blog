---
layout: post
title: 'Mi contribución a Active Admin: el detrás de escena'
subtitle: '"Un pequeño aporte a la comunidad Open Source, un gran paso como persona y como software engineer"'
author: Vicente Correa
tags:
- Active Admin
- Open Source
- gem
- ruby
- rails
- Ruby on Rails
date: 2024-05-29 10:22 -0400
images_path: "/assets/images/2024-05-29-mi-contribución-a-active-admin-el-detrás-de-escena"
background: "/assets/images/2024-05-29-mi-contribución-a-active-admin-el-detrás-de-escena/fondo_open_source.jpg"
---
Sí, hay código mío en Active Admin, una conocida gema que provee una interfaz para administrar recursos de una aplicación Ruby on Rails. Pero antes de explicar cómo mi código llegó ahí, necesito explicar algunos conceptos.

### Introducción: SAC, superhéroes y Active Admin

En Buk existe un área llamada SAC (servicio al cliente), quienes son los primeros en proveer soporte técnico a los clientes cuando éstos tienen dudas o problemas con la aplicación. Para ello, SAC tiene acceso a la interfaz de [Active Admin](https://activeadmin.info/) de cada cliente.

Por otro lado, como vimos en el artículo "*[Superhéroes contra el maléfico Bug](http://localhost:4000/2022/07/20/superheros-contra-bugs.html)*", en Buk tenemos superhéroes; cargos rotativos que se dedican exclusivamente a resolver incidencias de los clientes cuando SAC no puede hacerlo.

También es importante saber cómo es la vista de administración de un recurso en Active Admin. En la siguiente imagen se ve una; a la izquiera está la tabla con los registros y a la derecha sus filtros.

![Tabla y filtros de un recurso en Active Admin]({{page.images_path}}/active_admin.png)

Sabiendo eso, veamos cuál fue el problema que suscitó mi aporte.

### El problema

Un agente de SAC, para solucionar una incidencia de un cliente, debía acceder a una vista de Active Admin donde se listan ciertos recursos del cliente. Intentó ingresar y ¡paf! 💥 error 500. El servidor no respondió, la vista no cargó y SAC no pudo solucionar el problema del cliente. Ese día yo estaba como superhéroe del equipo encargado de esa sección de Active Admin, por lo que el agente de SAC se comunicó conmigo para solucionar su problema. Probando en mi ambiente de desarrollo, ingresé a la vista con el problema y obtuve el siguiente error:
```
PG::QueryCanceled: ERROR: canceling statement due to statement timeout
```
Es decir, el sistema estuvo mucho tiempo obteniedo información desde la base de datos y alcanzó el límite de tiempo. Lo primero que pensé fue que la tabla que se estaba intentando cargar tenía muchas filas. Sin embargo, la tabla estaba paginada, es decir, que consulta en la base de datos sólo lo necesario para mostrar una página de la tabla, no intenta obtener toda la data de una vez. 🤔 "Extraño el error", pensé. Conversando con otro *software engineer* de Buk vimos que el problema podía estar en la carga de los filtros de la tabla en vez de en la data misma. Considerando eso eliminé ciertos filtros que necesitaban mucha data y se usaban poco y... 🥁 sí, el problema estaba ahí, en la carga de data para los filtros. La vista cargó rápidamente sin problemas. Subí los cambios a producción y SAC pudo solucionar el incidente del cliente.

### Una oportunidad de mejora 💡

Luego de solucionar el error me quedé pensando: ¿por qué Active Admin no me dijo que el problema estaba en los filtros? Perdí tiempo buscando el problema donde no estaba. Y seguí pensando. Si yo tuve este problema, también podrían tenerlo otros miles de usuarios de Active Admin (al momento de escribir este artículo, [la gema es usada en más de 35 mil repositorios](https://github.com/activeadmin/activeadmin/network/dependents?dependent_type=REPOSITORY)). Tal como vimos en el artículo "*[Rascando una picazón, o como mejoramos las cosas que usamos](https://buk.engineering/2022/05/10/rascando-picazon-como-mejoramos-cosas-usamos.html)*", me di cuenta de que podía mejorar esta herramienta que usamos en Buk y así ayudar a *devs* no solo de Buk, sino que de todo el mundo.

### La solución

Sin pensarlo más, cloné el [repositorio de Active Admin](https://github.com/activeadmin/activeadmin), encontré dónde se levantaba el error de *timeout* y lo intercepté para dar más información en su mensaje. Agregué estas 2 líneas de código:

```ruby
rescue ActiveRecord::QueryCanceled => error
  raise ActiveRecord::QueryCanceled.new "#{error.message.strip} while querying the values for the ActiveAdmin :#{method} filter"
```

Es decir, indiqué que el error se da obteniendo los datos para un determinado filtro de la tabla. Después de probar mucho y asegurarme de que la implementación era la mejor posible, seguí las [instrucciones de la guía para contribuir en Active Admin](https://github.com/activeadmin/activeadmin/blob/master/CONTRIBUTING.md), y así creé [este PR](https://github.com/activeadmin/activeadmin/pull/8117). Debido a mi entusiasmo ante la posibilidad de aportar rápido a un conocido proyecto Open Source, pasé por alto algo importante que siempre aplicamos en Buk: *"toda funcionalidad debe ir con sus tests"*, ante lo cual un *dev* de la comunidad Open Source me pidió que agregara un test. Y precisamente eso fue lo que más me costó, dado que Active Admin usa [Spec](https://github.com/ruby/spec) para los tests y yo nunca había hecho pruebas con Spec. Finalmente logré hacer el test.

Luego del comentario del *dev* de la comunidad y de que mi PR pasara con éxito la revisión automática de cobertura de tests, mi PR llevaba más de un mes sin interacción. Ya estaba perdiendo la esperanza cuando Javier Julio (mantenedor de Active Admin) me pidió que corrigiera ciertos detalles. Lo hice y subí los cambios, él me aprobó el PR y el 1 de diciembre de 2023 *mergeó* mi commit a *master* 🥹.

![Merge de mi PR a Active Admin]({{page.images_path}}/merge_PR.png)

### Algunos pensamientos 💭

Todo lo contado acá me dejó algunos pensamientos que quiero compartir:

- Sí, cuantitativamente es un pequeño aporte; 2 líneas de funcionalidad y 15 de tests. Pero para mí fue un gran logro como persona y como *software engineer*.
- El que quiere, puede. No soy experto en Ruby on Rails ni en Active Admin. Llevo pocos años trabajando como *software engineer* y no soy un programador innato. Simplemente puse en práctica uno de los [pilares de Buk](https://www.buk.cl/quienes-somos): *"Vamos al infinito y más allá"*. Fui curioso y no me contenté solamente con solucionarle el problema al agente de SAC; también vi una oportunidad de mejora y la aproveché, y con esfuerzo y perseverancia logré que mi código llegara a Active Admin.
- Comparto los pensamientos de Felipe en su artículo "*[Rascando una picazón, o como mejoramos las cosas que usamos](https://buk.engineering/2022/05/10/rascando-picazon-como-mejoramos-cosas-usamos.html)*" sobre el ecosistema Open Source y el hecho de aportar en él.
