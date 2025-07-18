# Cómo agregar un autor (author) al blog

Definir un perfil de autor permite generar una página personalizada que muestra información relevante como nombre, cargo, descripción profesional, enlaces a redes sociales y una lista completa de todos los artículos que ha publicado en el blog.

**No es obligatorio agregar un perfil de autor.** Si el archivo correspondiente existe en el directorio `_authors`, el sistema del blog lo identificará automáticamente. En caso de que no exista, solamente se mostrará el nombre en formato de texto plano ingresado en el atributo `author` del post. A pesar de no ser obligatorio, crear un perfil de autor es altamente recomendable ya que permite dar el debido reconocimiento a quien escribe y proporciona a los lectores una página con información detallada sobre el autor o autora.

## Pasos para agregar un autor

1. Crea un archivo en el directorio `_authors` con un nombre que funcione como identificador único del autor (por ejemplo, `aboneto.md`).

2. Completa el archivo con los datos del autor siguiendo una estructura similar a la de un [post](como-agregar-un-post.md), es decir, incluyendo una sección de *Front Matter* y el contenido principal. Por ejemplo:

    ```yaml
    ---
    layout: author
    short_name: aboneto
    title: 'Antonio Barbosa'
    name: Antonio Barbosa
    position: Software Engineer
    linkedin_username: aboneto
    github_username: aboneto
    background: "/assets/images/authors/aboneto/background.jpeg"
    ---
    ```

    El contenido en formato Markdown que escribas en este archivo se mostrará automáticamente en la sección "Sobre mí" dentro de la plantilla `_layouts/author.html`.

3. Agrega las imágenes relacionadas con el autor (foto de perfil, imagen de fondo, etc.) en la siguiente ruta: `assets/images/authors/[identificador-del-autor]/`.

4. Una vez completado el perfil, crea un Pull Request siguiendo las [convenciones de git](git-conventions.md) establecidas y solicita la aprobación final en el espacio de Google Chat [#comité-techblog](https://chat.google.com/room/AAAAm1mqm2E?cls=7).

Al crear un perfil de autor, el sistema genera automáticamente una página dedicada en el blog bajo la URL `https://buk.engineering/authors/[identificador-del-autor]` (por ejemplo: `https://buk.engineering/authors/aboneto`). Adicionalmente, en cada uno de los posts escritos por este autor, su nombre aparecerá como un enlace clickeable que dirige a esta página de perfil.
