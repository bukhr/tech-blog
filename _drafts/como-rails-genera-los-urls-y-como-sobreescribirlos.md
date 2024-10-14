---
layout: post
title: Cómo Rails genera los URLs y como sobreescribirlos
subtitle: Un pequeño recorrido por el proceso de construcción de rutas relativas y URLs
  en Rails
author: Diego Echeverría G.
tags: [rails, REST, url, actionpack]
date: 2024-10-11 15:26 -0300
images_path: /assets/images/2024-10-11-como-rails-genera-los-urls-y-como-sobreescribirlos
background: "/assets/images/2024-10-11-como-rails-genera-los-urls-y-como-sobreescribirlos/ruby-on-rails-logo.svg.png"
---
¿Te has preguntado alguna vez como es que Rails hace para transformar todos los métodos que terminan en `url` o `path` en URLs legibles para nuestro navegador? Pues si lo has hecho, has llegado al lugar correcto, en este post te explicaré cómo es que Rails genera de manera dinámica estos métodos y como sobreescribir la construcción de URLs de manera efectiva en tu aplicación.

Toda aplicación en Rails suele utilizar métodos de la forma `action_resource_path` donde `action` corresponde en general a rutas custom fuera del CRUD (es vacío de ser una ruta del CRUD como `create`) y `resource` corresponde al nombre del recurso al que queremos llegar con la ruta. Por ejemplo para el recurso `users` y su acción para editar la contraseña `edit_password`, el método que utilizaremos será el método `edit_password_user_path`. Esto generará un URL del estilo `www.example.com/users/6/edit_password` o `users/6/edit_password` dependiendo del contexto.

A pesar de que esto lo usamos muchísimo, es muy difícil saber como es que estos métodos se definen 'solos' apenas se declaran las rutas en el archivo de rutas, casi como por arte de magia, pero no te preocupes, ahora te lo explicamos.

## Definición de métodos dinámicos de URL

Para definir los métodos dinámicos de generación de URLs Rails toma el archivo `config/routes.rb` y utilizando una [convención de nombres basada en REST](https://guides.rubyonrails.org/routing.html), genera helpers o métodos como el del ejemplo `edit_password_user_path`, que retornarán un string en forma de URL completa o parcial.

Esta conversión se lleva a cabo en la clase `Rails::Routes::RouteSet` perteneciente a la [gema `actionpack`](https://github.com/rails/rails/tree/main/actionpack). Rails, usando está clase, mapea cada definición de ruta en el archivo de rutas, al conjunto de verbos HTTP `GET`, `POST`, `PATCH`, `DESTROY`, etc. y a una acción y controlador específico dentro de la aplicación. Luego, estos métodos se crean de manera dinámica usando `define_method` y `method_missing` en tiempo de ejecución, justo cuando las rutas son cargadas al inicio de la aplicación.

Así, la clase `Rails::Routes::RouteSet` es la responsable de almacenar absolutamente todas las rutas definidas en la aplicación, pero ¿Sería una pesima idea repetir el código no? dado que Rails mantiene una convención estable y nosotros como desarrolladores no llegamos a tocar la definición de estas rutas casi nunca, no es muy eficiente que todos  los helpers dinámicos definan el mismo código y hagan lo mismo. Por esto es que los helpers se apoyan de otro módulo que contiene todas estas convenciones, pero se declarán de todas maneras para hacernos la vida más fácil, ya que son más convenientes y más legibles y mucho más fáciles de utilizar, ya entenderemos por qué.

## Delegación a `url_for`, `path_for` y `full_url_for`

Los métodos dinámicos generados y almacenados en `Rails::Routes::RouteSet` funcionan de la siguiente manera: Delegan la construcción de su URL a uno de dos métodos que vienen de la misma gema `actionpack`, hablamos de `url_for` y `path_for`. Cada uno de los helpers custom de URL generados tiene una llamada a `url_for` (para URLs completas) o a `path_for` (para rutas relativas) de la clase `Rails::Routes::RouteSet`, que son los responsables de armar la URL definitiva.

Dentro de la clase `Rails::Routes::RouteSet` en el método `url_for` se construyen las opciones para llamar a métodos subyacentes pertenecientes a la clase singleton del módulo de la misma gema llamado `ActionDispatch::Http::URL`.

En caso de que el método dinámico llame al método `path_for` de la clase `Rails::Routes::RouteSet`, esto llamará al método `url_for` de la misma clase, pero con las opciones correctas para luego llamar al método `path_for` de la clase singleton del módulo `ActionDispatch::Http::URL`. En el caso de que el método dinámico llame al método `url_for` de la clase `Rails::Routes::RouteSet`, en general se llamará al método `url_for` de la clase singleton del módulo `ActionDispatch::Http::URL`.

Así, los métodos que construyen el URL final serán los métodos `path_for` y `url_for` de la clase singleton del módulo `ActionDispatch::Http::URL`. En este contexto el método `path_for` construirá el string del path relativo al que se quiere llegar (por ejemplo `'users/6/edit_password'`), mientras que el método `url_for` decidirá, según las opciones, si llamar al método `path_for` del mismo contexto o al método `full_url_for` del mismo contexto que construirá la URL completa, desde inicio a fin (por ejemplo `'www.example.com/users/6/edit_password'`).

Finalmente, estos métodos son propagados a `ActionView` y `ApplicationController` a través de un tercer módulo llamado `ActionDispatch::Routing::UrlFor` que es incluido en los módulos `ActionView::RoutingUrlFor` y `ActionController::UrlFor` respectivamente, e inyecta los métodos `url_for` y `path_for` que también pueden ser usados para generar URLs, sin embargo, dado que nosotros simples mortales no sabemos como funciona el módulo `ActionDispatch::Http::URL` es mucho más conveniente utilizar los métodos dinámicos. De manera simplificada podríamos decir que el resultado de `edit_password_user_path(6)` será el mismo que el resultado de `url_for(controller: 'users', action: 'edit_password', id: 6)`.

![Diagrama de creación de URLs en Rails simplificado]({{page.images_path}}/rails-creacion-de-urls.png)

*Diagrama de creación de URLs en Rails simplificado*

## Sobreescribiendo la construcción de URLs

Entonces ¿Cómo sobreescribimos la construcción de URLs? y ¿Por qué querriamos sobreescribir las URLs? Uno de los muchos casos de uso que podríamos aplicar para sobreescribir los URLs es agregar parámetros a la construcción de manera global.

Por ejemplo, podríamos recuperar el trace y saber desde donde es que un usuario le esta haciendo click a cierta URL, es decir, en que archivo se genera el link clickeado. Esto no es simple de hacer, ya que en Rails el trace de una llamada a una URL parte cuando se crea el objeto de la request y pierde toda referencia a los archivos anteriores.

Agregar a mano los `params` no es escalable, puesto que cada vez que se llame a la ruta tendríamos que estar agregando el parámetro que buscamos.

Entonces ¿Cómo agregamos un parámetro a la URL? Los métodos no dinámicos (del módulo `ActionDispatch::Http::URL`) de construcción de URLs reciben solo un parámetro de nombre `options`, este parámetro contiene el controlador y la ruta a los que se quiere llegar, además de los parámetros. En consecuencia, para modificar las URLs bastará con modificar los `options`, dependiendo de lo que requieras realizar, te recomiendo que con un debugger analices como modificarlos. Sin embargo, dependiendo del nivel en el que estemos mirando el argumento `options`, este podría ser: Un hash con lo ya mencionado, un string con URL, o un record de un modelo (`ActiveRecord`), por lo que tenemos que tener cuidado al momento de sobreescribirlo.

Para agregarle parámetros al URL en la generación podemos tomar varios caminos:

* Podemos sobreescribir directamente el método de generación de URL, por ejemplo sobreescribir el método `edit_password_user_path` y `edit_password_user_url` en los lugares donde se utilice, es decir, en `ActionView`, `ApplicationController`, `ActionMailer`, etc. Esto quita el overhead de las demás URLs y da flexibilidad al momento de querer sobreescribir en solo algunos componentes de la aplicación. Sin embargo, esto es poco escalable, dado que si otra ruta lo necesita probablemente tendremos que repetir código y re definir el método cada método nuevo. En este nivel es posible recibir todo lo que nosotros hayamos declarado en la aplicación como `options`, por lo que de eso dependera nuestra sobreescritura.

* Podemos sobreescribir los métodos `url_for` y `path_for` y usar un mecánismo para identificar las rutas a sobreescribir, como un archivo externo o un concern en los controladores. Luego inyectar esta sobreescritura en los componentes donde los necesitemos `ActionView`, `ApplicationController`, `ActionMailer`, etc. o en componentes más específicos como podría ser el controlador `UsersController`. Esta opción entrega la misma flexibilidad anterior, pero con mayor escalabilidad, sin embargo, si buscas algo más global, te recomendamos utilizar la siguiente opción. Además, en este nivel podemos recibir hashes, strings u otros como `options`, por lo que la sobreescritura se puede volver tediosa y con código innecesario.

* Podemos sobreescribir los métodos `url_for` y `path_for` directamente en la clase singleton del módulo `ActionDispatch::Http::URL` dentro de un initializer de la siguiente manera:

  ```ruby
  Rails.application.config.after_initialize do
    ActionDispatch::Http::URL.singleton_class.prepend(Module.new do
      def url_for(options = {})
        super(modify_url_options(options))
      end

      def path_for(options = {})
        super(modify_url_options(options))
      end
    end)
  end
  ```

  Utilizamos un `Module.new` para evitar leaks de memoria, junto con `after_initialize` para evitar que las versiones anteriores de la sobreescritura se queden trabadas.

  Esto reemplazará el comportamiento de todos los métodos dinámicos de generaciíon de URLs en la aplicación, sin excepción. En este nivel además, los método `url_for` y `path_for` solo pueden recibir hashes como `options`, por lo que se hace mucho más fácil sobreescribir.

Esperamos que con esto hayas aprendido un poco del ciclo de vida de los links en Rails o que al menos te haya dado curiosidad el tema para seguir investigandolo por tu cuenta. Happy coding!
