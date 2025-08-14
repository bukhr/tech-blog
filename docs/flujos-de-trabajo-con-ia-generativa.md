# Flujos de trabajo con IA Generativa

Este documento describe los flujos de trabajo (*workflows*) disponibles para utilizar IA generativa en la creación y gestión de contenido para el Buk Tech Blog. El objetivo no es reemplazar a un autor, sino asistirlo y optimizar su tiempo.

## Workflows disponibles

- [onboarding](#onboarding): Guía de onboarding para desarrolladores del blog
- [create-post](#create-post): Crear una nueva publicación (post)
- [create-interview](#create-interview): Crear una nueva entrevista
- [create-author](#create-author): Crear una página de autor
- [topic-suggestion](#topic-suggestion): Obtener sugerencias de temas para publicaciones
- [review](#review): Revisar el contenido existente
- [review-pr](#review-pr): Revisar un Pull Request

## Cómo utilizar los workflows

Para utilizar cualquiera de estos workflows, debes seguir estos pasos:

1. Abrir el chat de Windsurf ([Cascade](https://windsurf.com/cascade)) en el repositorio del blog técnico
2. Seleccionar el modelo `Claude 3.7 (Thinking)` para obtener mejores resultados
3. Escribir el comando del workflow (por ejemplo: `/create-post`) seguido de tu instrucción
4. Seguir las indicaciones que te proporcione el asistente

## Lista de workflows

### onboarding

Este workflow proporciona una guía paso a paso para nuevos desarrolladores que se incorporan al equipo del Buk Tech Blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/onboarding` para obtener una guía paso a paso para nuevos desarrolladores que se incorporan al equipo del Buk Tech Blog.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de onboarding.

- También puedes proporcionar más detalles para recibir una guía más personalizada, ejemplo:

    ```prompt
    /onboarding Soy nuevo en el equipo y necesito entender cómo contribuir al blog
    ```

    **Resultado**: El asistente te proporcionará una guía detallada sobre cómo configurar tu entorno, entender la estructura del repositorio y comenzar a contribuir al blog técnico.

### topic-suggestion

Este workflow te proporciona sugerencias de temas para nuevas publicaciones en el Buk Tech Blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/topic-suggestion` para obtener una lista de sugerencias de temas para publicaciones.

    **Resultado**: Se iniciará un chat interactivo donde la IA te entregará una lista de sugerencias de temas para publicaciones.

- También puedes especificar un tema para obtener sugerencias relacionadas, ejemplo:

    ```prompt
    /topic-suggestion Necesito ideas para posts sobre Ruby on Rails y optimización de rendimiento
    ```

    **Resultado**: El asistente te proporcionará una lista de posibles temas para publicaciones relacionadas con Ruby on Rails y optimización de rendimiento.

### create-post

Este workflow te ayuda a crear una nueva publicación para el Buk Tech Blog desde cero.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/create-post` para ejecutar el workflow en modo chat interactivo.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de creación de un post.

- Proporciona todos los datos iniciales para saltar los pasos del chat interactivo, ejemplo:

    ```prompt
    /create-post Me gustaría crear un post sobre la creación de workflows de Windsurf para la automatización de procesos para generar nuevos posts en el Buk Tech Blog. El autor será aboneto.
    ```

    **Resultado**: Se creará un borrador en `_drafts/workflows-de-windsurf-para-automatizacion-de-posts.md` con el contenido del post. Luego podrás mejorar el post, sea manualmente o mediante instrucciones adicionales en el chat.

### create-interview

Este workflow te ayuda a crear una nueva entrevista en el Buk Tech Blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/create-interview` para ejecutar el workflow en modo chat interactivo.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de creación de una entrevista.

- Proporciona todos los datos iniciales para saltar los pasos del chat interactivo, ejemplo:

    ```prompt
    /create-interview Me gustaría crear una entrevista con Meraioth Ulloa, que es Staff Software Engineer en Buk. El tema de la entrevista es sobre la creación de workflows de Windsurf para la automatización de procesos para generar nuevos posts en el Buk Tech Blog.
    ```

    **Resultado**: Se creará un borrador de entrevista que podrás personalizar según tus necesidades. No se generarán las respuestas de las preguntas de forma automática, solo el esqueleto de la entrevista.

### create-author

Este workflow te ayuda a crear una nueva página de autor en el Buk Tech Blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/create-author` para ejecutar el workflow en modo chat interactivo.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de creación de un archivo de autor, haciéndote preguntas para obtener toda la información necesaria.

- Proporciona todos los datos iniciales para saltar los pasos del chat interactivo, ejemplo:

    ```prompt
    /create-author Necesito crear una página de autor para Meraioth Ulloa, que es Staff Software Engineer en Buk. Su usuario de GitHub es meraioth.
    ```

    **Resultado**: Se creará un archivo de autor en `_authors/` con toda la información necesaria.

### review

Este workflow te ayuda a revisar el contenido existente en el Buk Tech Blog para asegurar su calidad y cumplimiento con las reglas del blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/review` para ejecutar el workflow en modo chat interactivo.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de revisión del contenido. Si hay archivos markdown con modificaciones recientes, serán sugeridos automáticamente, si están en alguna de las carpetas `_posts`, `_drafts` o `_authors`.

- También puedes especificar el archivo que deseas revisar, ejemplo:

    ```prompt
    /review _posts/2025-06-30-cpu-throttling-en-kubernetes-el-enemigo-silencioso.md
    ```

    **Resultado**: El asistente revisará el archivo especificado y te proporcionará sugerencias de mejora basadas en los criterios de revisión establecidos.

### review-pr

Este workflow te ayuda a revisar un Pull Request en el Buk Tech Blog para asegurar su calidad y cumplimiento con las reglas del blog.

#### Cómo utilizarlo

Ejecutar el siguiente comando del workflow:

- `/review-pr` para ejecutar el workflow en modo chat interactivo.

    **Resultado**: Se iniciará un chat interactivo donde la IA te guiará en el proceso de revisión del Pull Request.

- También puedes especificar el Pull Request que deseas revisar, ejemplo:

    ```prompt
    /review-pr 222
    ```

    **Resultado**: El asistente revisará el Pull Request especificado y te proporcionará sugerencias de mejora basadas en los criterios de revisión establecidos.
