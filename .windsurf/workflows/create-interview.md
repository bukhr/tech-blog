---
description: Crear entrevista con ayuda de la IA Generativa
---

# Workflow para Entrevista

## Flujo

1. **Preparación**
   - Solicitar información básica del entrevistado:
     - Nombre completo
     - Rol/cargo
     - Experiencia relevante
   - Revisar la documentación en `docs/como-agregar-una-entrevista.md`

2. **Estructura de la entrevista**
   - Ayudar a formular 5-10 preguntas relevantes
   - Organizar preguntas en orden lógico (introducción → temas técnicos → conclusión)

3. **Creación del archivo**
   - Generar el archivo en `_drafts` con el formato adecuado
   - Configurar correctamente el Front Matter

4. **Contenido y formato**
   - Estructurar la entrevista con formato pregunta-respuesta
   - Sugerir una introducción que presente al entrevistado
   - Incluir una conclusión o cierre

## Revisión final

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
- No generar las respuestas de las preguntas
