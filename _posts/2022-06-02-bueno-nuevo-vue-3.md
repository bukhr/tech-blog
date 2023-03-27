---
layout: post
title: Lo bueno y nuevo en Vue 3
subtitle: El equipo core de Vue ha agregado nuevas funcionalidades junto a mejoras sobre las APIs actuales, por lo que los desarrolladores de Vue 2 se sentirán cómodos con las nuevas sintaxis. Revisemos algunas en este artículo.
author: Jorge Epuñan
date: 2022-06-02 10:00 -0400
tags: [frontend, vue, javascript]
background: "/assets/images/2022-05-28-lo-bueno-nuevo-vue3/portada.jpg"
---

Cuando Evan You anunció el [soft release de Vue 3 para fines del 2021](https://blog.vuejs.org/posts/vue-3-as-the-new-default.html), la comunidad estaba ansiosa por finalmente trabajar con una versión estable de esta popular librería. Personalmente venía trabajando con [Nuxt](https://nuxtjs.org/) 2 esperando la promesa de que Nuxt 3 apenas saliera la versión final de Vue 3, así que ese trimestre final era clave. Con todo en orden finalmente el 7 de febrero de 2022 fue la fecha donde Vue 3 era definido como la versión por defecto en NPM. En este artículo presentaremos las grandes novedades y mejoras de esta esperada nueva versión de Vue JS.

## Performance

La librería minimizada (y comprimida con gzip) pesa alrededor de _11kb_, gracias a un gran trabajo de modularización y soporte solo a browsers modernos. ¡Impresionante!

## API core modularizada

Gracias a esta reescritura por módulos de Vue 3, cada componente permite ser incluído o eliminado si no es utilizado (gracias _tree-shaking_). Por ejemplo si no utilizas una directiva como v-if o un componente como `<transition>` estos no serán incluídos en el bundle final:

```js
// en Vue 2 todo el objeto Vue es importado y utilizado en producción
import Vue from 'vue'

// En Vue 3 solo propiedades importadas son incluídas en el bundle final
import { Transition, vIf } from 'vue'
```

## Web Proxy y reactividad

Este feature ha sido muy esperado por la comunidad y es una gran mejora en la performance. En la versión 2 de Vue JS nos acostumbramos a los _getter_ y _setters_ que iban recorriendo recursivamente  todos los objetos y sus propiedades para transformarlos; ya con [Web Proxies](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy) es nativo y más rápido la respuesta ante cambios en el Virtual DOM.

## Composition API

Otra esperada funcionalidad, [Composition API](https://vuejs.org/guide/extras/composition-api-faq.html) mejora la reutilización de lógica y orden en la organización del código. En Vue 2 se utilizan comúnmente propiedades como `data`, `methods` y `computed` entre otros. En Vue 3 se exponen estas propiedades como funciones, lo que permite flexibilidad a la lógica de componentes y un código más legible. Mira el siguiente ejemplo:

```html
<template>
  <div>
     {{ count }}
    <button @click="increment">+</button> 
  </div> 
</template>
```

```js
function myCount() {
  const count = ref(0)
  function increment () { count.value++ }

  return {
    count,
    increment
  }
}
```

Y lo instanciamos en la nuevo método `setup()`, que es una función que retorna propiedades y funciones al `<template>`:

```js
export default {
  setup () {
    const { count, increment } = myCount()

    return {
      count,
      increment
    }
  }
}
```

## Portals

Básicamente portals proporciona una forma de renderizar hijos en un nodo existente pero fuera de la jerarquía DOM del componente padre. En otras palabras son componentes que renderizan contenido fuera del componente actual. Imagina hidratar una ventana modal de contenido sin tener que enviarle datos como argumentos:

```html
<portal to="modal">
  <p>Lorem ipsum dolor sit amet…</p>
</portal>
```

En otro componente:

```html
<portal-target name="modal">
  // aquí se renderizará <p>Lorem ipsum…</p>
</portal-target>
```

## Ecosistema

Junto con el lanzamiento de esta versión, el ecosistema ha evolucionado con muchas nuevas librerías:

- [Vite](https://vitejs.dev/) como nueva librería de _tooling_.
- Nuevo store management mediante [Pinia](https://pinia.vuejs.org/).
- Soporte nativo de [Typescript](https://vuejs.org/guide/typescript/overview.html).
- Single-file-components en tu IDE con [Volar](https://marketplace.visualstudio.com/items?itemName=vue.volar).
- Type-check con [vue-tsc](https://github.com/johnsoncodehk/volar/tree/master/packages/vue-tsc).

**Suspense, fragments… ¡wow!** Hay mucho más que aprender de la tercera versión de Vue, y es una de las librerías que se utilizan en Buk para construir las interfaces e interacciones que son utilizadas por millones de usuarios de la plataforma dentro de latinoamérica.

¡Te invito a conocer más de Buk y [los beneficios de ser un #buker](https://info.buk.cl/reclutamiento-buk-devs?utm_source=blog-eng&utm_medium=link&utm_campaign=outreach)!
