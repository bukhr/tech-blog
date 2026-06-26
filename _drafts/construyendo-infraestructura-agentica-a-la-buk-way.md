---
layout: post
title: "Construyendo infraestructura agéntica a la Buk Way"
subtitle: "Por qué construimos nuestro propio núcleo agéntico sobre Jenkins en lugar de comprar una plataforma, y cómo lo llevamos a más de 300 ejecuciones diarias."
author: rnavarro
tags: [ai, claude, agentes, jenkins, developer-experience, compound-engineering]
images_path: "/assets/images/2026-06-26-construyendo-infraestructura-agentica-a-la-buk-way"
image: "/assets/images/2026-06-26-construyendo-infraestructura-agentica-a-la-buk-way/img-metadata.png"
date: 2026-06-26 09:00 -0300
---

<!--
GUÍA DEL BORRADOR
- Estructura acordada a partir del guion de la charla "Construyendo Infraestructura Agéntica a la Buk Way".
- Cada sección trae un lead-in redactado (tono modelo) + un comentario "CUBRIR:" con el contenido del/los slide(s) a desarrollar + marcadores de imagen 🖼️.
- Convenciones del repo: español, términos técnicos en inglés con traducción en (), `##` para secciones y `###` para sub.
- Antes de publicar: crear _authors/rnavarro.md y reemplazar las imágenes placeholder.
-->

Cuando nació el equipo de DevEx AI, hace poco más de cinco sprints, no empezamos escribiendo código. Empezamos con una pregunta incómoda: *¿dónde estamos y hacia dónde queremos ir?* La respuesta fue igual de incómoda. Nuestro desarrollo IA-driven (impulsado por IA) estaba estancado en *context engineering* (ingeniería de contexto): pasarle información al prompt en el momento justo. Funciona bien con un puñado de repos y un equipo chico. No funciona cuando eres más de 400 desarrolladores trabajando sobre un monolito y decenas de stacks distintos.

Necesitábamos autonomía. Y la necesitábamos a escala, sin amarrarnos a una caja negra de un proveedor. Este post cuenta cómo resolvimos eso: la decisión de construir en vez de comprar, la arquitectura que montamos sobre Jenkins, los problemas que solo aparecen en producción y la evidencia de que funciona.

<!-- CUBRIR (intro, slides 1–3): contexto IADEVS opcional. NO incluir la bio personal de la charla — la cubre el `author`. Anclar la tensión central: autonomía a escala sin vendor lock-in. -->

## El punto de partida: IA estancada en Context Engineering

<!--
CUBRIR (slides 3–4):
- Qué es context engineering y por qué se nos quedó corto a nuestra escala/complejidad.
- El salto conceptual a Compounding Engineering: construir sistemas que aprendan y acumulen conocimiento útil en el tiempo.
- Dejar planteado el "hacia dónde vamos" como motor del resto del post.
🖼️ Diagrama: context engineering vs. compounding engineering (el escalón siguiente).
-->

## Comprar o construir: por qué terminamos en Jenkins

Con el destino claro, fuimos al mercado a buscar quién nos lo resolviera.

<!--
CUBRIR (slides 4, 6):
- Alternativas evaluadas: n8n, OpenAI Agents, OpenHands, AWS AgentCore, Port.io, CrewAI.
- Por qué las descartamos: costo, escala y vendor lock-in.
- El miedo explícito: caja negra de plataforma cerrada = perder control de ejecución, escalabilidad y costo.
- La decisión pragmática (y barata): núcleo agéntico propio.
- Por qué Jenkins: ya orquesta nuestro delivery; fue repensar cómo lo usamos. (Glosar: Jenkins = automatización/orquestación.)
- Anclar el argumento de escala: ~400 devs (605 con Producto); integraciones custom por equipo = mantenimiento inmanejable.
🖼️ Diagrama/tabla: alternativas evaluadas vs. criterios (costo / escala / vendor lock-in).
-->

## La arquitectura: el Agentic Hub

Lo entretenido: qué fue lo que construimos.

### El Hub

<!--
CUBRIR (slides 5, 7):
- Jenkinsfiles como dispatchers (despachadores) de pipelines de agentes, en vez de un orquestador complejo desde cero.
- El contrato: cualquier sistema emite un JSON estándar al Hub vía Jenkins API.
- Ejecución: Docker interactuando con la CLI de Claude (`claude -p`); devuelve el resultado al origen.
- La idea fuerza: la integración se hace una sola vez.
🖼️ Diagrama central del post: flujo high-level sistema → Hub (Jenkins API) → Docker/Claude → resultado.
-->

### Guardrails

Meter agentes autónomos a ejecutar código en una empresa del tamaño de Buk exige seguridad estricta. La dividimos en dos ejes.

<!--
CUBRIR (slide 8):
- Infraestructura: EC2 dedicado en AWS, IAM con permisos mínimos, ECR pull-only, Security Groups que bloquean egress salvo GitHub, Anthropic y el ECR.
- Runtime: sanitización agresiva de logs y artefactos; Claude con `--permission-mode dontAsk` y herramientas estrictamente permitidas.
- Mensaje: aislamiento total.
🖼️ Diagrama: dos ejes de seguridad (infra + runtime).
-->

### CRONes

Sobre esa base segura montamos tareas agénticas programadas, con un flujo transparente para el desarrollador.

<!--
CUBRIR (slide 9):
- Flujo: editas un YAML → abres un PR (human-in-the-loop siempre) → un Job dedicado de Jenkins ("Seeder") actualiza el pipeline → las tareas se ejecutan de forma programada.
🖼️ Diagrama: YAML → PR → Seeder → ejecución programada.
-->

### El ChatBot

Y aquí se conecta todo.

<!--
CUBRIR (slide 10):
- ChatBot filtra el ruido de GitHub y valida firmas HMAC-SHA256.
- Se comunica con el Agentic Hub para levantar a Claude.
- Cerrar anticipando el caso estrella: este es el motor de /request-full-review (lo vemos en detalle más abajo).
-->

## Lo que el papel no te cuenta: problemas en producción

Todo esto suena muy bien en papel. En producción tuvimos problemas reales.

### Muchos repos, muchos stacks

<!--
CUBRIR (slides 11–13):
- El problema: monolito Ruby on Rails + repos en Node, PHP, Python, Groovy, etc. Un agente necesita ejecutar código real (tests, linters). ¿Una sola imagen Docker gigante? Pesadilla.
- La solución de dos vías:
  - Slim (~260MB): Ruby, Python, Node + herramientas globales (ripgrep, jq). Fallback universal.
  - Full: se clona del repo target; trae sus binarios + sidecar de base de datos para correr la suite real.
🖼️ Diagrama: estrategia Slim vs. Full.
-->

### Skills por repositorio

<!--
CUBRIR (slides 14–15):
- Para no acoplar la lógica, sistema de Skills con 3 niveles de prioridad:
  - Nivel 1: skills específicas para ese repo (en el Hub).
  - Nivel 2: skills definidas dentro del propio repo target.
  - Nivel 3: skills genéricas del Hub (fallback).
- Mensaje: descentralizamos el conocimiento del agente.
🖼️ Diagrama: resolución por niveles de prioridad.
-->

### ¿Webhooks o GitHub Actions?

Pregunta obligatoria: ¿por qué Webhooks + Jenkins y no simplemente GitHub Actions?

<!--
CUBRIR (slide 16):
- Economía de escala: para nuestra cantidad de devs, subir al tier superior de la organización en GitHub = costo fijo mensual altísimo.
- Decisión: aprovechar la infra existente y mandar ese presupuesto a lo que sí da valor: pagar llamadas a la API de Claude.
-->

## La evidencia: `/request-full-review` en acción

Volviendo a la integración del ChatBot, este es el resultado real.

<!--
CUBRIR (slides 17–19):
- Se gatilla a demanda en los PRs. El ChatBot acusa recibo, el Hub analiza el código, Claude comenta directo en GitHub.
- Detecta desde problemas críticos de seguridad hasta N+1 queries.
- Deduplicación: no repite comentarios de commits anteriores.
- Cierra los hilos automáticamente si corriges el código.
- Lee documentación interna (CLAUDE.md) para aplicar convenciones del equipo y de cada repo.
🖼️ Captura real: comentario del agente en un PR (ojo: sin secretos ni datos sensibles, según convenciones del repo).
-->

## Hacia dónde vamos: cerrar los Learning Loops

Con la infraestructura funcionando y sirviendo más de 300 ejecuciones por día, seguimos iterando.

<!--
CUBRIR (slides 20–23):
- Consolidar Compounding Engineering.
- El desafío actual: cerrar los Learning Loops (ciclos de aprendizaje) — cómo convertir la interacción humano↔agente (ej.: una corrección en un PR) en aprendizaje registrable y consultable.
- Hoy: formato Zettelcard o lesson-learned (una lección que escala a configuración del repo) para que el agente no repita el error.
- Visión: de automatizar a construir nuestro propio sistema operativo de agentes.
🖼️ Diagrama opcional: el learning loop (interacción → captura → config → mejor próxima ejecución).
-->

## El equipo detrás

<!--
CUBRIR (slides 24–25):
- Presentar al equipo DevEx AI: nosotros somos el human-in-the-loop detrás de toda esta infraestructura agéntica.
- Cierre breve.
🖼️ Foto del equipo (opcional).
-->
