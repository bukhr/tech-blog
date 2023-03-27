---
layout: post
title: Comandos git para ahorrar minutos y memoria
author: Fernando Navajas
subtitle: Cuando iniciamos en la programación con GIT aprendemos varios comandos simples como "git pull", "git clone", "git commit", y una vez que lo hemos aprendido ...
tags: git
date: 2021-04-15 15:08 -0400
background: /assets/images/2021-04-15-comandos-git-para-ahorrar-minutos-y-memoria/gatitos.jpeg
---

Cuando iniciamos en la programación con GIT aprendemos varios comandos simples como "git pull", "git clone", "git commit", y una vez que lo hemos **aprendido** a utilizar, pasamos largos periodos sin buscar más información, pensamos que lo que sabemos es suficiente para librarnos de los problemas del día a día. Justo aquí te topaste con el fin de ese periodo, y ahora te ayudare a ahorrar un par de minutos y memoria cuando estés programando en tu nuevo proyecto.

La finalidad de este post es ser una lectura rápida que te ayude a ahorrar minutos y no perderlos leyendo, así que manos a la obra.

### Alias

Los alias son apodos que le puedes dar a comandos de git, con la finalidad de escribir menos y ayudar con la memoria de los comandos git, que varias veces terminamos buscándolos en Google.

Por ejemplo: `git checkout <rama>`. Este comando puede ser abreviado como `git ch <rama>`

Para definir un Alias, debes agregarlo a un archivo de configuración de git, que tienen el nombre de **.gitconfig** (archivo oculto), el cual puede ser el **global** (en el directorio *"/home/tu_usuario/.gitconfig"* de tu computador, si estás en linux o mac, basta con escribir `cd` en consola y te llevara a la ubicación, si es windows es en *"C:\\.gitconfig"*) o **local** ( en la carpeta donde se encuentra el proyecto accedemos al archivo en *".git/config"*). Para ejemplos ocupare la configuración global.

Una vez posicionado, ocupas tu editor de texto favorito (en mi caso nano) y editamos el archivo:

```sh
nano .gitconfig
```

podemos agregar los alias al principio o al final. Ejemplo de mi **.gitconfig**

```
[alias]
       ch = checkout
       st = status
       co = commit -m
       chf = checkout -f
       pf = push --force
       br = branch
       rbi = "!f() { git rebase -i HEAD~$1; }; f"
       rbm = rebase master
       reo = "!f() { git reset --hard origin/$1; }; f"
       in = commit --amend --no-edit
       re = "!f() { git reset --soft HEAD~$1; }; f"
       rbc = rebase --continue
```

Los alias también pueden ser agregados por comandos de consola, de la siguiente forma:

```sh
git config --global alias.ch checkout
```
Donde el tag **- - global** es para definir que configuración queremos modificar, seguido de la **seccion.clave** en este caso **alias.ch** y su valor **checkout**

Con esto podremos utilizar el comando `git ch rama` como si fuera `git checkout rama`

*Todos tenemos formas distintas de recordar las cosas, por lo que puedes elegir el alias que mejor te represente el comando. En mi caso para los comandos "clásicos" ocupo las primeras 2 letras, para las demás es solo mi forma de recordarlas.*

Explicaré algunos de estos métodos, que posiblemente te ayudarán en tu día a día

`git chf --> git checkout -f`

- *Descarta todos los cambios realizados*, resulta útil cuando pruebas cambios y luego no los necesitas.

`git re 1 --> git reset --soft HEAD~1`

- *Desarma el último commit* y conserva los cambios en el stage (como si hicieras un git add .)

`git in --> git commit --amend --no-edit`

- *Agrega los cambios que están en el área de Stage al último commit*, este comando me resulta muy útil cuando debo agregar una corrección al último commit que he hecho. El indicador `--no-edit ́ permite hacer las correcciones sin alterar el mensaje.

`git rbi 3 --> git rebase -i HEAD~3`

- *Realiza un rebase interactivo de los últimos 3 commits*
Esto puede ahorrar bastante tiempo para algunos teclados donde es difícil darle al ~ (virgulilla).
Un rebase interactivo de N commits atrás, útil para realizar modificaciones a N commits pasados

`git rbc --> rebase --continue`

- De la mano con el rebase interactivo, a veces tenemos conflictos al aplicar un rebase, al solucionar estos conflictos, debemos darle un continue al comando de rebase y solo para ahorrar un par de segundos, tengo un alias que lo hace más fácil.


En internet puedes encontrar comandos hechos para cosas más complejas, como por ejemplo: Ver los últimos commits ordenados por fecha.
`branches = branch --sort=-committerdate --format='%(HEAD)%(color:yellow)%(refname:short) | %(color:bold green)%(committerdate:relative) | %(color:blue)%(subject)%(color:reset)' --color=always`

Posiblemente ocupes comandos distintos y hasta únicos, pero te aseguro que más de uno lo ocupas lo suficiente para que se merezca un alias. Te invito a aplicar alias a tus comandos, ahorrar un par de minutos y simplificarte la vida.
