---
layout: post
subtitle: En Buk, la plataforma está siempre en constante crecimiento y aplicando mejoras, por lo que las migraciones son una parte esencial de la aplicación.
title: Una migración directa del gimnasio
author: Maximiliano García Roe
date: 2022-05-18 10:00 -0400
tags: [ruby, migraciones]
background: "/assets/images/2022-05-18-migracion-directa-gimnasio/portada.jpg"
---

En Buk, la plataforma está siempre en constante crecimiento y aplicando mejoras, por lo que las migraciones son una parte esencial de la aplicación. Estas nacen por nuevos requerimientos, o por razones que en un inicio no pudimos divisar o que estaban fuera del alcance inicial de una tarjeta. Esto hace que necesitemos migraciones que crean nuevas tablas, agreguen columnas nuevas, eliminen atributos existentes, la necesidad de nuevas claves foráneas, etc.

A simple vista, estas nuevas necesidades en nuestra base de datos no se resuelven con un código complejo, pero cuando ya tienes una aplicación lo suficientemente grande, utilizada por centenares de usuarios y donde además trabajan en la aplicación decenas de desarrolladores, una migración que no está bien pensada puede generar varios problemas. Estos problemas pueden ser:

- Dañar el schema de la base datos
- Downtime en la aplicación
- Demoras en el proceso de deploy
- Inconsistencias en tu aplicación

Cuando hacemos una migración, independiente de lo que esta implique, debemos siempre hacernos las siguientes preguntas: ¿la aplicación va correr de manera correcta después de ejecutar la migración? Si la base de datos es lo suficientemente grande, ¿esto no genera problemas en el proceso de deploy? Para ayudarte en este proceso clave es necesario hacer unas _migraciones fuertes_ o mejor conocidas **'Strong Migration'**

## Strong Migration

Son una forma de hacer migraciones de tal manera que sean lo menos invasivas a la aplicación, y que al ejecutarlas, no afecte en su funcionamiento.  Estas se realizan con pequeños cambios que van directos a tu aplicación en producción, para que en el caso de que algún pase falle, revertir el cambio no sea complejo.  Uno de los casos más típicos donde se necesita crear un **strong migration**, es agregar una columna `NOT NULL` con un valor por defecto.

Un ejemplo de un caso específico: supongamos que tienes la tabla `Restaurante` y sus atributos son `nombre` / `estilo` / `rating` y que a este modelo necesitas agregarle el atributo `vegetariano` de tipo booleano para saber si cumple esta condición o no, y quieres que este valor sea `NOT NULL` y además por default tenga valor `False`.

## Pasos a Seguir

Usando el ejemplo anterior, tenemos que relizar una seguidilla de pasos y para este caso nos vamos a basar en un ejemplo de **strong migration** en el framework **Ruby on Rails**.  Cada paso es un cambio directo a tu rama de _producción_, para así estar seguros del funcionamiento del cambio que se quiere hacer.

### 1 - Ignorar la columna

En el modelo `Restaurante` donde quiero agregar la columna, lo primero que hay que hacer es ignorar la columna que se quiere agregar, en este caso `vegetariano`.  Esto no afecta al funcionamiento, ya que se trata de ignorar algo que no existe (todavia)

 ```ruby
 self.ignored_columns = [:vegetariano]
 ```

### 2 - Agregar la columna con el valor por defecto

Ya que la columna está ignorada, para efectos de aplicación esta columna no existe, entonces agregarla a la migración que crea la columna no va afectar al desarrollo de la aplicación. Esta migración tiene que tener el valor por defecto que indicamos más arriba, y así cada vez que se crea un nuevo registro en el modelo, guardará su valor. Ojo que aún no se le define como `NOT NULL`.

 ```ruby
 def up
   add_column :restaurante, :vegetariano, :boolean
   change_column_default :restaurante, :vegetariano, false
 end
 ```

### 3 - Llenar los registros nuevos de la tabla

Ahora se tiene que hacer un cambio que elimine el `ignored_columns` agregado en el [paso 1](#1---ignorar-la-columna). Además se tiene que agregar que, cada vez que se cree un nuevo registro en el modelo, se le asigne el valor por defecto. Esto se realiza para evitar por alguna razón que exista un valor null en la columna al momento de editar o crear un registro.  Para esto en general se usa el callback `before_save` en el modelo.

 ```ruby
 before_save do
   self.vegetariano = false if vegetariano.nil?
 end
 ```

Tambien, dependiendo el caso, se tiene que cambiar las partes de la aplicación donde se crea o edita algún registro del modelo para evitar lo anteriormente explicado

### 4 - Llenar los registros antiguos de la tabla

Ya que la columna `vegetariano` se agregó en pleno funcionamiento, es posible que algún registro en el pasado haya quedado con el valor `NULL` y así evitamos que en el paso siguiente de dejar la columna como `NOT NULL` no se ejecute un error en la app. Para hacer esto se crea una migración de la siguiente manera

 ```ruby
 def up
   Restaurante.where(vegetariano: nil).in_batches do |rows|
     row.update_all(vegetariano: false)
   end
 end
 ```

Se aplica en `in_batches` para que en el proceso de deploy no sea tan invasivo el cambio, porque puede que el modelo tenga muchos datos.

### 5 - Configurar la columna como `NOT NULL`

Ya que sabemos con certeza que no existen valores `NULL` en la columna por todos los pasos anteriores, podemos ahora crear una migración para que la columna `vegetariano` sea `NOT NULL`

 ```ruby
 def up
   change_column_null :restaurante, :vegetariano, false
 end
 ```

Puede que este proceso sea un poco lento pero ayuda que al crear un nueva columna o algún cambio importante en la base datos esto no afecte al funcionamiento de la aplicación.

Esta es una de las tantas formas de crear una strong migration, ya que hay muchos otros casos de aplicación.  Por ejemplo agregar un `foreign key`, cambiar el nombre de una tabla, eliminar una columna, etc. La idea es siempre aplicar esta filosofía al momento de hacer un cambio importante en la base de datos.

Si te interesó este y muchos otros artículos que tratamos en este blog, no dudes en revisar las [oportunidades de trabajo que tenemos en Buk](https://info.buk.cl/reclutamiento-buk-devs?utm_source=blog-eng&utm_medium=link&utm_campaign=outreach) y ¡únete a nosotros!

-----
En este repositorio hay otros casos como este en [StrongMigrations](https://github.com/ankane/strong_migrations)
