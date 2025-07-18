---
description: Onboarding guiado para desarrolladores del blog técnico
---

# Workflow de Onboarding para el Blog Técnico

## Inicio

1. Preguntar al usuario qué desea crear, ofreciendo opciones claras:
   - Publicación (Post)
   - Entrevista
   - Página de Autor

## Flujo para Publicación (Post)

1. **Selección de tema**
   - Verificar temas existentes para evitar duplicados

   ```bash
   find _posts -type f -name "*.md" | sort -r
   ```

   - Sugerir 3-5 temas relevantes basados en:
     - Las reglas definidas en el workflow `.windsurf/workflows/topic-suggestion.md`

2. **Creación del archivo**
   - Utilizar el workflow `/create-post` para generar la estructura base
   - Explicar la importancia del Front Matter y sus campos

3. **Estructura del contenido**
   - Guiar al usuario para incluir:
     - Introducción clara (contexto y objetivo)
     - Desarrollo (con subtítulos organizados)
     - Conclusión o resumen
     - Referencias y recursos adicionales

4. **Redacción colaborativa**
   - Ofrecer asistencia para mejorar párrafos específicos
   - Sugerir mejoras de estilo manteniendo la voz del autor
   - Recordar mantener términos técnicos en inglés con traducción en paréntesis

## Flujo para Entrevista

1. **Ejecución Guiada**
   - Utilizar el workflow `/create-interview` para generar la entrevista
   - Explicar al usuario los pasos durante la ejecución

## Flujo para Página de Autor

1. **Recopilación de información**
   - Solicitar datos necesarios:
     - Nombre completo
     - Rol/cargo
     - Breve biografía
     - Enlaces a redes profesionales (opcional)
     - Foto (instrucciones para agregarla)

2. **Creación del archivo**
   - Utilizar el workflow `/create-author` para generar la estructura
   - Explicar la ubicación y formato del archivo

## Revisión final (para cualquier tipo de contenido)

1. **Verificación técnica**
   - Comprobar que el formato markdown es correcto
   - Verificar que los enlaces funcionan
   - Asegurar que las imágenes se muestran correctamente

2. **Revisión de contenido**
   - Ortografía y gramática
   - Coherencia y claridad
   - Cumplimiento de las reglas del blog:
     - Contenido en español con términos técnicos en inglés
     - Sin información confidencial o sensible
     - Estilo profesional y técnico

3. **Previsualización**
   - Guiar al usuario para ejecutar el blog localmente y verificar cómo se ve

   ```bash
   bundle exec jekyll serve --drafts
   ```

## Reglas generales

- Seguir siempre las directrices en `.windsurf/rules/globalrules.md`
- Mantener un tono profesional pero accesible
- Asegurar que el contenido aporta valor técnico
- Respetar la privacidad y seguridad de la información
