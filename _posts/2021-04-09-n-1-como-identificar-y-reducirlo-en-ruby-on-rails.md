---
layout: post
title: N+1, Cómo identificar y reducirlo en Ruby on Rails
author: Juan Pablo Rojas | Franklin Padilla | Fernando Navajas
images_path: "/assets/images/2021-04-09-n-1-como-identificar-y-reducirlo-en-ruby-on-rails"
tags: [git, ruby]
date: 2021-05-03 10:30 -0400
background: "/assets/images/2021-04-09-n-1-como-identificar-y-reducirlo-en-ruby-on-rails/portada.png"
---

### ¿Qué es un N+1 y por qué se produce?

El problema de N+1 es común en modelos de programación de tipo **Object Relational Mapping(ORM)**, en donde principalmente se modelan estructuras de base de datos relacional, mapeando las relaciones de tablas hacia los objetos, pudiendo así, crear fácilmente acciones CRUD que operan directamente sobre la base de datos.

Dicho lo anterior, el problema de N+1 radica principalmente en relaciones del tipo many-to-many / one-to-many, en donde se necesita de una consulta para el objeto principal y otra consulta para un objeto relacionado, generando así N consultas para un conjunto de objetos principales con una adicional para el objeto relacionado.

### Ejemplo de cómo generar un N+1 por código

  ![solucionar, n_1]({{page.images_path}}/n_1_code_example.png)

El código anterior itera sobre todos los registros del objeto del modelo llamado `Postulacion`, del cual recolecta la información de la entidad asociada `Postulante` para al final obtener el nombre del postulante.

### ¿Dónde visualizamos el problema N+1?

La manera más rápida, sin ir más lejos, es mirar la terminal donde se esté ejecutando el servidor de Rails, fijándose en la serie de consultas repetidas hacia una entidad en particular, tal y como se muestra en el siguiente ejemplo:

![solucionar, n_1]({{page.images_path}}/n_1_console_log.png)

Otra forma es utilizando herramientas para detectar el N+1, como `Miniprofiler`, que permite ver dentro de la aplicación las consultas realizadas a la base de datos, entregando los tiempos de carga y su procedencia.

![solucionar, n_1]({{page.images_path}}/n_1_profiler.png)

En la imagen anterior podemos observar en la segunda fila de la columna **query** el valor **96 sql**, esto significa que se han realizado 96 consultas a la base de datos. Al hacer click sobre ese dato se despliega el detalle de las consultas realizadas.

![solucionar, n_1]({{page.images_path}}/n_1_profiler_detail.png)

Se puede apreciar que se realiza la misma consulta varias veces, esto es un indicio que existe un problema de N+1

### ¿Cómo solucionar un N+1?

Una solución a este problema es utilizar una técnica conocida como Eager Loading o Carga Previa la cual consiste en la asociación de modelos relacionados para un determinado conjunto de resultados con solo la ejecución de una consulta, en lugar de tener que ejecutar N consultas, donde N es el número de elementos en el conjunto inicial. En RoR se puede aplicar esta técnica mediante el uso de las funciones `includes`, `eager_load` y `preload`:

- **Includes**

    ![solucionar, n_1]({{page.images_path}}/n_1_code_solution.png)

    En el ejemplo, cuando se itera sobre la colección de postulaciones, todos los registros de postulantes asociados a postulaciones, son incluidos al principio, con esto, se reducirá la cantidad de consultas SQL ejecutadas por el ORM a solo dos consultas:

    ![solucionar, n_1]({{page.images_path}}/n_1_solution_console_log.png)

    Nuevamente si abrimos miniprofiler a simple vista se puede observar que en la segunda fila se han reducido las consultas sql de 96 a 23.

    ![solucionar, n_1]({{page.images_path}}/n_1_solution_profiler.png)

    Luego, haciendo click en el mismo lugar donde se indican 23 sql, se puede acceder a las consultas realizadas y nos podemos dar cuenta que la inmensa cantidad de consultas mostradas antes de eliminar el N+1 **¡No están!**

    ![solucionar, n_1]({{page.images_path}}/n_1_solution_profiler_detail.png)

## Conceptos adicionales

- **Preload**

  ![solucionar, n_1]({{page.images_path}}/preload_example.png)

  Preload es similar a includes en el sentido de que también precarga los datos de la asociación mediante la ejecución de una consulta aparte. La desventaja de usar `preload` es que no podemos usar la tabla asociada en la cláusula `where` ya que `preload` siempre genera 2 consultas sql separadas.

- **Eager load**

  ![solucionar, n_1]({{page.images_path}}/eager_load_example.png)

  A diferencia de `preload`, `eager_load` produce solo **UNA** consulta la cual se basa en un `join (LEFT OUTER JOIN)` entre ambos modelos relacionados. ActiveRecord itera sobre el resultado y construye los objetos correspondientes de ambas tablas.

## Herramientas para detectar N+1

- **Bullet**: esta gema de Ruby está diseñada para ayudar a incrementar el desempeño de la aplicación mediante la reducción del número de consultas a BD que se llevan a cabo. Chequea las queries que se van ejecutando mientras se desarrolla y notifica cuándo se debe usar _Carga Previa (Eager Load)_ para evitar problemas de N + 1, también avisa cuando se está aplicando _Carga Previa_ innecesariamente.
  Puedes revisar más sobre la documentación de esta gema [aquí](https://github.com/flyerhzm/bullet).

    ![solucionar, n_1]({{page.images_path}}/bullet_config.png)

    Una vez se pone en marcha el servidor, si tomamos el ejemplo dado anteriormente, al ingresar a la ruta donde se genera el n+1, la gema nos indicará exactamente donde se produce el problema y una posible solución:

    ![solucionar, n_1]({{page.images_path}}/bullet_alert.png)

- **Rack Mini Profiler**: es la herramienta de profiling más popular de Rails. Muestra las llamadas a base de datos, inspecciona la pila de ejecución y provee una serie de métricas acerca del uso de memoria. Puedes revisar más información sobre esta herramienta [aquí](https://github.com/MiniProfiler/rack-mini-profiler).
