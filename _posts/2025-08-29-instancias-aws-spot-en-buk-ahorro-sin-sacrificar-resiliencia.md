---
layout: post
title: 'Instancias AWS Spot en Buk: ahorro sin sacrificar resiliencia'
subtitle: Cómo usamos instancias AWS Spot en EKS para ahorrar costos manteniendo resiliencia, diversificación de capacidad, autoscaling y manejo de interrupciones.
author: aboneto
tags:
- aws
- spot
- kubernetes
- eks
- cost-optimization
- reliability
- autoscaling
- devops
- costos
image: "/assets/images/2025-08-29-instancias-aws-spot-en-buk-ahorro-sin-sacrificar-resiliencia/img-metadata.jpeg"
background: "/assets/images/2025-08-29-instancias-aws-spot-en-buk-ahorro-sin-sacrificar-resiliencia/background.jpeg"
date: 2025-08-29 12:46 -0400
---
En Buk adoptamos [instancias AWS Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) para cerca del 80% de nuestra infraestructura, incluyendo ambientes productivos. Spot ofrece la misma capacidad que On‑Demand, pero a un precio variable sujeto a disponibilidad; cuando AWS necesita la capacidad, puede recuperar la instancia con un aviso breve.

¿Estamos pagando de más por ejecutar todo en On‑Demand o exponiéndonos de más al usar Spot sin control? ¿Qué decisiones técnicas y operativas tomamos en Buk para que Spot sea una ventaja y no un riesgo?

En [Kubernetes (k8s)](https://kubernetes.io/es/docs/concepts/overview/what-is-kubernetes/) mitigamos los riesgos de Spot con prácticas de orquestación y diseño de aplicaciones. Los escenarios donde conviene y donde no, dependen de la tolerancia a fallas y de los [SLOs](https://sre.google/sre-book/service-level-objectives/): es posible capturar ahorros significativos sin sacrificar resiliencia ni la experiencia de usuario.

## Ventajas de usar AWS Spot

### Ahorro de costos (cost optimization)

- Reducciones relevantes del costo de cómputo frente a On‑Demand.
- Permite escalar más por el mismo presupuesto, acelerando proyectos batch y de data.
- En muchos escenarios el descuento efectivo frente a On‑Demand puede ser significativo (hasta ~90 % según mercado y tipo de instancia).
- Se puede combinar con una base On‑Demand cubierta por Savings Plans/Reserved Instances (planes de ahorro/instancias reservadas) para mantener previsibilidad de costos en la porción crítica.

### Elasticidad y capacidad diversificada

- Grupos con múltiples familias de instancias y zonas de disponibilidad (AZ) ofrecen más opciones al programador (scheduler) de k8s.
- Con políticas como Capacity-Optimized o Price-Capacity-Optimized se privilegia la capacidad disponible para reducir interrupciones.
- La diversificación de tipos/tamaños y AZ reduce la correlación de fallas y mejora la probabilidad de cumplir objetivos de capacidad bajo demanda.

### Buen ajuste con cargas tolerantes a fallas

- Servicios stateless (transacciones completamente independientes y aisladas), workers de colas, ETL/batch e inferencia offline se benefician especialmente.
- Pipelines y tareas idempotentes con checkpoints (por ejemplo, etapas de data processing) toleran bien reintentos y reprogramaciones.

## Desventajas y riesgos

### Interrupciones y variabilidad de capacidad

- AWS puede recuperar la instancia, con aviso de interrupción (interruption notice) de ~2 minutos.
- La disponibilidad depende de la demanda en cada mercado de instancias.

### Cold starts y tiempos de arranque

- En picos de tráfico, el autoscaling puede tardar más si la capacidad Spot está disputada.
- Descargas de imágenes grandes y warm‑up de aplicaciones aumentan el tiempo total hasta readiness si no se optimizan cachés y probes.

### Complejidad operativa

- Requiere mayor orquestación, observabilidad y controles de agotamiento (backoff, retries, idempotencia).
- Demanda disciplina en diseño de shutdown hooks, gestión de colas y timeouts para evitar pérdidas de trabajo.
- La mezcla Spot/On‑Demand y la diversificación deben revisarse periódicamente (FinOps) para balancear costo y SLOs.

### Cuotas y límites de servicio

- Límites de cuenta/región por familia de instancia pueden restringir la capacidad efectiva de Spot.
- Si la diversificación es baja (pocas familias o AZ), aumenta la probabilidad de no obtener capacidad cuando más se necesita.

### Riesgo de costos por fallback

- Una estrategia de fallback mal calibrada puede derivar tráfico inesperadamente a On‑Demand, elevando costos en picos.
- Es clave monitorear el ratio Spot/On‑Demand y alertar cuando se exceden umbrales definidos en el presupuesto.

## ¿Cómo funcionan las instancias AWS Spot y su cobro?

Spot aprovecha capacidad no utilizada de EC2 con un precio variable por tipo de instancia y zona de disponibilidad. No es necesario ofertar manualmente; si se desea, puede fijarse un precio máximo (por defecto, igual al de On‑Demand).

Cuando AWS requiere la capacidad, puede interrumpir una instancia con un aviso aproximado de dos minutos. Ese aviso llega como evento ([EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/what-is-amazon-eventbridge.html)/[CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)) y vía [IMDS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html); en Kubernetes, herramientas como Node Termination Handler permiten drenar el nodo a tiempo para minimizar impacto.

La facturación es por segundo (con mínimo de 60 segundos en Linux) al precio Spot vigente mientras la instancia está ejecutándose. Si la interrupción la inicia AWS, no se factura el tiempo restante desde el evento de recuperación; si la detención o terminación la hace el usuario, se cobra el tiempo efectivamente utilizado.

Además del cómputo, se siguen cobrando servicios asociados como volúmenes EBS, snapshots, transferencia de datos y Elastic IPs, cuyos precios no dependen de la tarifa Spot. Para mejorar la disponibilidad, conviene diversificar pools de capacidad usando múltiples familias y tamaños de instancia en varias AZ, lo que reduce la probabilidad de quedarse sin capacidad.

### Ejemplo de cálculo: Spot vs On‑Demand

Para ilustrar órdenes de magnitud, supongamos:

- Tipo de instancia: `m6i.large` (2 vCPU, 8 GiB) en `us-east-1`.
- Precio On‑Demand (aprox.): USD 0,096/h.
- Precio Spot promedio (descuento ~70 %): USD 0,029/h.
- 10 nodos ejecutándose 24/7 durante 30 días (~720 h/mes).
- Fallback del 10% de horas a On‑Demand por falta de capacidad Spot.

Horas de instancia totales en el mes: 10 nodos × 720 h = 7.200 h.

- Solo On‑Demand: 7.200 h × 0,096 = USD 691,20.
- Mix Spot 90 % + On‑Demand 10 %:
  - Spot: 6.480 h × 0,029 = USD 187,92.
  - On‑Demand: 720 h × 0,096 = USD 69,12.
  - Total mix = USD 257,04.

Resultado: ahorro estimado ≈ 62,8 % frente a solo On‑Demand.

Notas:

- Los precios varían por región, familia y momento. Validar en AWS Pricing antes de decisiones FinOps.
- Este ejemplo no incluye costos de EBS, data transfer ni IPs elásticas, que se cobran aparte.
- Un Savings Plan/RI (planes de ahorro/instancias reservadas) aplicado a la base On‑Demand puede mejorar aún más el costo efectivo.

## ¿Cuándo usar y cuándo evitar?

Spot es ideal para APIs stateless, servicios idempotentes, procesamiento batch y ETL, workers de colas, pipelines de datos o trabajos de render e inferencia offline. Estos escenarios toleran reintentos y reprogramación, y suelen operar con SLIs que admiten pequeñas variaciones durante eventos de interrupción controlada.

En cambio, suele evitarse —o combinarse con un porcentaje de On‑Demand— para bases de datos, colas autogestionadas y componentes stateful (con estado) de baja latencia o con ventanas de mantenimiento estrictas.

## Nuestra estrategia en Buk (Kubernetes sobre Spot)

En Kubernetes configuramos pods y nodos para detectar y manejar interrupciones sin pérdida de información. Partimos con grupos de nodos mixtos, combinando On‑Demand y Spot según la criticidad de cada servicio, y con una diversificación real de familias y tamaños de instancia desplegados en varias zonas de disponibilidad para reducir la correlación de eventos. Esta mezcla nos permite mantener una base estable para componentes sensibles y, al mismo tiempo, capturar el ahorro con cargas tolerantes.

El escalado ocurre en dos capas. A nivel de infraestructura, [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) ajusta la cantidad de nodos cuando hay pods en cola o nodos poco utilizados; a nivel de aplicación, [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) incrementa o reduce réplicas en función de métricas robustas para mantener el rendimiento deseado. Esta combinación ayuda a absorber picos mientras se mantiene el control de costos.

Para el manejo de interrupciones utilizamos [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler), que detecta el aviso y ejecuta un drenado (`kubectl drain`) con período de gracia. En los pods definimos `terminationGracePeriodSeconds` acordes a cierre seguro, configuramos probes de [readiness y liveness](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes), y agregamos hooks de [`preStop`](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/) para concluir trabajos y vaciar buffers. Los jobs y consumidores de colas son idempotentes y pueden reanudar desde checkpoints, minimizando reprocesamientos y pérdida de datos. En servicios HTTP, el `preStop` retira la instancia del balanceador y espera a que finalicen las solicitudes en curso.

En cuanto a colocación, usamos [Taints/Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) y reglas de [Affinity/AntiAffinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) para separar servicios críticos de procesos de background; los componentes stateful y de baja latencia se anclan a On‑Demand o a grupos con mayores garantías. En persistencia evitamos bases de datos sobre Spot y favorecemos servicios administrados, o arquitecturas híbridas cuando corresponde.

## Métricas y operación diaria

La operación diaria se apoya en observabilidad y procesos claros. Seguimos métricas de autoscaling (autoescalado), tasas de interrupción, latencia y errores con [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/) y [Mimir](https://grafana.com/oss/mimir/), organizando dashboards por tipo de carga para detectar patrones. Alertamos por colas de trabajo en crecimiento, errores de reintento inusuales y tiempos de drenado que exceden el período de gracia.

Desde el punto de vista de confiabilidad, definimos SLOs y, cuando aplica, SLAs que incorporan la naturaleza de Spot. Controlamos el [error budget](https://sre.google/sre-book/embracing-risk/#xref_risk-management_unreliability-budgets) para decidir ajustes en la mezcla Spot/On‑Demand y para priorizar mejoras cuando un servicio consume el presupuesto más rápido de lo esperado.

Mantenemos [runbooks](https://docs.aws.amazon.com/es_es/whitepapers/latest/aws-security-incident-response-guide/runbooks.html) para eventos de interrupción y validamos continuamente, en CI/CD, que los chequeos de readiness, los fallbacks y los mecanismos de reintento respondan como se espera. Los ejercicios de publicación incluyen verificaciones de que los hooks de apagado se ejecuten en el tiempo previsto y que los consumidores sean realmente idempotentes.

## Conclusión

Si bien el uso de instancias Spot implica riesgos, estos se mitigan con una estrategia técnica y operativa consistente:

- Mantener una base mínima en On‑Demand para componentes sensibles.
- Diversificar tipos y tamaños de instancia en múltiples zonas de disponibilidad y utilizar políticas Capacity‑Optimized para privilegiar pools con mayor estabilidad.
- Implementar drenado ordenado ante avisos de interrupción con termination hooks y `preStop`, más aplicaciones idempotentes con checkpoints para reanudar trabajo.
- Definir SLOs y gestionar el error budget para decidir la mezcla Spot/On‑Demand.
- Sostener observabilidad y alertas que detecten cambios en tasas de interrupción, colas y tiempos de drenado, junto con límites de costo para controlar desvíos.

Las instancias Spot permiten ahorros sustanciales —en algunos casos, reducciones cercanas al 90 % del costo de cómputo—, a cambio de operar con capacidad variable y posibles interrupciones. En Buk, sobre Kubernetes, se combinan diversificación de capacidad, autoscaling, drenado controlado y prácticas de resiliencia a nivel de pod para mantener estabilidad operando cerca del 80 % en Spot. El balance entre costo y confiabilidad depende de la tolerancia a fallas de cada servicio y de sus SLOs.

## Referencias

- [Instancias Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [EKS y mejores prácticas con Spot](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-spot.html)
- [AWS Node Termination Handler](https://github.com/aws/aws-node-termination-handler)
