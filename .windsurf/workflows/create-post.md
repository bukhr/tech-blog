---
description: Workflow para crear posts
---

# Workflow para Crear Posts

## Fase 1: Planificación del Post

1. **Tema y Nombre del Post**
   - Pregunte al usuario cuál es el tema del post que desea crear y si tiene algún nombre en mente.
   - Sugiera un título atractivo y conciso basado en el tema proporcionado.

2. **Información del Autor**
   - Verifique si el autor ya existe en `_data/authors.yml`.
   - Si no existe, sugiera crear el autor primero siguiendo la documentación en `docs/como-agregar-un-author.md`.

## Fase 2: Creación del Archivo

3. **Nombre del Archivo**
   - Cree el nombre del archivo siguiendo el formato: `YYYY-MM-DD-titulo-del-post-en-minusculas-con-guiones.md`.
   - Use la fecha actual para la parte YYYY-MM-DD.

4. **Estructura del Front Matter**
   - Revisar la documentación `docs/como-agregar-un-post.md`.

## Fase 3: Desarrollo del Contenido

5. **Estructura del Contenido**
   - Proponga una estructura para el contenido que incluya:
     - Introducción: Contexto y objetivo del post
     - Desarrollo: Secciones principales con subtítulos claros
     - Conclusión: Resumen y llamado a la acción

6. **Redacción Colaborativa**
   - Vaya interactuando con el usuario para desarrollar el contenido, sección por sección.
   - Sugiera mejoras de redacción y formato según sea necesario.

## Fase 4: Finalización

7. **Revisión**
   - Revise con el usuario aspectos como:
     - Ortografía y gramática
     - Coherencia del contenido
     - Enlaces y referencias

8. **Imágenes**
   - Recuerde al usuario incluir imágenes relevantes en `/assets/images/posts/`.
   - Verifique que las imágenes estén correctamente referenciadas en el post.

9. **Prueba Local**
   - Sugiera al usuario probar el post localmente siguiendo las instrucciones en `docs/como-ejecutar-el-blog-localmente.md`.

## Ejemplos de Posts

Para referencia, los posts actuales se encuentran en la carpeta `_posts`. Algunos ejemplos incluyen:

- Artículos técnicos sobre Ruby on Rails
- Posts sobre herramientas y tecnologías utilizadas en Buk
- Entrevistas con miembros del equipo

## Reglas

- Utilice las reglas definidas en el archivo `.windsurf/rules/globalrules.md`