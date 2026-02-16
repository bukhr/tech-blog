---
layout: post
title: "AG-UI en Ruby: la gema ag‑ui‑protocol"
subtitle: "Cómo pasamos de integraciones ad-hoc a un protocolo de eventos, y por qué lo liberamos como SDK open source para Ruby."
author: aboneto
tags:
- ai
- agents
- ruby
- rails
- open-source
- ag-ui
date: 2026-02-16 09:00 -0300
images_path: "/assets/images/2026-02-16-ag-ui-en-ruby-la-gema-ag-ui-protocol"
image: "/assets/images/2026-02-16-ag-ui-en-ruby-la-gema-ag-ui-protocol/img-metadata.png"
background: "/assets/images/2026-02-16-ag-ui-en-ruby-la-gema-ag-ui-protocol/background.png"
---

En Buk veníamos construyendo experiencias conversacionales con agentes, pero con una realidad típica en equipos que se mueven rápido: gran parte de la comunicación entre agente y frontend terminaba quedando como acuerdos “de facto” (eventos armados a mano, payloads que cambian, edge cases (casos borde) que se descubren tarde).

Para resolverlo, decidimos adoptar el [protocolo AG-UI](https://docs.ag-ui.com/introduction), que estandariza la comunicación *agent-to-UI* usando un modelo orientado a eventos.

Y como nuestro stack principal es Ruby on Rails y aún no existía un SDK Ruby oficial, aportamos a la comunidad creando la gema [ag-ui-protocol](https://rubygems.org/gems/ag-ui-protocol): un SDK Ruby para implementar servidores de agentes compatibles con AG-UI.

## El problema: integraciones que no escalaban

La solución anterior (más artesanal) nos dejaba varios costos ocultos:

- **Falta de estandarización**: No había un protocolo claro para describir el ciclo de vida de una ejecución, mensajes, herramientas, estados, etc.

- **Baja extensibilidad**: Conectar un nuevo chat o una nueva UI a un agente nuevo implicaba volver a negociar formatos, validar supuestos y reescribir adaptadores.

- **Escalabilidad limitada**: El camino para incorporar funcionalidades futuras como *human-in-the-loop*, UIs enriquecidas o herramientas del lado del cliente no estaba claramente definido.

- **Alto time-to-market (TTM)**: Cada ajuste importante implicaba tocar varias capas y crear lógica específica para cada caso.

El punto no era “hacerlo más elegante”, sino reducir fricción y riesgo: si queríamos iterar rápido en agentes, necesitábamos una interfaz estable y predecible.

## Qué es AG-UI (y por qué nos hizo sentido)

[AG-UI](https://docs.ag-ui.com/introduction) es un protocolo diseñado para ser liviano y mínimamente prescriptivo. Su idea base es simple: durante una ejecución, el agente emite eventos estandarizados (16 tipos core) que el cliente puede procesar para construir una experiencia en tiempo real.

Dos características del protocolo fueron clave para nosotros:

- **Comunicación orientada a eventos (streaming)**: En vez de “una respuesta final”, el agente va emitiendo eventos que representan avance, mensajes parciales, tool calls (llamadas a herramientas), cambios de estado, etc.

- **Independiente del transporte**: El protocolo no impone un mecanismo único. Puedes transportar eventos por Server-Sent Events (SSE), WebSockets, webhooks, o lo que se ajuste mejor a tu arquitectura.

Además, AG-UI propone una capa “compatibility-first (compatibilidad primero)”: los eventos no tienen que ser idénticos al formato exacto de referencia, sino compatibles. Eso facilita adoptar AG-UI encima de agentes existentes, sin reescribir todo.

### Arquitectura

AG-UI sigue una arquitectura cliente-servidor que estandariza la comunicación entre agentes y aplicaciones:

![Arquitectura de AG-UI]({{ page.images_path }}/ag-ui-architecture.png)

- Application: Aplicaciones orientadas al usuario (es decir, chat o cualquier aplicación habilitada con IA).
- AG-UI Client: Clientes de comunicación genéricos como HttpAgent o clientes especializados para conectar a protocolos existentes.
- Agents: Agentes de IA de backend que procesan solicitudes y generan respuestas de streaming.
- Secure Proxy: Servicios de backend que proporcionan capacidades adicionales y actúan como un proxy seguro.

### Tipos de eventos

![Tipos de eventos en AG-UI]({{ page.images_path }}/event-streaming.png)

AG-UI agrupa eventos en categorías (con documentación pública):

- [Lifecycle Events](https://docs.ag-ui.com/concepts/events#lifecycle-events): Monitoriza la progresión de las ejecuciones del agente (agent runs).
- [Text Message Events](https://docs.ag-ui.com/concepts/events#text-message-events): Gestiona el contenido textual transmitido por streaming.
- [Tool Call Events](https://docs.ag-ui.com/concepts/events#tool-call-events): Administra las ejecuciones de herramientas (tool executions) realizadas por los agentes.
- [State Management Events](https://docs.ag-ui.com/concepts/events#state-management-events): Sincroniza el estado entre los agentes y la interfaz de usuario (UI).
- [Activity Events](https://docs.ag-ui.com/concepts/events#activity-events): Representa el progreso de la actividad en curso.
- [Special Events](https://docs.ag-ui.com/concepts/events#special-events): Soporte para funcionalidades personalizadas o especiales.

Si quieres profundizar, este es un buen punto de partida: [Events en AG-UI](https://docs.ag-ui.com/concepts/events).

## Nuestra decisión: alinearnos con un estándar

Adoptar AG-UI fue una decisión práctica y estratégica para Buk:

- **Bajo time-to-market (TTM)**: En vez de inventar un “protocolo Buk” desde cero, partimos de un estándar ya definido.

- **Alineado con el mercado**: AG-UI está creciendo en adopción y tiene integraciones con proyectos del ecosistema (por ejemplo, [CopilotKit](https://www.copilotkit.ai/)).

- **Baja complejidad de adopción**: La documentación está bien estructurada y el protocolo es directo.

- **Alta capacidad de personalización**: Cuando necesitas algo fuera del core, existen eventos *custom* para extender sin romper el contrato.

- **Compatibilidad futura**: Dado que los proveedores de LLM (y el mercado) empujan el roadmap de funcionalidades, mantener una interfaz estandarizada entre agente y UI nos permite incorporar cambios con menos fricción.

## La gema ag-ui-protocol

[ag-ui-protocol](https://rubygems.org/gems/ag-ui-protocol) es un SDK Ruby para AG-UI que entrega:

- **Estructuras fuertemente tipadas** para eventos y modelos

- **Validación en runtime con Sorbet** para verificar tipos en tiempo de ejecución.

- **Serialización automática a camelCase**, para integrarse de forma natural con frontends

- **Un encoder** pensado para transportar eventos eficientemente (por ejemplo, sobre SSE)

El código vive en el repositorio oficial del protocolo: [ag-ui-protocol/ag-ui (Ruby SDK community)](https://github.com/ag-ui-protocol/ag-ui/tree/main/sdks/community/ruby).

### Módulos principales

La gema se organiza en tres áreas:

- **`AgUiProtocol::Core::Types`**: message types, tools y data models
- **`AgUiProtocol::Core::Events`**: event types y event handling
- **`AgUiProtocol::Encoder`**: utilidades para codificar eventos para streaming HTTP

### Open source y contribución

Esta gema la desarrollé yo, con revisión de Felipe Sateler (nuestro CTO) y del equipo de CopilotKit. Pero lo más importante es que quedó como un aporte abierto: cualquier persona puede usarla, abrir issues o proponer mejoras.

Si te interesa contribuir: [Contributing guide](https://docs.ag-ui.com/development/contributing).

### Cómo se usa (ejemplo rápido)

El patrón es: crear un evento, codificarlo y enviarlo por el canal de streaming que estés usando.

```ruby
require "ag_ui_protocol"

event = AgUiProtocol::Core::Events::TextMessageContentEvent.new(
  message_id: "msg_123",
  delta: "Hello from Ruby!",
)

encoder = AgUiProtocol::Encoder::EventEncoder.new
encoded_event = encoder.encode(event)
```

En un servidor con SSE, ese `encoded_event` es lo que típicamente terminas escribiendo hacia el stream de respuesta.

#### Mensajes multimodales

AG-UI también contempla contenido multimodal. Por ejemplo, un mensaje de usuario que combine texto e imagen:

```ruby
require "ag_ui_protocol/core/types"

message = AgUiProtocol::Core::Types::UserMessage.new(
  id: "user-123",
  content: [
    { type: "text", text: "Please describe this image" },
    { type: "binary", mimeType: "image/png", url: "https://example.com/a.png" },
  ],
)
```

## Conclusión

Publicar `ag-ui-protocol` nos llena de orgullo, ya que fue una forma de resolver un problema real que teníamos en Buk, pero también de aportar a la comunidad algo que creemos que será cada vez más común en el desarrollo de *agentic apps* (aplicaciones con agentes): **estandarizar la conversación entre agentes y UIs mediante eventos**.

Queremos agradecer el apoyo y gestión del equipo de [CopilotKit](https://www.copilotkit.ai/) ([Nathan Tarbert](https://github.com/NathanTarbert) y [Jordan Ritter](https://github.com/jpr5)), que revisó nuestro [Pull Request](https://github.com/ag-ui-protocol/ag-ui/pull/865) de la gema y aceptó nuestra contribución a la comunidad. Esperamos seguir colaborando con ellos en el futuro y traerles nuevas contribuciones al funcionamiento del protocolo en Ruby.

También queremos agradecer a nuestro equipo de producto, y en especial a nuestra Product Manager ([Sara Calle](https://www.linkedin.com/in/sara-calle/)), por impulsar esta iniciativa y por confiar en el valor de ag-ui-protocol para Buk y la comunidad. Su apoyo fue clave para poder desarrollarla como parte de nuestro trabajo.

Si estás construyendo agentes en Ruby esperamos que encuentres útil esta gema y que puedas contribuir a su desarrollo. Si quieres conversar sobre casos de uso, mejoras o integraciones, el [repositorio](https://github.com/ag-ui-protocol/ag-ui/tree/main/sdks/community/ruby) está abierto.
