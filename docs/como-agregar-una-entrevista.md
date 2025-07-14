# Cómo agregar una entrevista

Las entrevistas son [posts](como-agregar-un-post.md) que se publican en el directorio `_posts`, pero se distinguen por contener la categoría `interview` en el atributo `categories` del [Front Matter](https://jekyllrb.com/docs/front-matter/).

## Pasos para agregar una entrevista

Para agregar una nueva entrevista al blog, sigue estos pasos:

1. Crea una nueva entrevista usando:

    ```sh
    bin/create_interview "entrevista con [nombre del entrevistado] - [rol o especialidad]"
    ```

    Esto creará:

    - Un archivo draft en `_drafts/entrevista-con-[nombre]-[rol].md`
    - Un directorio para imágenes en `assets/img/interviews/[nombre]/`

2. Completa los datos del inicio del documento (la sección de [Front Matter](https://jekyllrb.com/docs/front-matter/)) con la información correspondiente al post. Ejemplo:

    ```Yaml
    ---
    layout: post
    title: Título de la Entrevista
    subtitle: Rol o descripción breve del entrevistado
    image: "/assets/img/interviews/[nombre-entrevistado]/img-metadata.png"
    author: Nombre del Entrevistado
    tags:
    - tag1
    - tag2
    - tag3
    categories: interview
    images_path: "/assets/img/interviews/[nombre-entrevistado]"
    date: YYYY-MM-DD HH:MM:SS -0600
    background: "/assets/img/interviews/[nombre-entrevistado]/background.png"
    ---
    ```

    Más detalles de los atributos en [Atributos del post (Front Matter)](como-agregar-un-post.md#atributos-del-post-front-matter)

3. Escribe el contenido de la entrevista después del `---`. No es necesario usar `#` para el título principal, ya que éste es generado automáticamente por Jekyll. Sin embargo, debes agregar todos los demás subtítulos a partir de `##`. El contenido de la entrevista debe estar escrito en formato Markdown, siguiendo este formato:

    ```markdown
    Breve introducción sobre el entrevistado y el contexto de la entrevista (1-2 párrafos)

    ## [Pregunta 1]?

    [Respuesta 1]

    ## [Pregunta 2]?

    [Respuesta 2]

    ...
    ```

4. Añade las imágenes relacionadas con la entrevista en: `assets/img/interviews/[nombre]/`

5. Cuando la entrevista esté lista para publicarse, ejecutar el siguiente comando:

    ```sh
    bin/jekyll publish _drafts/entrevista-con-[nombre]-[rol].md
    ```

### Recomendaciones para entrevistas

- **Imágenes**: Incluye una foto del entrevistado (siempre con su consentimiento) y/o imágenes relevantes a los temas tratados en la conversación.
- **Estructura**: Mantén un formato pregunta-respuesta claro y consistente a lo largo de toda la entrevista.
- **Extensión**: Procura que las respuestas sean concisas y enfocadas en el tema principal.
- **Etiquetas (Tags)**: Utiliza etiquetas específicas que ayuden a categorizar adecuadamente el contenido de la entrevista.
- **Imagen de fondo (Background)**: Selecciona una imagen de fondo relacionada con el tema de la entrevista o el área de especialidad del entrevistado.

### Revisión y publicación

Antes de publicar la entrevista, solicita la aprobación del entrevistado, quien debe revisar el texto para verificar la exactitud del contenido y sugerir cualquier cambio necesario. Posteriormente, solicita la aprobación final en el canal [#comité-techblog](https://chat.google.com/room/AAAAm1mqm2E?cls=7).