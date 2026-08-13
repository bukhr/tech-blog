---
layout: post
title: 'Actualizar una gema no debería mover 74 líneas del Gemfile.lock'
subtitle: "Por qué `bundle update` arrastra más de lo que le pides, y cómo lo resolvimos con un plugin de Bundler que vuelve el modo conservativo el default del proyecto."
author: jpacheco
tags: [ruby, bundler, gema, open-source, dependencias]
images_path: /assets/images/2026-08-13-bundle-update-conservativo-por-defecto
date: 2026-08-13 10:00 -0300
---

Cualquiera que haya mantenido una aplicación Ruby on Rails medianamente grande conoce la escena. Necesitas actualizar **una** gema —digamos, `rails`— para aplicar un parche de seguridad o agarrar un bug fix. Ejecutas lo más obvio:

```sh
$ bundle update rails && git diff --stat Gemfile.lock
 Gemfile.lock | 74 +++++++++++++++++++++++-----------------------
```

Setenta y cuatro líneas. Pediste mover una gema.

Parte de ese diff **sí** es esperable. `rails` es una *metagem*: un paquete que agrupa a sus componentes (`actionview`, `activerecord`, `actionpack`, etc.), y tiene todo el sentido que se muevan juntas a la misma versión. Nadie se queja de eso.

El problema es **lo otro** que aparece: dependencias transitivas (transitive dependencies) y compartidas —gemas que `rails` toca indirectamente, como `rack`, `nokogiri` o `concurrent-ruby`— que saltaron a versiones más nuevas que tu `Gemfile` permite, pero que tu cambio en `rails` **no necesitaba** y nadie revisó. En el mejor caso es ruido que ensucia el pull request. En el peor, rompe algo en producción.

![Comparación entre bundle update rails y bundle update --conservative rails: en el primer caso las dependencias transitivas compartidas también se mueven]({{ page.images_path }}/alcance-del-update.svg)

Este post cuenta cómo resolvimos ese problema de raíz con **[`bundler-conservative-update`](https://rubygems.org/gems/bundler-conservative-update)**, un plugin de Bundler que vuelve el `bundle update` conservativo por defecto, y cómo funciona por dentro.

## Por qué pasa: `install` fija, `update` re-resuelve

Para entender el diff gigante hay que mirar cómo Bundler decide qué versiones instalar.

El `Gemfile` no lista versiones exactas: lista **restricciones** (constraints), como `gem "rack", "~> 2.2"`, que admiten un rango de versiones válidas. Bundler toma esas restricciones, suma las que declara cada gema a su vez, y construye un **grafo dirigido acíclico** (DAG) de dependencias. Después corre un **solver** que busca una combinación de versiones que satisfaga todo el grafo a la vez ([rubyguides lo explica en detalle](https://www.rubyguides.com/2021/04/bundler-dependency-resolution/)). Desde Bundler 2.5 ese solver es **Moll**, que resuelve desde cero de forma determinista ([anuncio oficial](https://bundler.io/blog/2023/10/23/bundler-2-5-beta-released.html)).

El resultado de esa resolución se **fija** (lock) en el `Gemfile.lock`. Y ahí está la diferencia entre los dos comandos que más se confunden:

- `bundle install` **respeta el lock**. Si las versiones fijadas siguen satisfaciendo el `Gemfile`, no se mueven.
- `bundle update X` **desbloquea** `X` y toda su cadena de dependencias, **ignora** lo que el lock decía para esas gemas y **re-resuelve**, tomando para cada una la versión más nueva que el `Gemfile` permita.

Ese re-resolver es el mecanismo del diff gigante. Si `actionpack` requiere `rack (>= 2.2.4, < 3.3)` y `rack` estaba fijada en una versión vieja, un `bundle update rails` desbloquea la cadena completa y sube `rack` al tope de ese rango. Nadie pidió mover `rack`.

Y `rack` es un caso especialmente incómodo, porque no es solo una dependencia de `rails`: en nuestro monolito la arrastran también `rack-attack`, `rack-cors`, `rack-mini-profiler` y `opentelemetry-instrumentation-rack`. Es una dependencia **compartida**: una pieza de la que cuelga media aplicación, movida como efecto secundario de un cambio que era sobre otra cosa.

## El daño: un cambio de comportamiento escondido en el PR de otra gema

Esto no es una molestia estética. El equipo de Framework de Buk lo vivió con esa misma gema.

Un salto de `rack` de la **2.2.18 a la 2.2.21** —un patch, legítimo y necesario, que cerraba alertas de seguridad— cambió el comportamiento del *multipart parser* y del *query parser*. Para que la aplicación siguiera comportándose igual hubo que escribir parches a mano, con sus tests, y el cambio alcanzó a cientos de clientes.

Que un patch de seguridad ajuste comportamiento no es anormal; es el costo normal de mantener dependencias al día ([los advisories de Rack son públicos](https://github.com/rack/rack/security/advisories)). Lo doloroso a escala es otra cosa: que un cambio de ese calibre pueda **colarse escondido dentro del PR de otra gema**, sin que nadie lo haya pedido ni revisado deliberadamente. La diferencia entre "subimos `rack` y revisamos el diff del parser" y "subimos `rails` y `rack` vino de pasajero" es enorme cuando algo falla.

En software de gran escala, cada actualización debería ser **intencional**. Por eso en Buk optamos por el modo conservativo, y de esa necesidad nace la gema.

## `--conservative` ya existe, pero hay que acordarse

Bundler tiene una bandera para exactamente esto:

```sh
bundle update --conservative rails
```

[`--conservative`](https://bundler.io/man/bundle-update.1.html) desbloquea **solo** las gemas que nombraste y deja todo lo demás exactamente como estaba en el lock. El diff se reduce a lo que pediste.

El problema es que es **opt-in en cada invocación**. Funciona solo si cada persona —y cada script, y el CI— se acuerda de escribirlo. Y Bundler **no ofrece ninguna configuración** para volverlo el comportamiento por defecto del proyecto.

El resultado es predecible: te olvidas una vez, un compañero se olvida otra, y el `Gemfile.lock` vuelve a llenarse de cambios que nadie pidió. La fricción no está en el flag; está en tener que recordarlo para siempre.

## La solución: que la política viva en el `Gemfile`

La idea detrás de `bundler-conservative-update` es simple: si "actualizar de forma conservativa" es una buena política para el proyecto, **declárala en el proyecto**, no en la memoria de cada persona.

Al ser un [plugin de Bundler](https://bundler.io/guides/bundler_plugins.html), se instala declarándolo en el propio `Gemfile`:

```ruby
plugin "bundler-conservative-update"
```

El siguiente `bundle install` instala el plugin. Desde ahí, **cualquier** `bundle update` sobre ese proyecto —tuyo, de tus compañeros o del CI— se comporta de forma conservativa:

```sh
$ bundle update rails
bundler-conservative-update: re-running with --conservative (only requested gems are updated; set BUNDLER_CONSERVATIVE_UPDATE_DISABLE=1 to opt out)
  Pass --patch, --minor, --major or --all to choose a different update strategy.
```

## Cómo funciona por dentro

Un plugin de Bundler puede registrar **hooks** (ganchos) que se disparan en ciertos eventos del ciclo de vida. Este registra `before-install-all`, que también corre durante un `bundle update`:

```ruby
# plugins.rb
Bundler::Plugin.add_hook("before-install-all") do |_dependencies|
  hook = BundlerConservativeUpdate::Hook.new(argv: ARGV, env: ENV)

  next unless hook.should_inject?

  # ... re-ejecutar bundle con --conservative
end
```

El hook recibe las dependencias, pero **lo importante no está ahí**: qué tan lejos debe llegar el update vive en `ARGV`, los argumentos de la línea de comandos. Así que el plugin inspecciona `ARGV` y decide.

![Flujo del plugin: en el primer pase el hook evalúa cuatro condiciones y re-ejecuta el comando con Kernel.exec; en el segundo pase declina inyectar]({{ page.images_path }}/flujo-del-plugin.svg)

### La decisión

Toda la lógica vive en una clase [`Hook`](https://github.com/bukhr/bundler-conservative-update/blob/main/lib/bundler_conservative_update.rb) que se instancia con `argv` y `env` inyectados —lo que la hace testeable sin un Bundler real— y responde a una sola pregunta:

```ruby
def should_inject?
  index = update_index

  return false if index.nil?
  return false unless @argv[index] == "update"

  args = @argv[(index + 1)..] || []

  return false if skip_flag?(args)
  return false unless scope?(args)
  return false if disabled?

  true
end
```

Se rehúsa a inyectar si el subcomando no es `update` (así `bundle install`, `bundle exec` o `bundle lock` quedan fuera), si el comando ya declara una estrategia explícita (`--conservative`, `--patch`, `--minor`, `--major`, `--strict`, `--all`, `--ruby`, `--bundler`, `--source`), si no nombra nada que actualizar, o si está activo el opt-out por entorno.

Encontrar el subcomando suena trivial y no lo es: hay que saltarse el valor de opciones globales como `--retry 3`, donde el `3` no es un subcomando sino el argumento del flag anterior.

### Re-ejecutar sin envolver

Cuando la decisión es inyectar, el plugin no llama a Bundler internamente: **reemplaza el proceso actual**.

```ruby
Kernel.exec(Gem.ruby, spec.bin_file("bundle"), *hook.conservative_argv)
```

`Kernel.exec` sustituye el proceso en el lugar, así que el stdin y la TTY se heredan, y el exit code que recibes es el del `bundle update` real, no el de un envoltorio. El nuevo `ARGV` es el original con `--conservative` insertado justo después del subcomando:

```ruby
def conservative_argv
  new_argv = @argv.dup
  new_argv.insert(update_index + 1, "--conservative")
  new_argv
end
```

### El guard de recursión que no existe

Re-ejecutar el comando tiene un riesgo obvio: el hook se dispara, re-ejecuta, el hook se vuelve a disparar, y así hasta el infinito. La solución no usa ninguna variable de entorno ni marca de estado.

La recursión se corta sola porque el comando re-ejecutado ya lleva `--conservative` en su propio `ARGV`, y `--conservative` es justamente una de las estrategias explícitas que hacen declinar al hook. Lo ve, se hace a un lado y deja correr el update. El guard contra la recursión y el caso "el usuario ya lo pidió" son literalmente el mismo chequeo.

## Cuándo inyecta, de un vistazo

| Invocación | ¿Inyecta `--conservative`? | Por qué |
|---|---|---|
| `bundle update rails` | sí | nombra una gema |
| `bundle update rails --local` | sí | las flags que no cambian el alcance se conservan |
| `bundle update --group dev` | sí | Bundler expande el grupo en las gemas a desbloquear |
| `bundle update` (sin gemas) | no | no nombra nada; ver abajo |
| `bundle install`, `bundle exec`, `bundle lock` | no | no es un update |
| `bundle update --conservative rails` | no | ya fue pedido; también es el guard de recursión |
| `bundle update --patch/--minor/--major/--strict rails` | no | estrategia explícita |
| `bundle update --all` | no | "actualiza todo", explícito |
| `bundle update --bundler`, `--source`, `--ruby` | no | cambian *qué* se resuelve, no nombran gemas |
| cualquiera con `BUNDLER_CONSERVATIVE_UPDATE_DISABLE=1` | no | opt-out |

### La sutileza: por qué un `bundle update` pelado no se protege

Este es el detalle que más me costó pulir. Uno esperaría que un `bundle update` a secas también se volviera conservativo. Pero `--conservative` restringe la resolución **a través de la lista de gemas que se pidió desbloquear explícitamente**. Cuando esa lista viene vacía, Bundler cae en un fallback y desbloquea **todas** las dependencias directas del `Gemfile`: justo el resultado que el plugin existe para evitar.

Inyectar ahí no restringiría nada y, peor, imprimiría un mensaje que promete algo que no está ocurriendo. Por eso el plugin se hace a un lado, y lo mismo vale para `--bundler`, `--source` y `--ruby`, que cambian qué se resuelve en vez de nombrar gemas.

## Relación con `prefer_patch`

Bundler tiene un setting relacionado que genera confusión: [`prefer_patch`](https://bundler.io/man/bundle-config.1.html) (`BUNDLE_PREFER_PATCH`), que hace que `bundle update` se comporte como `bundle update --patch`. Controlan cosas distintas:

- `prefer_patch` controla el **nivel** de las actualizaciones (preferir patch por sobre minor/major), no su alcance. Las dependencias compartidas y transitivas igual pueden moverse.
- `--conservative` controla el **alcance**: solo se desbloquea lo que nombraste.

El plugin automatiza **solo** el alcance, y ambos conviven bien: como el hook inspecciona `ARGV` y no la configuración de Bundler, tener `BUNDLE_PREFER_PATCH` activo no suprime la inyección. Con los dos, `bundle update rails` mueve `rails` y sus componentes sin arrastrar la cadena compartida, y además prefiere un patch release. Pasar `--patch` explícito en la línea de comandos sí lo suprime, porque ahí el comando ya declara su propia estrategia.

## Limitaciones, honestamente

Ninguna herramienta es mágica, y esta tiene bordes que conviene conocer antes de adoptarla:

- **`bundle update` sin gemas no está protegido**, por el fallback de arriba. Nombra las gemas que quieres, o usa `--all` para ser explícito.
- **`bundle lock --update` no está cubierto.** Ese comando pasa por una ruta de código que nunca dispara los hooks de plugins, así que el plugin no puede verlo. Prefiere `bundle update`, y si necesitas [`bundle lock --update`](https://bundler.io/man/bundle-lock.1.html), revisa el diff a mano.
- **`--bundler`, `--source` y `--ruby` quedan fuera**, por la misma razón.
- **Las herramientas que resuelven el lockfile sin correr `bundle update` localmente** (Dependabot, Renovate y similares) no están cubiertas.
- **Un clone fresco queda desprotegido hasta el primer `bundle install`**, que es lo que instala el plugin.

## Opt-out cuando de verdad lo quieres

No hay un opt-out permanente por proyecto, y es a propósito: si un proyecto quiere updates sin restricciones, simplemente no debería declarar el plugin. Para el caso puntual de "esta vez sí quiero que las transitivas se muevan", basta una variable de entorno:

```sh
BUNDLER_CONSERVATIVE_UPDATE_DISABLE=1 bundle update rails
```

Y para la tarea periódica de actualizar todo no hace falta ninguna variable: `--all` ya se respeta.

## Cuándo vale la pena

`bundler-conservative-update` no es para todos los proyectos. Brilla en **monolitos grandes**, con un `Gemfile.lock` extenso, donde un `bundle update` ingenuo genera diffs inmanejables y el riesgo de una transitiva no revisada es concreto. En proyectos chicos, con pocas gemas, la fricción que ahorra es menor.

Para nosotros encaja con una idea simple: las políticas que benefician a todo el proyecto deberían vivir en el proyecto —en este caso, en el `Gemfile`— y no depender de que cada persona recuerde un flag.

Si la idea te sirve, la gema está en [RubyGems](https://rubygems.org/gems/bundler-conservative-update) y el código en [GitHub](https://github.com/bukhr/bundler-conservative-update). Las contribuciones y reportes de bugs son bienvenidos.
