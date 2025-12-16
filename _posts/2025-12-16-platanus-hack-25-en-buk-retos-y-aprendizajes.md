---
layout: post
title: "Platanus Hack 25 en Buk: Retos y Aprendizajes del Equipo"
subtitle: "El fin de semana del 21 al 23 de noviembre, las oficinas de Buk se convirtieron en el laboratorio de desarrollo más intenso de LATAM."
author: ["José Carrasco", "Lucas Palacios"]
tags:
- platanus-hack
- hackathon
- innovacion
- cultura
- aprendizajes
images_path: "/assets/images/2025-12-16-platanus-hack-25-en-buk-retos-y-aprendizajes"
image: "/assets/images/2025-12-16-platanus-hack-25-en-buk-retos-y-aprendizajes/img-metadata.png"
background: "/assets/images/2025-12-16-platanus-hack-25-en-buk-retos-y-aprendizajes/background.png"
date: 2025-12-16 11:20 -0300

---

Del 21 al 23 de noviembre, las oficinas de Buk en Santiago se transformaron en el epicentro de la Platanus Hack 25. Durante 36 horas de creación continua, más de 200 devs de toda LATAM se reunieron para colaborar con equipos externos y llevar ideas al siguiente nivel. En este post resumimos las vivencias de los participantes: qué nos motivó, qué retos aparecieron y qué aprendizajes nos llevamos al cerrar el fin de semana.

Más allá de la adrenalina de un hackathon, la Hack 25 nos recordó la importancia de construir en comunidad. Las experiencias compartidas muestran cómo cada desafío técnico se convirtió en una oportunidad para crecer, cómo la colaboración rompió silos y cómo la creatividad se mantuvo encendida incluso cuando los relojes marcaban la madrugada.

Varios "Bukers" aceptaron el desafío de participar, mezclando el talento externo y viviendo la experiencia en carne propia. Hoy queremos compartir, sin filtros, lo que ocurre cuando juntas café, código y una fecha límite inamovible. Aquí están los retos técnicos y los aprendizajes reales que nos dejó el fin de semana.

![Foto de los participantes de la Platanus Hack 25 en Buk]({{ page.images_path }}/foto-de-los-participantes.jpeg)

## Preparativos y Expectativas

Los equipos se conformaron por una mezcla de roles y especialidades, incluyendo perfiles de Backend, Frontend, AI, DevOps, Pitch, Presentación y Management Analyst. Esta variedad de enfoques para la creación de productos resultó ser muy valiosa.

La expectativa general antes del evento era muy alta. La oportunidad de formar parte de un evento organizado por referentes tecnológicos como Platanus y Buk, junto a sponsors de alto nivel (como Buda, Fintoc, entre otros), se sintió como un privilegio. A pesar de la alta competitividad y experiencia de los participantes, esto sirvió como una gran motivación para que cada integrante buscara su mejor nivel.

Como preparativos previos, los equipos se reunieron con antelación para analizar proyectos finalistas de ediciones anteriores, discutir posibles tracks y evaluar las fortalezas y debilidades individuales para definir una distribución de roles óptima. Además, se discutieron los stacks tecnológicos a utilizar.

![Participantes de la Platanus Hack 25 trabajando y conversando]({{ page.images_path }}/participantes-trabajando-y-conversando.jpeg)

## Desafíos durante el Evento

### Retos Principales

El mayor problema compartido fue la dificultad para **encontrar un proyecto llamativo, que generará impacto y que fuera plasmable en un producto funcional en tan solo 36 horas**. Los temas se diseñaron a propósito para ser ambiguos o abiertos, forzando a buscar soluciones ambiciosas y diferentes. La estrategia clave fue **invertir tiempo en la planificación, discusión y alineación del equipo antes de empezar a codificar**. Esto hizo mucho más expedito el desarrollo posterior.

Un desafío crítico que afectó a un equipo fue el **cuestionamiento de un juez sobre el cumplimiento de la idea con el tema del track**, incluso cuando ya contaban con una primera versión funcional. Esto obligó a una reevaluación inmediata, resultando en una decisión intermedia: mantener el trabajo inicial como un extra y desarrollar una nueva funcionalidad central que se ajustara a las exigencias temáticas del track.

Otro reto fue la **gestión de código en un ambiente de alta velocidad y con integrantes con diferente experiencia en git**. Para reducir interferencias, se optó por dividir el trabajo de manera eficiente. Además, se implementaron hooks pre-push para forzar el uso de linters y formatters, aunque la conciliación de ramas y la resolución de conflictos fueron una lucha constante durante el desarrollo.

![Felipe Sateler hablando con un equipo]({{ page.images_path }}/felipe-sateler-hablando-con-un-equipo.jpeg)

A continuación se resumen los principales desafíos identificados:

- **Idea del Proyecto**:
  - **Descripción del Problema**: Encontrar una idea llamativa, impactante y factible en 36 horas bajo temáticas ambiguas.
  - **Solución o Enfoque**: Invertir tiempo en la planificación, discusión y alineación del equipo antes de codificar.

- **Cumplimiento de Track**:
  - **Descripción del Problema**: Un proyecto funcional fue cuestionado por un juez por no cumplir con las exigencias temáticas.
  - **Solución o Enfoque**: Pivotar parcialmente, manteniendo el trabajo inicial como extra y desarrollando una nueva funcionalidad central.

- **Colaboración y Git**:
  - **Descripción del Problema**: Manejo de conflictos y la inexperiencia de algunos miembros del equipo en flujos de trabajo rápidos con git.
  - **Solución o Enfoque**: Dividir el trabajo para reducir interferencias e implementar hooks pre-push para asegurar la calidad y consistencia del código.

### Herramientas y Metodologías

Los equipos utilizaron una variedad de herramientas y metodologías:

- **Stacks tecnológicos**: Se utilizó una combinación de React, NextJS, FastAPI y Convex. Las bases de datos incluyeron Postgres.

- **Servicios y Librerías**: Se implementaron servicios en AWS y Vercel para el deploy. Para funcionalidades de IA, se recurrió a la API de ElevenLabs (Text-to-Speech y Speech-to-Text), GPT5 y Claude 3.5 Haiku vía API, embeddings de OpenAI, y librerías como Langgraph, Langchain y Playwright.

- **Metodologías**: Aunque se intentó usar Kanban, en la práctica el desarrollo tendió a ser más libre y enfocado en la división eficiente de tareas para evitar interferencias.

## Aprendizajes y Resultados

### Lecciones Clave

- **Menos es más y la planificación es crucial**: La idea no tiene que ser la más compleja técnicamente, sino la más clara, bien pensada y ejecutada. El trabajo previo de discutir, cuestionar y alinear la idea aseguró que el producto final fuera simple, útil y fácil de comunicar, una enorme ventaja en un formato acotado como un hackathon.

- **La planificación de la infraestructura es crítica (no basta con el local)**: Nunca hay que confiarse del tiempo restante. Problemas inesperados de infraestructura (ej: límites de tamaño para binarios en Vercel, o la inviabilidad de polling en entornos de producción) consumieron toda la holgura de tiempo prevista. Un aprendizaje clave fue que es esencial evaluar la factibilidad técnica del despliegue desde el inicio.

- **Uso responsable y estandarizado de la Inteligencia Artificial (IA)**: El uso intenso de IA para programar (vibecoding) resultó ser contraproducente si no se estandariza. Las diferentes convenciones, reglas y estilos generados por distintos agentes de IA dificultaron la revisión y el trabajo en conjunto. El aprendizaje clave es estandarizar el uso de los agentes de IA, configurándose con el mismo conjunto de reglas y compartiendo prompts y lineamientos para mantener coherencia, estilo y estructura en el código generado.

### Resultados Presentados

Los equipos presentaron proyectos funcionales que demostraron el potencial de la IA y la automatización. Algunas propuestas fueron:

- **Mejora del habla y habilidades de oratoria**: Una PWA (Progressive Web App) que utilizaba IA para ofrecer ejercicios interactivos, análisis en tiempo real (pronunciación, ritmo, vocabulario) y una funcionalidad de depuración de discurso para limpiar muletillas y disfluencias.

- **Optimización de listas de compra**: Una aplicación web inteligente que transformaba lenguaje natural en listas de compra optimizadas mediante una arquitectura multiagente con RAG. Buscaba y comparaba precios entre supermercados para generar una lista final costo-eficiente, con la capacidad de automatizar el flujo de compra.

## Conclusión

La experiencia de la hackathon fue sin duda única e irrepetible. Queremos agradecer profundamente a Platanus por crear este tipo de instancias, a Buk por disponer de las oficinas y organización, y a los demás sponsors que hicieron posible un evento de esta magnitud.

Este tipo de actividades ponen a la región como referente a nivel tecnológico, además de que demuestran que hay talento y potencial para construir y pensar en grande. La adrenalina de trabajar intensamente, el compartir e intercambiar ideas con gente muy capaz, y el tener una instancia única para dejar volar la imaginación sin miedo a equivocarse, hicieron que el evento valiera totalmente la pena.

Los equipos quedaron motivados para seguir desarrollando sus prototipos. Ya se están planificando nuevas features, mejoras y la liberación de los mismos al público para obtener feedback y seguir iterando en una mejora continua. El objetivo es convertir estas visiones en algo concreto que aporte valor real, creyendo que la combinación de IA, automatización y datos actualizados tiene el potencial de transformar experiencias cotidianas.

Invitamos a desarrolladores y también a quienes aportan desde otras disciplinas a sumarse a experiencias como esta. Los hackathons son espacios únicos para aprender, experimentar, equivocarse rápido y construir cosas que quizá nunca se habrían atrevido a intentar solos. Si se les presenta alguna oportunidad así, tómenla, no se van a arrepentir. Asimismo, animamos a las empresas a seguir el ejemplo de Platanus y Buk, impulsando iniciativas que fomenten la colaboración, la innovación y el crecimiento profesional.
