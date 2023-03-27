---
layout: post
title: Subquerys con ActiveRecord
subtitle: Cómo usar subquerys para realizar consultas complejas sin salir de ActiveRecord.
author: Julio Linarez
tags: [rails, active-record]
date: 2021-10-15 11:33 -0300
background: /assets/images/2021-10-01-subquerys-con-activerecord/portada-activerecord.png
image: /assets/images/2021-10-01-subquerys-con-activerecord/portada-activerecord_opt.png
---

Solo en Chile ya más de 2500 empresas usan Buk, eso hace fundamental que nuestra aplicación sea rápida. Una de las causas más comunes en que las aplicaciones web son lentas es por una mala comunicación con su base de datos. Durante la fase de desarrollo hay varios cambios simples que se pueden hacer para que una aplicación consuma menos tiempo.

### Subquerys

Veamos el siguiente código como ejemplo para identificar el problema.

```ruby
activated_user_ids = User.where(activated: true).pluck(:id)
# SELECT "users"."id" FROM "users" WHERE "users"."activated" = true
Post.where(user_id: activated_user_ids)
# SELECT "posts"."*" FROM "posts" WHERE "posts"."user_id" in (1 , 2, .... n)
```

El problema con el código anterior es que hay que hacer dos consultas a la base de datos para obtener resultados. Tambien puede traer problemas si la cantidad de registros es demasiado grande en la primera consulta, porque en la segunda la cantidad de "ids" están explicitos.

Como se podrán imaginar, hay una mejor forma de hacer esta consulta:

```ruby
activated_user_ids = User.where(activated: true).select(:id)
Post.where(user_id: activated_user_ids)
# "SELECT "posts".* FROM "posts" WHERE "posts"."user_id" IN (
#    SELECT "users"."id" FROM "users" WHERE "users"."activated" = true
# )"

#  El "select(:id)" de activated_user_ids es opcional, ActiveRecord lo infiere
#  de la clave primaria del modelo.
```

Ohh, las consultas se anidan y generan una sola en la base de datos 😲.

Podemos ir mucho más alla y realizar consultas un poco más complejas usando subquerys.

```ruby
# Buscamos los usuarios activos
activated_users = User.where(activated: true)

# Buscamos la mayor cantidad de vistas por cada usuario activo
max_view_per_user = Post.select('user_id','max(views) as max_view')
                        .where(visible: true, user_id: activated_users)
                        .group(:user_id, :max_view)

# Buscamos los post más vistos de cada usuario activo
Post.where("(user_id, views) IN (?)", max_view_per_user)

# SELECT "posts"."user_ids" FROM "posts" WHERE (user_id, views) IN (
#   SELECT "posts"."user_ids", max(views) as max_view FROM "posts"
#   FROM "posts"
#   WHERE "posts"."visible" = true
#   WHERE "posts"."user_id" IN (
#     SELECT "users"."id" FROM "users" WHERE "users"."activated" = true
#   )
#   GROUP BY "posts"."user_id", max_view
# )
```

En la consulta anterior hemos anidado dos querys, una dentro de otra, para hallar el post visible con más vistas por usuario activado en la aplicación.

Como podemos ver, usar subquerys nos permite realizar consultas sin perder las ventajas que nos brinda hacerlo por ActiveRecord en comparación a hacerlo con SQL plano.

En buk siempre intentamos optimizar los procesos para poder brindarle a nuestros clientes una mejor experiencia. Si te gusta aplicar este tipo de trucos y quieres ser parte de nuestro equipo, postúlate! [¡Estamos contratando!]({{ site.work_with_us_link }})
