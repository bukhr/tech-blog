---
layout: post
title: "Claude en Buk: Del copiloto al agente autónomo"
subtitle: "Cómo evolucionamos la adopción de IA en un equipo de más de 500 personas, desde un IDE agéntico hasta un agente autónomo con Claude Code."
author: ignacio-figueroa
tags:
- ai
- claude
- agentes
- context-engineering
- developer-experience
images_path: "/assets/images/2026-04-08-claude-en-buk-del-copiloto-al-agente-autonomo"
image: "/assets/images/2026-04-08-claude-en-buk-del-copiloto-al-agente-autonomo/img-metadata.png"
date: 2026-04-08 09:00 -0300
---

Estamos viviendo un punto de inflexión en el desarrollo de software. Entre mayo de 2025 y febrero de 2026, los modelos de inteligencia artificial pasaron de resolver el 72% al 81% de issues reales de GitHub en [SWE-bench Verified](https://www.swebench.com/), el benchmark (referencia) más exigente de la industria. Ese salto no es solo un número: representa un cambio real en lo que la IA puede hacer por las personas que construyen software.

En Buk decidimos apostar fuerte por este cambio. A inicios de 2026, cerca de 550 personas de ingeniería y producto trabajan con Claude Code como herramienta principal, impulsada con IA. Este post cuenta cómo llegamos ahí: desde nuestros primeros pasos con un IDE agéntico en 2025, pasando por el momento en que los modelos dieron un salto cualitativo a fines de ese año, hasta la decisión de migrar a un agente autónomo y lo que estamos construyendo hacia adelante.

Nuestra filosofía siempre ha puesto al desarrollador en el rol de diseñador de software. Lo que importa es el modelamiento, la arquitectura, la mantenibilidad, la revisión. Escribir el código es una necesidad, no el centro de nuestra actividad. En esa línea, vemos a la IA como un exoesqueleto: potencia lo que hacemos, pero el control sigue en manos de las personas.

## Los tres niveles de interacción con la IA

Para entender nuestra evolución, es útil pensar en tres niveles de interacción entre personas e inteligencia artificial:

**Automation** (automatización): tú le dices exactamente qué hacer y la IA lo ejecuta. Es útil, pero limitado — requiere que definas cada paso.

**Augmentation** (aumento): tú y la IA trabajan juntos. Te acompaña en el ciclo de desarrollo, iterando ideas y ayudándote a lograr tu propósito. Aquí la IA ya no solo ejecuta: sugiere, complementa y acelera.

**Agency** (agencia): la IA trabaja de forma independiente. Tú la configuras estableciendo su conocimiento y patrones de comportamiento, en vez de darle tareas puntuales. Toma decisiones, navega el contexto y produce resultados con mínima intervención humana.

Nuestra historia es, en esencia, el camino de Augmentation a Agency.

## La etapa Augmentation: Windsurf

Durante 2025 implementamos Windsurf, un IDE agéntico, como nuestra herramienta de IA para desarrollo. Con cerca de 380 personas del equipo de desarrollo usándolo, el objetivo era claro: acelerar el ciclo de desarrollo sin perder el control sobre el diseño del software.

Trabajamos en tres frentes para potenciar la experiencia:

- **Contexto**: en ese entonces conocido como *windsurfrules*, archivos que le daban a la IA información sobre nuestras convenciones y arquitectura.
- **Integraciones**: formas de conectar la IA a nuestras herramientas como Sentry, Jira o Google Drive.
- **Workflows**: prompts reutilizables que solucionaban problemas recurrentes, invocados directamente por las personas del equipo.

Los resultados fueron mixtos. La herramienta nos ayudaba, pero su autonomía no era la mejor. A fines del período, el 43% de las personas había utilizado solamente un 10% de su cuota disponible, y un 17% prácticamente no la tocó. El NPS era de 30.

Estábamos en el nivel de Augmentation: la IA nos acompañaba y colaboraba en el ciclo de desarrollo, pero necesitaba supervisión constante. Era un buen copiloto, no un ingeniero autónomo.

## El punto de inflexión: noviembre de 2025

En noviembre de 2025 ocurrió algo inusual: tres modelos de gran capacidad fueron lanzados casi simultáneamente. GPT-5.1 de OpenAI, Gemini 3 Pro de Google y Claude Opus 4.5 de Anthropic llegaron al mercado en un período muy corto. No fue un avance incremental — fue un *watershed moment* (momento decisivo).

Los datos en SWE-bench Verified lo reflejan con claridad. En mayo de 2025, Claude Opus 4 resolvía el 72.5% de los issues. Para noviembre, GPT-5.1 alcanzó el 76.3% y Gemini 3 Pro el 76.2%. En diciembre, Claude Opus 4.5 llegó al 80.9%.

Hay un concepto que ayuda a entender por qué esto importa tanto: el ratio entre la potencia del modelo y la complejidad de la tarea. Cuando este ratio cruza cierto umbral, tareas que antes eran demasiado complejas para la IA caen dentro de su capacidad. Eso es exactamente lo que pasó a fines de 2025. El *one-shotting* — donde la IA genera el código para una funcionalidad o una corrección en una sola pasada — se hizo viable para un número creciente de casos de uso.

Los ejemplos no tardaron en aparecer: el navegador Ladybird migró su motor de JavaScript de C++ a Rust con asistencia de IA en dos semanas. Boris Cherny, creador de Claude Code, declaró no haber escrito una sola línea de código desde noviembre.

El tercer nivel de interacción — Agency — estaba comenzando a tomar fuerza.

## La decisión: migrar a Claude Code

En febrero de 2026 terminaba nuestro contrato con Windsurf. Después de evaluar pilotos con distintas herramientas, decidimos migrar a Claude Code.

La razón de fondo fue un cambio de paradigma. Un IDE agéntico como Windsurf opera en el nivel de Augmentation: vive dentro de tu editor, te sugiere código, te acompaña mientras programas. Es un copiloto sofisticado. Claude Code, en cambio, opera en el nivel de Agency: es un agente impulsado con IA que trabaja autónomamente con tu base de código. No necesita que le dictes cada paso — tú le das contexto, conocimiento y herramientas, y él navega el problema por su cuenta.

Dicho de forma simple: es la diferencia entre tener a alguien mirando tu pantalla sugiriéndote qué escribir, y tener a un ingeniero al que le puedes delegar una tarea completa.

Otro cambio importante fue ampliar el alcance. Con Windsurf, la herramienta era exclusiva para el equipo de desarrollo. Con Claude Code, decidimos que todas las personas ligadas a ingeniería y producto tuvieran acceso — especialmente los product managers. En un mundo donde la IA puede generar código, las personas que definen el qué y el por qué se vuelven tan relevantes como las que definen el cómo. Hoy tenemos cerca de 550 licencias activas entre personas de desarrollo, producto y otros roles de ingeniería.

## Context Engineering: la clave para un buen agente

Para entender por qué el contexto es tan importante, vale la pena entender — en simple — cómo funcionan los modelos de lenguaje que están detrás de herramientas como Claude Code.

Un LLM (Large Language Model, o modelo de lenguaje grande) es un sistema que predice el siguiente token (unidad de texto) en una secuencia. Fue entrenado con enormes cantidades de texto y aprendió patrones del lenguaje, el código, la lógica y el razonamiento. Cuando le haces una pregunta o le das una instrucción, el modelo genera una respuesta token por token, eligiendo en cada paso el más probable dado todo lo anterior.

Ese "todo lo anterior" es lo que llamamos la **ventana de contexto**: el espacio de trabajo del modelo. Es todo lo que puede "ver" en un momento dado para generar su respuesta — tu instrucción, los archivos que leyó, la documentación que le entregaste, el historial de la conversación. Todo lo que está en la ventana de contexto influye directamente en la calidad de la respuesta.

Aquí aparece un problema sutil pero crítico: la **polución de contexto**. Si le entregas al modelo demasiada información irrelevante, no solo desperdicias tokens (que tienen un costo y un límite), sino que diluyes la señal con ruido. El modelo pierde foco y genera respuestas de menor calidad. Piénsalo así: es como intentar concentrarte en una reunión donde hay cinco conversaciones simultáneas que no tienen nada que ver con tu tema.

El **context engineering** (ingeniería de contexto) es el arte de entregar al modelo el contexto justo y necesario — ni más, ni menos. Que cuando la IA vaya a trabajar en una tarea, tenga exactamente la información que necesita: las convenciones del equipo, la arquitectura del módulo, el dominio de negocio relevante, y nada que sobre.

En Buk, esto se tradujo en un trabajo colaborativo en tres frentes:

- **Documentación optimizada**: comenzamos a mejorar nuestra documentación pensando no solo en las personas sino también en la IA. La cantidad de commits de documentación creció significativamente durante este período: de un promedio trimestral de 51 commits de documentación entre Enero y Marzo de 2025 a 125 commits promedio entre Enero y Marzo de 2026 — evidencia de que el equipo entendió que documentar bien es darle mejor contexto al agente.
- **CLAUDE.md**: el archivo central que define las reglas, convenciones y conocimiento que Claude Code necesita para trabajar en nuestra base de código. Es como un proceso de integración comprimido para la IA.
- **Skills** (habilidades): definimos habilidades particulares para nuestro agente — tareas específicas donde tiene todo el conocimiento necesario para ejecutar de principio a fin. En vez de darle instrucciones genéricas, le entregamos procedimientos completos con el contexto preciso para cada tipo de tarea.

La clave está en el equilibrio: suficiente contexto para que la IA tome buenas decisiones, pero no tanto que se ahogue en información irrelevante.

## Lo que viene

La migración a Claude Code y el trabajo en context engineering son los cimientos. Sobre ellos estamos construyendo lo que viene.

### Compound Engineering

Uno de los problemas más comunes al trabajar con IA es la repetición: el agente comete un error, tú lo corriges manualmente, y en la siguiente sesión comete el mismo error porque no aprendió nada. Compound Engineering es nuestra respuesta a eso.

La idea es simple: en vez de arreglar las cosas que la IA hace mal, enseñarle cómo arreglarlas. Cada sesión con el agente debe ser mejor que la anterior. Lo estructuramos como un ciclo de cuatro pasos:

- **Plan**: planificar la tarea en detalle antes de delegar.
- **Delegate**: dejar que el agente haga el trabajo.
- **Assess**: verificar que funciona — con tests, revisión, validación.
- **Codify**: registrar lo aprendido en la configuración del agente (CLAUDE.md, skills, documentación) para que no se repitan los errores.

El paso clave es Codify. Es lo que transforma una corrección puntual en un aprendizaje permanente. Con el tiempo, el agente se vuelve más capaz porque acumula conocimiento sesión tras sesión — y todo el equipo se beneficia de ello.

### Harness Engineering

Compound Engineering mejora al agente en cada interacción. Harness Engineering va un paso más allá: se trata de armar un ecosistema completo de herramientas y ciclos de retroalimentación para que la IA pueda operar sin intervención humana.

Esto significa darle al agente acceso a la misma información que tenemos nosotros — métricas, registros, trazas, resultados de tests — para que pueda evaluar su propio trabajo y corregir el rumbo. En vez de que una persona le diga "esto está mal, arréglalo", el agente puede detectar el problema por sí mismo a través de la retroalimentación de las herramientas.

### Agentes autónomos

La visión final es tener agentes que sepan trabajar como nosotros por su propia cuenta. Que se puedan comunicar entre ellos si lo necesitan. Que usen las herramientas y el conocimiento que les hemos entregado. No como reemplazo de las personas, sino como una extensión del equipo que potencia nuestra capacidad de entrega.

El futuro del desarrollo de software es uno donde las personas diseñan — en colaboración con el agente —, el agente escribe el código, y las personas revisan y aprueban. Y en Buk, estamos avanzando hacia allá.
