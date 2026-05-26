---
layout: post
title: 'Ingeniería de Buk en Brasil: Evolucionando la Arquitectura y Saldando Deuda Técnica'
subtitle: Un recorrido por las innovaciones técnicas y herramientas implementadas para escalar nuestra operación en Brasil.
author: suntea43
tags: buk, brasil, ruby-on-rails, i18n, event-bus, esocial, security, architecture
image: "/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/img-metadata.jpg"
background: "/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/background.jpg"
date: 2026-05-25 18:30 -0500
---

Desde que el equipo de Brasil comenzó a liderar el desarrollo de nuevas características para este mercado, nos enfrentamos a un reto doble: avanzar rápidamente con las necesidades locales (como el complejo ecosistema de eSocial) y, al mismo tiempo, asegurar que nuestra arquitectura fuera escalable, mantenible y libre de deuda técnica.

En este artículo, quiero profundizar en las herramientas e iniciativas de ingeniería que hemos sumado a Buk para potenciar nuestra operación en Brasil, promoviendo estándares que otros equipos también están adoptando.

## 1. Inclusión "absoluta" de I18n: Multiidioma por usuario

Históricamente, muchas aplicaciones manejan el idioma a nivel de cuenta o de instancia. Sin embargo, para una operación global como la nuestra, necesitábamos mayor granularidad. Gracias a un esfuerzo coordinado, donde el equipo de **Expansión Brasil** apoyó activamente en la inclusión de traducciones en toda la aplicación y el equipo de **Plataforma** proveyó la arquitectura necesaria, implementamos un soporte de I18n (*Internationalization* o internacionalización) "absoluto", permitiendo que cada usuario elija su idioma de preferencia de forma independiente.

![Ilustración de internacionalización y traducción dinámica en Buk](/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/i18n-translatable.jpg)

Esta ardua tarea no solo implicó traducir llaves de texto, sino asegurar que el contexto del usuario se mantuviera a través de *background jobs* (tareas en segundo plano) y comunicaciones por correo. Para facilitar este proceso y asegurar la calidad del código, personalizamos un *cop* (regla de análisis estático) llamado `DecorateString`, diseñado para detectar automáticamente textos *hardcodeados* (escritos directamente en el código) y promover el uso sistemático de llaves de traducción.

En cuanto a la gestión de los archivos de traducción, nuestra estrategia ha evolucionado notablemente. Inicialmente, el equipo de **Traducción**, integrado por **Carolina Grignani** y **Lorena López**, centralizaba los contenidos utilizando **Phrase**. Posteriormente, el equipo de **UX Writing** asumió la responsabilidad de las traducciones y los textos en la aplicación, migrando la operación a **Crowdin** para permitir una integración continua entre el diseño, la redacción y el desarrollo.

Sin embargo, este avance dio pie a un nuevo reto técnico: la necesidad de traducir registros dinámicos de la base de datos (como nombres de cargos o departamentos) y no solo llaves estáticas. Para resolver esto, el equipo de **Plataforma** desarrolló un nuevo **Building Block** (bloque de construcción) llamado **Translatable**. Esta herramienta permite que cualquier modelo de la aplicación sea traducible de forma nativa, asegurando que el contenido generado por el usuario también respete el idioma preferido de quien lo visualiza.

Para quienes deseen profundizar en cómo escalamos esta solución, pueden ver un resumen detallado en la charla de **Mayra Navarro** en el [Tropical.rb 2024](https://www.youtube.com/watch?v=ULTdp9YtNww&list=PLvOWTr3oa1dVFAtodH31zjwdue2QH7wdd&index=7).

## 2. EventBus: Desacoplando la lógica de negocio

A medida que Buk crece, el acoplamiento entre servicios puede convertirse en un cuello de botella. Bajo la visión de **Alexis Aguirre**, quien planteó que los servicios no deberían llamarse directamente entre sí para evitar dependencias rígidas, se propuso la implementación del [patrón de Event Bus](https://medium.com/elixirlabs/event-bus-implementation-s-d2854a9fafd5) (bus de eventos) como la solución ideal para desacoplar nuestra arquitectura.

Esta necesidad se volvió crítica durante nuestra operación en Brasil. Nos enfrentamos a múltiples flujos donde la creación o edición de un registro (como un empleado) debía disparar notificaciones o reportar novedades a otros módulos. Comprendimos que el lugar adecuado para esta lógica no era el servicio encargado de la creación del registro, sino que debía existir un mecanismo que notificara a la aplicación sobre la ocurrencia de esta novedad.

![Diagrama de funcionamiento del Event Bus en Buk](/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/event-bus-diagram.png)

Ahora, en lugar de realizar llamadas imperativas y acopladas entre servicios, nuestra arquitectura permite notificar la ocurrencia de estas novedades para que otros módulos reaccionen de forma independiente. Esto facilita que nuevos servicios puedan "colgarse" de flujos existentes para sumar lógica sin necesidad de modificar el código de los servicios emisores originales. Este cambio ha reducido drásticamente la complejidad de nuestros flujos, permitiéndonos expandir la lógica de negocio de forma limpia, modular, asíncrona y, sobre todo, escalable.

## 3. Fiji: Potencia visual para eSocial

Gestionar los eventos de eSocial en Brasil es una tarea técnica monumental debido a la cantidad de datos y estados que cada evento puede tener. Para mejorar la observabilidad (*observability*) de este proceso, integramos **Fiji**, un *framework* (marco de trabajo) interno diseñado específicamente para la creación de tablas robustas y visualización de datos complejos.

![Dashboard de Fiji para visualización de eventos eSocial en Buk](/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/fiji-esocial.png)

Gracias a Fiji, nuestro equipo de ingeniería puede enfocarse exclusivamente en la lógica de negocio. Los retos técnicos asociados a la creación de vistas, el filtrado avanzado, la inclusión de acciones y el cumplimiento estricto de los lineamientos de nuestro *design system* (sistema de diseño) ya vienen resueltos por defecto al acoplarnos a este marco.

El impacto ha sido transformador: estimamos que el desarrollo de nuevas interfaces es hasta **10 veces más rápido** gracias a las capacidades nativas de la herramienta. Con Fiji, el equipo de soporte e ingeniería puede visualizar el ciclo de vida completo de un evento de eSocial de forma intuitiva, permitiendo diagnosticar errores de forma mucho más rápida que con las vistas estándar y convirtiéndose en el estándar de oro para nuestras operaciones de cumplimiento.

## 4. Building Block de Comprobantes: Más allá de la nómina

La necesidad de entregar comprobantes digitales no se limita a la nómina mensual. En Brasil, es crítico gestionar comprobantes de:

* Adelanto de vacaciones (*adiantamento de férias*)
* Decimotercer salario (*13° salário*)
* Finiquitos (*rescisões*)

Y tenemos en mente seguir extendiendo el soporte a más tipos de comprobantes a medida que el mercado brasileño lo requiera.

![Comprobantes de pago gestionados por el Building Block de Buk](/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/payment-stubs.png)

Para resolver esto de forma escalable, nos apoyamos en el **Building Block** de comprobantes desarrollado y gestionado por el equipo de **Cálculos**. Gracias a la arquitectura de extensiones de esta herramienta, pudimos extender el comportamiento nativo de nuestra nómina a estos otros tipos de pagos.

Este esfuerzo de colaboración nos ha permitido estandarizar la definición de los comprobantes de pago y sus conceptos asociados bajo un mismo motor genérico. De esta forma, garantizamos la consistencia técnica y visual en el almacenamiento y visualización para el empleado, logrando incluir estos nuevos procesos en tiempo récord.

## 5. Manejo de encrypted_credentials: Seguridad nativa e implícita

Siguiendo la línea de lo expuesto en un [artículo anterior]({% post_url 2025-04-05-migracion-paso-a-paso-de-attr-encrypted-al-cifrado-nativo-de-rails-7 %}) sobre la migración al cifrado nativo de Rails 7, hemos adoptado el uso de `encrypted_credentials` (credenciales cifradas) para el manejo de información sensible.

![Manejo seguro de credenciales cifradas con Rails en Buk](/assets/images/2026-05-25-ingenieria-buk-brasil-evolucionando-arquitectura/encrypted-credentials.png)

En este caso, el cifrado nativo es implícito a la herramienta provista por el equipo de **Plataforma**. Nosotros simplemente nos acoplamos a esta lógica para el guardado de los certificados digitales de las empresas. Estos certificados son la "llave" de acceso a los servidores gubernamentales de eSocial y, al estar integrados con la seguridad nativa de Rails, aseguramos que la información esté protegida mediante variables de entorno y llaves de cifrado robustas, garantizando que los datos nunca queden expuestos en logs o bases de datos sin la debida protección.

## Conclusión

La operación de Buk en Brasil ha sido mucho más que un desafío de localización de producto; ha sido un catalizador para elevar nuestra excelencia en ingeniería. Al integrar de forma transversal herramientas como el EventBus, el framework Fiji y los Building Blocks de plataforma, no solo estamos cumpliendo con las regulaciones de un mercado complejo, sino que estamos construyendo un sistema verdaderamente escalable y desacoplado.

Esta evolución técnica es lo que nos permite pasar de una aplicación que simplemente "funciona" a una plataforma robusta y escalable. Lo más valioso de este proceso ha sido alcanzar un estado de sinergia, o lo que llamamos entrar en "flow", donde todos los equipos avanzamos en una misma dirección. Esto no solo hace que los cambios sean escalables, sino que nos permite avanzar a una velocidad excepcional.

En el equipo de Brasil, seguimos comprometidos con saldar deuda técnica y promover iniciativas que fortalezcan el core de ingeniería de todo Buk. Esperamos que esta experiencia les pueda servir a otros equipos de desarrollo para seguir construyendo soluciones de clase mundial. Más allá de lo que estas iniciativas aportan internamente, esperamos también inspirar a los lectores a construir herramientas con una visión más amplia: no solo para resolver un problema puntual, sino para diseñar soluciones que puedan reutilizarse y crecer con el tiempo.
