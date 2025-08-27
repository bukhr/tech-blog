---
layout: post
title: 'Optimización de Pipelines: Utilizando caché de Docker para reducir tiempos
  de build'
subtitle: Estrategias para reducir tiempos de build usando caché compartido entre
  ramas
image: "/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master/img-metadata.png"
author: dvargas
tags:
- docker
- ci/cd
- optimización
- caché
- jenkins
- devex
date: 2025-08-25 09:54 -0300
images_path: "/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master"
background: "/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master/background.png"
---
## Optimización de builds de Docker en Pull Request

Actualmente, los builds en los pipelines de CI/CD pueden tomar tiempos considerables en el peor escenario cuando no se aprovecha el caché existente. En los mejores casos, utilizando caché de assets, este tiempo puede reducirse hasta en un **92 %**, o en promedio un **63 % de mejora** si solo se aprovecha para el resto de capas sin considerar los assets (que constituye el proceso más lento en un build).

Sin embargo, estos casos óptimos son escasos debido a que los PR suelen partir de un estado de master que luego sigue avanzando, haciendo que el caché de assets rara vez coincida perfectamente.

Es una de las principales oportunidades que encontramos en DevEx para mejorar los tiempos de nuestros pipelines, y en el proceso de build mismo, se puede observar en el siguiente gráfico, cómo es que se reparten los tiempos:

![img](/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master/tiempos-build.png)

Debido a esto, se decidió implementar una estrategia que permitiera aprovechar el caché existente en master para optimizar los tiempos de build. Sin embargo, inicialmente se tomó la oportunidad de aprovechar el caché de la mayoría de capas, y dejar los assets como una oportunidad aparte, ya que si bien su tiempo es de gran impacto, en comparativa la suma de todas las demás terminó impactando más en el tiempo, como evidencia el resultado de esta misión.

## La misión: Optimizar el proceso de build

La misión consistió en diseñar una estrategia que permitiera:

1. Que tanto `build-image` como `build-image-test` aprovecharan eficientemente el caché generado por master.
2. Optimizar la sincronización de assets, limitándola a las ramas que realmente lo necesitan.
3. Reducir el tamaño de la imagen final eliminando elementos innecesarios como la carpeta `.git`. Esto generó una reducción significativa en el tamaño de la imagen de docker, lo que optimiza el tiempo de push y pull a ECR en AWS.

## Solución implementada

![img](/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master/proceso-build.png)

### 1. Compartir caché entre master y ramas de desarrollo

La primera parte de la solución implementada consistió en modificar el proceso de `build-image` para que utilizara el caché generado en la rama master. Esto optimizó las capas del build, especialmente en los pasos:

```dockerfile
# =====================
# 2. CACHE IMAGE
# =====================
FROM ${BASE_IMAGE} AS cache
WORKDIR ${WORKDIR}$
COPY --from=builder --chown=user:user ${WORKDIR}$/vendor/bundle vendor/bundle
COPY --from=builder --chown=user:user ${WORKDIR}$/node_modules node_modules
COPY --from=builder --chown=user:user ${WORKDIR}$/public/packs-test public/packs-test
COPY --from=builder --chown=user:user ${WORKDIR}$/public/assets public/assets
COPY --from=builder --chown=user:user ${WORKDIR}$/tmp tmp

# =====================
# 3. RUNNER IMAGE
# =====================
FROM ${BASE_IMAGE} AS runner
ARG RAILS_ENV
ARG BUNDLE_GEMFILE=Gemfile
ARG BUNDLE_GEMFILE_LOCK=Gemfile.lock
ENV RAILS_ENV=$RAILS_ENV BUNDLE_GEMFILE=${BUNDLE_GEMFILE} BUNDLE_APP_CONFIG=/usr/local/bundle GEM_HOME=/usr/local/bundle BUNDLE_PATH="./vendor/bundle"
WORKDIR ${WORKDIR}$
COPY --from=builder ${WORKDIR}$ .
COPY --from=builder /usr/local/bundle /usr/local/bundle
```

Este cambio por sí solo redujo los tiempos de build en aproximadamente un **63%**, estableciendo una nueva línea base para los tiempos de construcción.

Luego en el Jenkinsfile se implementó el caché de Docker para que el build-image-test y build-image aprovecharan el caché de master.

Se define una variable de entorno con `BASE_CACHED_IMAGE` que se utiliza en el build-image-test y build-image para aprovechar el caché de master.

```sh
stage("build-image") {
    agent {
        ...
    }
    environment {
        ..
        BASE_CACHED_IMAGE = "${AWS_ECR_REPOSITORY}:cache-master-test-${IMAGE_VERSION}"
        ...
    }
    steps {
        ...
        buildBukProdImage()
        ...
    }
}
```

```sh
void buildBukProdImage(String DOCKERFILE="Dockerfile", tagSuffix = null) {
    ...
      docker.build("$BUK_PROD_IMAGE", "
      --target builder 
      --build-arg BASE_CACHED_IMAGE 
      --build-arg RAILS_ENV 
      --build-arg IMAGE_VERSION 
      --build-arg CI_COMMIT_SHA 
      ${dependabotFrozenArg()} .")
    ...
}
```

Esta imagen se genera en los builds de master, y se mantiene actualizada cada 2 horas.

### Oportunidad de mejora: Generar este caché en rangos de tiempo más acotados

```sh
if (env.BRANCH_NAME == "master") {
    // Hacemos build de la imagen cache y la pusheamos al registro.
    docker.build("$BASE_CACHED_IMAGE", "
    --target cache 
    --build-arg RAILS_ENV 
    --build-arg IMAGE_VERSION 
    --build-arg CI_COMMIT_SHA 
    ${dependabotFrozenArg()} .")
    sh "docker push -q $BASE_CACHED_IMAGE"
}
```

Notar `--target cache`, para que se genere la imagen de caché.

### 2. Optimización de sincronización de assets

Se identificó que no todas las ramas necesitan sincronizar sus assets con S3. Por eso se removió esta sincronización del proceso de `build-image` general y se implementó exclusivamente para los stages que corren en master o en producción:

```sh
// Si el branch es master o production, se extrae el public y se sube a S3
if (env.GIT_BRANCH == "master" || env.GIT_BRANCH == "production") {
    sh """
        container=\$(docker create $BUK_PROD_IMAGE)
        docker cp "\$container":$WORKDIR/public .
        aws s3 sync --acl public-read public s3://buk-cdn-assets/public --quiet
    """
}
```

Esto nos ayuda a ganar unos minutos en el build, y además evitar que se suban assets innecesarios.

### 3. Reducción del tamaño de la imagen

Para optimizar el tamaño de la imagen, se eliminó la carpeta `.git` del contenedor final, agregándola en el .dockerignore. Esto requirió especial atención para no interrumpir los procesos que dependen de esta carpeta:

Para las etapas que específicamente requieren la carpeta `.git`, simplemente se pasó como una referencia externa:

```sh
docker.image("$BUK_IMAGE").inside("-v ${WORKSPACE}/.git:${WORKDIR}/.git") {
    sh """cd $WORKDIR
    $COMMAND
    """
}
```

## Resultados obtenidos

La implementación de estas optimizaciones permitió obtener los siguientes resultados:

1. **Tiempo base de build**: Reducción de aproximadamente un **63%** en el caso promedio.
2. **Casos óptimos**: Mantenimiento de la máxima eficiencia (hasta un **92% de reducción** respecto al peor caso) cuando hay coincidencia exacta de assets.
3. **Tamaño de imagen**: Reducción significativa del peso al eliminar la carpeta `.git`.
4. **Transferencia de datos**: Menor uso de ancho de banda al sincronizar assets solo cuando es necesario.

## Casos de éxito documentados

Estos días se ha visto una disminución de los tiempos de caché de manera notable, como se puede ver en el siguiente gráfico:

![img](/assets/images/2025-08-25-optimizacion-de-ci-cd-aprovechando-el-cache-de-docker-build-desde-master/resultados-cache.png)

## Lecciones aprendidas

Al implementar esta solución, se identificaron importantes lecciones sobre optimización de pipelines de CI/CD:

1. **El caché como aliado**: Aprovechar el caché existente entre diferentes flujos de trabajo puede producir mejoras significativas de rendimiento.
2. **Optimizar selectivamente**: No todos los procesos necesitan ejecutarse en todos los contextos; es importante identificar qué operaciones son realmente necesarias en cada etapa.
3. **Peso de la imagen impacta**: En contenedores Docker, cada megabyte cuenta, especialmente en operaciones repetitivas como los builds de CI/CD.

## Conclusión

La optimización de procesos de CI/CD mediante el uso inteligente del caché de Docker build demostró ser una estrategia efectiva para reducir tiempos de espera, aumentar la productividad del equipo y hacer un uso más eficiente de los recursos de infraestructura.

Esta solución mejoró significativamente los tiempos de build, especialmente en proyectos con bases de código grandes donde los tiempos de construcción pueden convertirse en un impedimento para la velocidad de desarrollo.

Aún queda margen de mejora, el caché de assets se reutiliza en todos los PRs, por lo que se puede optimizar aún más. La generación de estos tampoco es óptima aún. Una estrategia bastante interesante puede ser buscar mecanismos para que el procedimiento en su build de assets se haga más eficiente.
