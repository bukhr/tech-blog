---
description: Revisar un Pull Request de forma técnica y detallada
---

# Workflow para Revisar un Pull Request

## Fase 1: Preparación y Contexto

1. **Obtener Información del PR**
   - Solicitar al usuario el número o URL del PR que desea revisar.
   - Visualizar información detallada del PR usando GitHub CLI:

     ```bash
     gh pr view <número-pr> --json title,body,author,state
     ```

   - Preguntar sobre el contexto y el propósito del PR (nueva funcionalidad, corrección de bugs, mejora, etc.).

2. **Configuración del Entorno**
   - Verificar si el usuario tiene el PR localmente o necesita descargarlo.
   - Guiar en la obtención y prueba del código si es necesario:

     ```bash
     gh pr checkout <número-pr>
     ```

## Fase 2: Análisis de Cambios

1. **Revisión General de Cambios**
   - Ver el resumen de cambios con GitHub CLI:

     ```bash
     gh pr diff <número-pr> --color=always
     ```

2. **Análisis de Código por Archivo**
   - Para cada archivo modificado, revisar detalladamente:

     ```bash
     gh pr diff <número-pr> -- ruta/al/archivo
     ```

   - Si necesitas revisar el historial de cambios:

     ```bash
     git blame ruta/al/archivo
     ```

## Fase 3: Criterios de Revisión Técnica

1. **Cumplimiento de Estándares**
   - **Estructura del código:** El código sigue la arquitectura y patrones establecidos.
   - **Convenciones de nomenclatura:** Nombres descriptivos y coherentes con las prácticas del proyecto.
   - **Jekyll:** Verificar que los cambios respetan la estructura de Jekyll.
   - **Front Matter:** Comprobar que el front matter está correctamente formateado.

2. **Calidad del Código**
   - **Funcionalidad:** El código hace lo que se supone que debe hacer.
   - **Eficiencia:** No hay operaciones innecesariamente complejas o costosas.
   - **Mantenibilidad:** El código es fácil de entender y modificar.
   - **Reutilización:** Se aprovechan componentes existentes cuando es posible.

3. **Seguridad y Privacidad**
   - Verificar que no hay credenciales expuestas ni información sensible.
   - Comprobar que no hay vulnerabilidades obvias de seguridad.
   - Asegurar que cualquier integración externa se realiza de forma segura.

## Fase 4: Retroalimentación

1. **Preparación del Feedback**
   - Organizar los comentarios por categorías:
     - Problemas críticos (must fix)
     - Sugerencias de mejora (nice to have)
     - Preguntas y aclaraciones
     - Aspectos positivos (reconocimiento de buen trabajo)

2. **Documentación del Feedback**
   - Preparar comentarios claros y específicos con ejemplos cuando sea necesario.
   - Ofrecer soluciones alternativas cuando se identifiquen problemas.
   - Añadir comentarios directamente al PR:

     ```bash
     gh pr comment <número-pr> --body "Tu comentario detallado aquí"
     ```

   - Para comentar en líneas específicas, utilizar la interfaz web de GitHub.

## Fase 5: Cierre y Decisión

1. **Recomendación Final**
   - Basado en la revisión, enviar la revisión con el comando apropiado:

     ```bash
     # Para aprobar el PR
     gh pr review <número-pr> --approve --body "Aprobado: [razón]"
     
     # Para solicitar cambios
     gh pr review <número-pr> --request-changes --body "Se requieren cambios: [detalles]"
     
     # Para comentar sin bloquear
     gh pr review <número-pr> --comment --body "Comentarios: [detalles]"
     ```

2. **Seguimiento**
   - Configurar notificaciones para seguir la actividad del PR:

     ```bash
     gh pr subscribe <número-pr>
     ```

   - Establecer un plan para verificar las correcciones si se solicitaron cambios.
   - Documentar las lecciones aprendidas para futuras revisiones.

## Reglas Generales

- Mantener un tono constructivo y respetuoso en todos los comentarios.
- Enfocarse en el código y los cambios, no en la persona.
- Ser específico en los problemas identificados y claro en las soluciones propuestas.
- Reconocer y destacar aspectos positivos del PR.
- Priorizar los problemas según su impacto y severidad.
- Seguir siempre las directrices definidas en el archivo `globalrules.md`.

## Reglas Específicas por Tipo de Contenido

### Revisión de Autores

- Verificar que el archivo esté en el directorio `_authors` con un nombre que sirva como identificador único.
- Validar el Front Matter obligatorio:
  - `layout: author`
  - `short_name`: Identificador único del autor (coincide con el nombre del archivo sin extensión)
  - `title`: Nombre completo del autor (entre comillas simples)
  - `name`: Nombre completo del autor
  - `position`: Cargo o rol del autor
- Comprobar que las imágenes relacionadas estén en la ruta correcta: `assets/images/authors/[identificador-del-autor]/`
- Verificar que la biografía del autor esté en formato Markdown adecuado y contenga información profesional relevante.
- Revisar si se han incluido correctamente los enlaces sociales (si aplica): `linkedin_username`, `github_username`, etc.

### Revisión de Posts

- Verificar la ubicación correcta del archivo (en `_posts` para publicaciones o `_drafts` para borradores).
- Validar el formato del nombre de archivo: `YYYY-MM-DD-titulo-del-post-en-minusculas-con-guiones.md`.
- Comprobar el Front Matter obligatorio:
  - `layout: post`
  - `title`: Título del post
  - `subtitle`: Descripción breve
  - `image`: Ruta correcta a la imagen de metadata
  - `author`: Identificador válido de un autor existente
  - `tags`: Lista de etiquetas relevantes
  - `date`: Formato correcto YYYY-MM-DD HH:MM -TTTT
- Revisar que las imágenes y recursos estén en la ubicación correcta: `/assets/images/YYYY-MM-DD-titulo-del-post/`.
- Verificar el formato Markdown del contenido (no usar `#` para título principal, usar `##` para subtítulos).
- Comprobar que el contenido esté en español, manteniendo términos técnicos en inglés cuando sea necesario.
- Verificar que no haya secretos (`password`, `tokens`, etc.) ni información sensible de productos internos.
- Verifica que el post no haya sido creado más del 80% por IA generativa.

### Revisión de Entrevistas

- Verificar la ubicación correcta del archivo (en `_posts` para publicaciones o `_drafts` para borradores).
- Comprobar el Front Matter obligatorio, incluyendo todos los del post más:
  - `categories: interview`
  - `images_path`: Ruta correcta al directorio de imágenes de la entrevista
- Verificar que las imágenes estén en la ubicación correcta: `/assets/img/interviews/[nombre-entrevistado]/`.
- Revisar la estructura de la entrevista:
  - Introducción sobre el entrevistado (1-2 párrafos)
  - Preguntas con formato `## [Pregunta]?`
  - Respuestas debajo de cada pregunta
- Comprobar que no haya preguntas o respuestas en blanco o incompletas.
- Verifica que la entrevista no haya sido creado más del 60% por IA generativa.
