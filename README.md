# Buk Tech Blog

<https://buk.engineering>

## Cómo correr el blog local

```sh
bundle exec jekyll serve --livereload --drafts
```

Abre tu navegador y dirígete a: <http://localhost:4000>

## Como correr el blog local (usando devbox)

1. Asegurate de tener instalado [nix](https://nixos.org/) y [devbox](https://www.jetpack.io/devbox/)
2. Ejecuta en tu maquina

```sh
devbox shell
```
3. Ya en tu entorno virtual ejecuta

```sh
bundle install
bundle exec jekyll serve --livereload --drafts
```
4. Abre tu navegador y dirígete a: <http://localhost:4000>

## Cómo agregar un post

Primero revisa, en este [notion](https://www.notion.so/bukhr/Blog-1872a9fbf389428dae20b06a8bfdbff9), que el tema a tratar no haya sido abordado previamente. Si en efecto es un nuevo tema, por favor añádelo para que todos sepan que ya lo estás escribiendo.\
Recuerda que un post puede tener 1 o más autores, por lo que si tu tema ya está siendo desarrollado, puedes ofrecerte para colaborar en él.

Para agregar un post, usa:

```sh
bin/jekyll draft "el titulo de mi post"
```

Esto creará un archivo `_drafts/el-titulo-de-mi-post.md`. Luego modifica el archivo
para agregarle el contenido.
Recuerda rellenar los datos en el inicio del documento, a esta sección Jekyll le llama [Front Matter](https://jekyllrb.com/docs/front-matter/)
.

```yaml
layout: post
title: Manteniendo la historia ordenada
subtitle: Cómo mantener en orden los commits en tu MR (breve descripción para previews)
image: "/assets/images/img-metadata.png" (imagen para previews, preferiblemente menos de 200px de ancho)
author: Andrés Howard
tags: git
date: 2021-03-17 11:33 -0300 # se autogenera, pero también lo puedes editar
background: "/assets/images/background.png"
```

Cuando tu post esté listo, corre

```sh
bin/jekyll publish _drafts/el-titulo-de-mi-post.md
```

Este comando moverá el draft a la carpeta `_posts` con el formato correcto.

Si el tema de tu post requiere cierto conocimiento específico, por favor asigna un revisor que conozca del tema.
Finalmente asígnalo para su aprobación final a @cflores2 o @jarismendi o pregunta en el canal de slack #tech-blog.

# Assets

Si quieres agregar imágenes para que las pueda usar toda la aplicación, déjalas en: \
`/assets/images/global`

Si las usarás solo en tu post, déjalas en: \
`/assets/images/[nombre-del-post]`

Ejemplo:
```
assets/images/2021-03-17-manteniendo-la-historia-ordenada/image1.png
```

Para añadir imágenes a tu post puedes agregar una variable en el [Front Matter](https://jekyllrb.com/docs/front-matter/) de tu post.

```
images_path: /assets/images/2021-03-17-manteniendo-la-historia-ordenada
```
Luego la puedes usar en tu post de esta forma:
```
![La historia, desordenada]({{page.images_path}}/image1.png)
```


## Convenciones
  - [Convenciones de git](docs/git-conventions.md)

## Usando Jekyll

### Documentación

https://jekyllrb.com/docs/home

### Code Highlighting

Se puede activar el resaltado por colores al definir un bloque de código indicando el lenguaje (`ruby`, `sh`, `python`, etc.). Por ejemplo:

```ruby
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
```
