---
layout: post
title: Optimizando la generación de documentos con Liquid
subtitle: Tips y optimizaciones que hicimos en Buk para generar documentos usando el motor de plantillas Liquid
author: Camilo Flores
tags: [liquid, optimización, documentos, plantillas]
date: 2021-08-06 12:29 -0400
background: /assets/images/2021-08-06-optimizando-la-generacion-de-documentos-con-liquid/portada.png
image: /assets/images/2021-08-06-optimizando-la-generacion-de-documentos-con-liquid/portada_preview.png
---
Una de las funcionalidades más usadas en Buk es la generación de documentos a partir de plantillas que definen los mismos usuarios. Esto es especialmente útil a la hora de generar contratos o anexos de trabajo, certificados y cualquier otra cosa que se le pueda ocurrir a nuestros clientes.

Para hacer esta magia usamos la recomendadísima gema [Liquid💧](https://shopify.github.io/liquid/) de Shopify. Esta gema se usa en Shopify para que sus usuarios puedan definir de forma simple las páginas web de los comercios que levantan, pero también se usa en otras plataformas como Jekyll donde está montado este humilde blog ~~y por lo que tuve que invertir varios minutos averiguando cómo escapar los fragmentos de Liquid para escribir este post~~.

En fin, mucha introducción, vamos a la papa.

## ¿Qué es Liquid?💧

En palabras de Shopify:

> Safe, customer-facing template language for flexible web apps.

En concreto permite declarar documentos en lo que es posible usar llaves dobles y Liquid se encargará de interpretar lo que está adentro. Por ejemplo:

```liquid
{% raw %}{{ page.title }}{% endraw %}
```

Imprimirá el atributo `title` de la variable `page`.

Pero si eso fuera todo esto el post sería muy fome, no estaríamos usando Liquid y yo no estaría escribiendo esto. La gracia es que Liquid va más allá:  permite a quienes definen las plantillas programar lógica (pero de forma segura). De hecho, otra definición de Liquid en la misma página dice:

> Liquid is a flexible, safe language, and is used in many different environments. Liquid was created for use in Shopify stores, and is also used extensively on Jekyll websites.

O sea se pueden declarar plantillas como esta:

```liquid
{% raw %}{% for customer in collection.customers %}
  {% if customer.name == "kevin" %}
    Hey {{ customer.name | upcase }}!
  {% else %}
    Hi Stranger!
  {% endif %}
{% endfor %}{% endraw %}
```


¡La creatividad del usuario es el límite 🤯!

## Usando Liquid programáticamente

Para que Liquid haga su magia son necesarios dos pasos:

1. Interpretar la plantilla a través de Liquid
2. "Renderizar" el contenido en base a la plantilla interpretada y un hash de "contexto" que contiene el valor de las variables a usar al interior de la plantilla:

```ruby
# Primero creamos e interpretamos la plantilla
template = "Hola {% raw %}{{ employee.name }}{% endraw %}!"
parsed_template = Liquid::Template.parse(template)

# Luego declaramos el objeto con las variables y lo usamos para renderear el resultado:
vars = { 'employee'=> { 'name'=> "Juan", 'age'=> 40 } }
puts parsed_template.render(vars)
```

Lo anterior, como es de esperar, imprimirá el mensaje `Hola Juan!`.

> Ten presente que Liquid requiere que las llaves del objeto desde el cual extrae las variables deben ser strings, por lo que si quieres usar un `Hash` estándar debes invocar `Hash#with_indifferent_access` de `ActiveSupport`

Easy peasy. Todo bien, todos felices.

## El problema

Si claro, éramos felices en Buk, todo funcionaba ok. El problema es que a medida que empezamos a disponibilizar cosas más complejas ¡el rendimiento de la generación de documentos empezó a empeorar!.

La razón es que a medida que la funcionalidad empezó a ser más usada se empezó a requerir disponibilizar variables cada más complejas. El problema que nos empezó a pegar es que, como a Liquid debemos pasarle el hash con todas las variables disponibles, todos los valores se evalúan antes de interpretar la plantilla. Por ejemplo, dado el siguiente objeto:

```ruby
vars = {
  empleado: {
    fecha_ingreso: I18n.l(employee.start_date),  # 1
    nombre: employee.person.full_name,           # 2
    nombre_jefe: employee.boss.person.full_name, # 3
    liquidacion: {
      monto: Settlement::CalculateAmountService.call(employee.last_settlement) # 4
    }
  }
}
```

Si se usa cada vez que alguien use una plantilla que requiera información básica del empleado (como por ejemplo la plantilla `{% raw %}{{ empleado.fecha_ingreso }}{% endraw %})`:

1. Se transformará el atributo `start_date` a la localización del usuario correspondiente (bien! 👍)
2. Se irá a buscar a la persona correspondiente al empleado y se invocará el método `full_name` (mal! 👎)
3. Se irá a buscar al jefe del empleado y luego a la persona, para luego invocar el método `full_name` (muy mal! 👎👎👎)
4. Aunque los puntos anteriores se pueden mitigar con el uso de `preload` (como comentamos en [este post sobre N+1](https://buk.engineering/2021/05/03/n-1-como-identificar-y-reducirlo-en-ruby-on-rails.html)), de todas formas se invocará al servicio para calcular el monto de una liquidación (terrible! ☠️☠️☠️ porque para calcular una liquidación es necesario recolectar un montón de información y hacer muchísimos cálculos "caros")

## Solución 1

La primera solución que se nos ocurrió fue separar las cosas "caras" en objetos diferentes, pero quisimos mantener una estructura lógica en las variables a la hora de generar una plantilla de cara al usuario. Además los usuarios ya estaban acostumbrados a generar sus plantillas de esta forma y evitamos a toda costa romper interfaces, ya sean de API, HTML o, en este caso, plantillas.

## Solución 2

Dándole una vuelta, nos pusimos a pensar si sería posible declarar el objeto de forma "funcional", es decir, que los valores fueran funciones tales que al invocarlas retornaran el valor correspondiente.

Navegando por el código de Liquid, vemos que el método que evalúa las variables (`Liquid::Context#lookup_and_evaluate`) es así:

```ruby
def lookup_and_evaluate(obj, key, raise_on_not_found: true)
  if @strict_variables && raise_on_not_found && obj.respond_to?(:key?) && !obj.key?(key)
    raise Liquid::UndefinedVariable, "undefined variable #{key}"
  end

  value = obj[key]

  if value.is_a?(Proc) && obj.respond_to?(:[]=)
    obj[key] = value.arity == 0 ? value.call : value.call(self)
  else
    value
  end
end
```

Vemos que si el valor es un `Proc`, Liquid se encargará de invocarlo!. Como Ruby sí permite hacer programación funcional y concisa a través de lambdas, hicimos la prueba de concepto:

```ruby
# Primero, evaluando la plantilla sin requerir calcular la edad:
vars = { 'employee'=> { 'name' => -> {"John"}, 'age'=> -> { puts "calculando age"; 40}}}
puts parsed_template.render(vars)
# => Hola John!

# Excelente. No se invoca el puts del lambda del valor de `age`.
# Pero... ¿funcionará para?

template_2 = "Hola {% raw %}{{ employee.name }}{% endraw %}, tienes {% raw %}{{ employee.age }}{% endraw %} años!"
parsed_template_2 = Liquid::Template.parse(template_2)
puts parsed_template_2.render(vars)
# => calculando age
# => Hola John, tienes 40 años!
```

🎉 ¡Éxito! Liquid hará el trabajo de evaluar sólo los lambdas que necesite de acuerdo con la plantilla en tiempo de renderizado. Lo mejor es que es un cambio muy pequeño en cuanto a código, nuestro objeto queda así:

```ruby
vars = {
  empleado: {
    fecha_ingreso: I18n.l(employee.start_date),
    nombre: -> { employee.person.full_name },
    nombre_jefe: -> { employee.boss.person.full_name },
    liquidacion: {
      monto: -> { Settlement::CalculateAmountService.call(employee.last_settlement) }
    }
  }
}
```

¿Éxito definitivo?

¡Casi! La verdad es que quedamos bien contentos con la solución pero nos encontramos con un par de problemas adicionales:

  1. El usar `stringify_keys` hace un poco menos cómoda la programación ya que hay que estar conscientes sobre qué tipo de datos se usan en las llaves del objeto creado por liquid para usarlo en nuestras plantillas
  2. Nos encontramos con el problema de que muchas veces calculábamos algo "caro" (por ejemplo una liquidación de un empleado) y luego calculábamos algo relacionado que ya había sido calculado para el valor anterior (por ejemplo un ítem particular de la liquidación como los días trabajados), donde nos beneficiaríamos mucho de "recordar" valores entre distintos valores del objeto usado para las plantillas.

## Solución 3

Para poder representar en plantillas los objetos básicos de Ruby (strings, hashes, arrays, etc), `Liquid` extiende estas clases con la función `to_liquid` que es la que finalmente se invoca al evaluar las plantillas. Así, basta crear nuestra propia clase con un método `.to_liquid` con las comodidades que necesitamos para hacernos más fácil la vida.

```ruby
# Representa una variable para liquid, que será evaluada solo en el momento en que alguien
# la utilice. Además, entrega facilidades para usar símbolos o strings para el objeto retornado
#
class LazyLiquidVar
  attr_reader :block

  def initialize(&block)
    raise ArgumentError, "Block is required" unless block_given?
    @block = block
  end

  def to_liquid
    @to_liquid ||= begin
      res = value
      res = res.stringify_keys if res.respond_to?(:stringify_keys) # liquid sólo usa strings
      res
    end
  end

  # Crea un nuevo valor lazy, pasando el valor actual
  def chain
    LazyLiquidVar.new do
      yield value
    end
  end
end
```

Y luego podremos hacer cosas como:

```ruby
def some_expensive_query
  min_value, max_value = expensive_array.minmax
  {
    min: min_value,
    max: max_value,
  }
end

expensive_vars = LazyLiquidVar.new{ some_expensive_query }
vars = {
  'name': employee.name
  min_value: expensive_vars.chain{|h| h[:min] },
  max_value: expensive_vars.chain{|h| h[:max] },
}
```

y 💥 ! Podremos usar objetos con keys de símbolos o strings, reutilizando cálculos caros y sólo calculando los valores que sean necesarios para renderizar nuestro documento.

## Resumen

En general en Buk nos gusta usar gemas que aportan con funcionalidades a nuestro producto y no reinventar la rueda, pero más de una vez nos ha pasado que al escalar debemos "estrujar" las gemas, o incluso [parcharlas](https://github.com/bukhr). Si te gusta ir más lejos, meter las manos en gemas y aportar al ecosistema opensource... ¿Te animas a hacerlo juntos? [¡Estamos contratando!]({{ site.work_with_us_link }})
