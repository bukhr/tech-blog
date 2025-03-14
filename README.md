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

# Tags

Hay 2 formas de poner las etiquetas:
1. Separados por espacios, sin corchetes y sin comas:
    ```
      tags: buk programación API
    ```
2. Con corchetes y separados por comas:
    ```
      tags: [buk, programación, API]
    ```
**Importante:** cuando se quiere poner un tag cuyo nombre tiene espacios (por ejemplo "software engineering") se debe usar la segunda forma

## Convenciones
  - [Convenciones de git](docs/git-conventions.md)

## Cómo agregar una entrevista

Para agregar una nueva entrevista al blog, sigue estos pasos:

1. Crea una nueva entrevista usando:

```sh
bin/create_interview "entrevista con [nombre del entrevistado] - [rol o especialidad]"
```

Esto creará:
- Un archivo draft en `_drafts/YYYY-MM-DD-entrevista-[nombre].md`
- Un directorio para imágenes en `assets/img/interviews/[nombre]/`

1. Modifica el Front Matter del archivo con la siguiente estructura:

```yaml
layout: post
title: "Título de la Entrevista"
subtitle: "Rol o descripción breve del entrevistado"
author: "Nombre del Entrevistado"
date: YYYY-MM-DD HH:MM:SS -0600  # se autogenera, pero puedes editarlo
background: '/assets/img/interviews/[nombre-entrevistado].jpg'
categories: interview
tags: [tag1, tag2, tag3]  # usa tags relevantes como: desarrollo, liderazgo-tech, innovación, etc.
images_path: /assets/img/interviews/[nombre-entrevistado]
```

1. Estructura el contenido de la entrevista siguiendo este formato:

```markdown
Breve introducción sobre el entrevistado y el contexto de la entrevista (1-2 párrafos)

## [Pregunta 1]?

[Respuesta 1]

## [Pregunta 2]?

[Respuesta 2]

...
```

1. Agrega las imágenes relacionadas con la entrevista en:
`/assets/img/interviews/[nombre-entrevistado]/`

1. Cuando la entrevista esté lista, publícala usando:

```sh
bin/jekyll publish _drafts/entrevista-con-[nombre]-[rol].md
```

### Recomendaciones para entrevistas

- **Imágenes**: Incluye una foto del entrevistado (con su permiso) y/o imágenes relevantes a los temas discutidos
- **Estructura**: Mantén un formato pregunta-respuesta claro y consistente
- **Extensión**: Procura que las respuestas sean concisas y enfocadas
- **Tags**: Usa tags específicos que ayuden a categorizar el contenido de la entrevista
- **Background**: Usa una imagen de fondo relacionada con el tema de la entrevista o el área de expertise del entrevistado

### Revisión y publicación

Al igual que con los posts regulares:

1. Asigna un revisor que conozca el tema o área del entrevistado
2. Asegúrate de que el entrevistado haya revisado y aprobado el contenido final
3. Solicita la aprobación final en el canal #coord-the-weekly-commit

## Usando Jekyll

### Documentación

<https://jekyllrb.com/docs/home>

### Code Highlighting

Se puede activar el resaltado por colores al definir un bloque de código indicando el lenguaje (`ruby`, `sh`, `python`, etc.). Por ejemplo:

```ruby
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
```
