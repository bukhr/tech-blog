# Cómo agregar un post

Antes de crear un post, revisa en el [Tech Blog](https://buk.engineering/) que no exista ya un post con el mismo tema. También verifica en [Jira](https://buk.atlassian.net/jira/software/projects/TECHBLOG/boards/460) que ningún otro desarrollador esté escribiendo sobre el mismo tema.

- Si el tema no ha sido abordado previamente, por favor añádelo en [Jira](https://buk.atlassian.net/jira/software/projects/TECHBLOG/boards/460) para que todos sepan que ya estás trabajando en él.

- Si el tema ya ha sido abordado, por favor ponte en contacto con el desarrollador que esté escribiendo sobre el mismo para ofrecerte a colaborar.

## Índice

1. [Paso a paso para crear un post](#paso-a-paso-para-crear-un-post)
2. [Atributos del post (Front Matter)](#atributos-del-post-front-matter)
3. [Assets](#assets)
4. [Tags (Etiquetas)](#tags-etiquetas)
5. [Convenciones](#convenciones)
6. [Code Highlighting](#code-highlighting)
7. [Documentación](#documentación)

## Paso a paso para crear un post

1. Usa el comando `bin/jekyll draft "El título de mi post"` para crear un borrador (`draft`) en el archivo `_drafts/el-titulo-de-mi-post.md`.

2. Completa los datos del inicio del documento (la sección de [Front Matter](https://jekyllrb.com/docs/front-matter/)) con la información correspondiente al post. Ejemplo:

    ```Yaml
    ---
    layout: post
    title: El título de mi post
    subtitle: Breve descripción para la lista de posts
    image: "/assets/images/2025-06-30-el-titulo-de-mi-post/img-metadata.png"
    author: aboneto
    tags:
    - git
    - MR
    - commits
    date: 2025-06-30 11:33 -0300
    background: "/assets/images/2025-06-30-el-titulo-de-mi-post/background.png"
    ---
    ```

    Más detalles de los atributos en [Atributos del post (Front Matter)](#atributos-del-post-front-matter)

3. Escribe el contenido del post después del `---`. No es necesario usar `#` para el título principal, ya que éste es generado automáticamente por Jekyll. Sin embargo, debes agregar todos los demás subtítulos a partir de `##`. El contenido del post debe estar escrito en formato Markdown.

4. Cuando el post esté listo, ejecutar el comando `bin/jekyll publish _drafts/el-titulo-de-mi-post.md` para mover el borrador al directorio `_posts` con el formato correcto. En este momento se generará automáticamente el campo `date` si no lo has especificado previamente.

5. Crea un Pull Request con el nuevo post siguiendo las [convenciones de git](git-conventions.md).

6. Solicitar la aprobación final en el espacio de Google Chat [#comité-techblog](https://chat.google.com/room/AAAAm1mqm2E?cls=7).

## Atributos del post (Front Matter)

| Atributo      | Descripción                                   |
|---------------|-----------------------------------------------|
| layout        | Define el diseño del post. Actualmente solo se soportan `post` e `interview`. |
| title         | Título del post                              |
| subtitle      | Breve descripción para la lista de posts     |
| image         | Imagen de los metadatos, que aparece al compartir el post. Debe ser almacenada en el directorio `assets/images/YYYY-MM-DD-<titulo_del_post>/img-metadata.png`. |
| author        | Autor del post. Puedes utilizar tu nombre o tu nombre de usuario de GitHub. |
| tags          | Etiquetas del post, en formato de lista.                |
| date          | Fecha del post, en formato `YYYY-MM-DD HH:MM -0300`. Se genera automáticamente al mover el borrador al directorio `_posts`, pero también puedes editarla manualmente. |
| background    | Imagen de fondo del post. Debe ser almacenada en el directorio `assets/images/YYYY-MM-DD-<titulo_del_post>/background.png`. |
| images_path   | Ruta de las imágenes del post. Debe ser `assets/images/YYYY-MM-DD-<titulo_del_post>`. |

## Assets

Si quieres agregar imágenes para que puedan ser utilizadas en toda la aplicación, colócalas en: 
`/assets/images/global`

Si las usarás exclusivamente en tu post, colócalas en:
`/assets/images/YYYY-MM-DD-<titulo_del_post>`

Ejemplo:

```text
/assets/images/2021-03-17-manteniendo-la-historia-ordenada/image1.png
```

Para añadir imágenes a tu post, puedes definir una variable en la sección de [Atributos del post (Front Matter)](#atributos-del-post-front-matter):

```yaml
images_path: /assets/images/YYYY-MM-DD-<titulo_del_post>
```

Luego la puedes usar en tu post de esta forma:

```markdown
![Texto descriptivo de la imagen]({{page.images_path}}/image1.png)
```

## Tags (Etiquetas)

Hay varias formas de definir las etiquetas:

- Agregando la lista de tags:

    ```yaml
    tags:
    - buk
    - programación
    - API
    ```

- Con corchetes y separados por comas:

    ```yaml
    tags: [buk, programación, API]
    ```

**Importante:** cuando quieras usar una etiqueta cuyo nombre contiene espacios (por ejemplo "software engineering") debes utilizar la segunda forma (con corchetes y separados por comas).

## Code Highlighting

Puedes activar el resaltado de sintaxis por colores al definir un bloque de código indicando el lenguaje correspondiente (`ruby`, `sh`, `python`, etc.). Por ejemplo:

```ruby
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
```

## Convenciones

- [Convenciones de git](git-conventions.md)

## Documentación

- [Jekyll](https://jekyllrb.com/docs/home)
- [Jekyll Front Matter](https://jekyllrb.com/docs/front-matter/)
- [Cómo agregar un autor](como-agregar-un-author.md)
