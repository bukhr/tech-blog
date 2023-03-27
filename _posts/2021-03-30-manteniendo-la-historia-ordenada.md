---
layout: post
title: Manteniendo la historia ordenada
subtitle: A medida que nuestro repositorio va creciendo, se hace fundamental ser ordenado en los commits para que la historia tenga sentido.
  En Buk, tenemos más de 30.000 commits en nuestro repositorio principal...
author: Andrés Howard
tags: git
images_path: "/assets/images/2021-03-17-manteniendo-la-historia-ordenada"
date: 2021-03-30 14:04 -0300
background: "/assets/images/2021-03-17-manteniendo-la-historia-ordenada/portada.png"
---
A medida que nuestro repositorio va creciendo, se hace fundamental ser ordenado en los commits para que la historia tenga sentido.
En Buk, tenemos más de 30.000 commits en nuestro repositorio principal, y somos cerca de 40 devs, por lo que seguir buenas prácticas es fundamental.


Cuando uno mira los commits de un proyecto, debería ser capaz de entender cuál es el aporte de cada uno de ellos, de manera que, si tenemos que hacer un refactor o entender cómo funciona algo, podamos hacerlo de manera simple.


Durante el proceso de desarrollo, es común cometer errores o que en la revisión de un Merge Request nos pidan que cambiemos algo. La forma más común de abordar esto es agregar nuevos commits con los cambios solicitados, pero esto nos genera una historia que es difícil de seguir. La forma correcta es cambiar los commits anteriores.


## ¿Cómo podemos cambiar la historia usando git?


Existen diversas formas de hacer ajustes al historial de cambios, por ejemplo si lo que queremos hacer es editar el último commit lo más simple es hacer un amend:


```sh
git commit --amend
```

Pero, ¿qué pasa si tenemos que hacer cambios en un commit anterior? Pensemos por ejemplo que hicimos un Merge Request y nos falló el test de Rubocop con un archivo que modificamos en un commit distinto al anterior. La forma más simple sería agregar un commit como el siguiente:


```sh
git commit -m "fix: arreglar test rubocop"
```

Sin embargo el problema es que la historia de commits nos queda desordenada:

![La historia, desordenada]({{page.images_path}}/git-history-1.png)

¿Cómo cambiamos la historia entonces?, la respuesta es haciendo un rebase interactivo. Con esto, podemos cambiar el orden de los commits así como también unir dos commits (hacer fixup). Entonces, lo que hacemos es un rebase interactivo desde el commit que queremos editar (seleccionándolo con su id) de la siguiente forma:


```sh
git rebase -i <commit_id>
```

Con esto, se abrirá el editor de texto por defecto con la historia de commits y se podrán realizar cambios. Por ejemplo en la imagen a continuación vemos la historia de una rama en la que hay 5 commits seguidos y abajo un comentario con la explicación de lo que podemos hacer. De esta forma podemos cambiar el orden en que se aplican los cambios o también seleccionar distintos comandos para saltarse un commit, cambiar el mensaje, combinar dos commits, etc.


Entonces, si ejecutamos un rebase interactivo a partir del commit siguiente al que tiene el mensaje “fix: Permitir beneficio de forma masiva cuando hay beneficios formulados” sería el siguiente comando:



```sh
git rebase -i e112c187e75d25635e47616066c967f0c3f8d6c8
```

De manera alternativa, si sabemos que queremos modificar los últimos 5 commits podemos hacer:


```sh
git rebase -i HEAD~5
```

Con esto, nos aparece lo siguiente:


![La historia, para ordenar]({{page.images_path}}/git-history-2.png)

Donde podemos ver que están los 5 commits posteriores al seleccionado y todos con la palabra pick, que significa que todos ellos se aplicarán. Aquí es donde ordenamos la historia: podemos mover el commit para arriba para que se aplique antes, y además cambiamos el comando por fixup, con lo que se va a unir al commit anterior (en este caso el `21544cec3c`) y además al último commit le dijimos que no lo aplique usando el comando drop.


![La historia, editando]({{page.images_path}}/git-history-3.png)


El resultado de esto, es una historia de commits más ordenada porque evita las correcciones y nos permite eliminar commits que no nos interesan.

![La historia, ordenada]({{page.images_path}}/git-history-4.png)


## Haciendo push


Es muy importante tener presente que cuando hagamos push al repositorio vamos a tener que forzarlo ya que la historia no va a cuadrar con la que está arriba, por lo tanto tendremos que hacer el peligroso


```sh
git push --force-with-lease
```
