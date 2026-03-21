---
layout: post
title: Modelos en Rails - Guía para escribir código limpio, mantenible y escalable
author: Lesner Villega
tags: 
- rails
- programación
image: "/assets/images/2026-01-20-modelos-en-rails-guia-para-codigo-limpio-mantenible-y-escalable/img-metadata.png"
background: "/assets/images/2026-01-20-modelos-en-rails-guia-para-codigo-limpio-mantenible-y-escalable/background.png"
date: 2026-01-20 16:44 -0600
---
Los modelos en **Ruby on Rails** son el corazón de la capa de dominio: representan datos, reglas de negocio y la lógica que hace que tu aplicación funcione. Sin embargo, a medida que una aplicación crece, es común que los modelos se conviertan en *god objects*: difíciles de mantener, probar y evolucionar.

En este artículo revisamos **una guía de prácticas de la industria** para diseñar modelos en **Rails**, siguiendo el llamado *“modo Rails”*: código claro, explícito, convencional y preparado para escalar.

---

## 📌 MVC sí, pero con responsabilidades claras

Rails implementa el patrón **Modelo–Vista–Controlador (MVC)**. Esto no es solo una convención, sino una guía de diseño.

Los modelos deben:

- Representar datos
- Definir asociaciones
- Validar reglas de negocio centrales

Los modelos **NO** deben:

- Enviar correos
- Orquestar flujos complejos
- Llamar APIs externas
- Coordinar procesos largos

> Un modelo con demasiadas responsabilidades se vuelve frágil y costoso de mantener.

---

## 📌 Extrae lógica compleja fuera del modelo

Cuando un método crece demasiado o mezcla varias responsabilidades, es momento de extraerlo.

### Service Objects

Encapsulan lógica de negocio compleja y reutilizable.

Casos comunes:

- Onboarding de usuarios
- Procesamiento de pagos
- Cálculos financieros
- Flujos multi-paso

Beneficios:

- Mejor legibilidad
- Fácil testeo
- Menor acoplamiento

❌ Mala práctica

```ruby
class Order < ApplicationRecord
  def finalize!
    calculate_totals
    apply_discounts
    charge_credit_card
    notify_user
    update!(status: "completed")
  end
end
```

✅ Buena práctica

```ruby
class CompleteOrder
  def initialize(order)
    @order = order
  end

  def call
    calculate_totals
    apply_discounts
    charge_payment
    mark_completed
  end
end
```

---

## 📌 Callbacks: poderosos, pero peligrosos

Los callbacks (`before_save`, `after_commit`, etc.) pueden generar **efectos secundarios ocultos**.

Buenas prácticas:

- Úsalos solo para lógica interna del modelo
- Evita lógica externa (emails, APIs, jobs)
- Prefiere acciones explícitas desde servicios

❌ Mala práctica

```ruby
class Invoice < ApplicationRecord
  after_save :sync_with_external_system

  def sync_with_external_system
    AccountingApi.sync(self)
  end
end
```

✅ Buena práctica

```ruby
class Invoice < ApplicationRecord
  after_commit :enqueue_sync, on: :create

  private

  def enqueue_sync
    SyncInvoiceJob.perform_later(id)
  end
end
```

> Si no puedes predecir qué hace un `save`, probablemente el modelo está mal diseñado.

---

## 📌 Scopes pequeños, expresivos y componibles

Los **scopes** ayudan a encapsular consultas comunes.

Recomendaciones:

- Nombres claros
- Sin lógica compleja
- Componibles entre sí
- Evita SQL crudo si ActiveRecord es suficiente

❌ Mala práctica

```ruby
scope :custom, -> {
  joins(:orders)
    .where("orders.total > 100 AND users.active = true")
    .order("orders.created_at DESC")
}

```

✅ Buena práctica

```ruby
scope :active, -> { where(active: true) }
scope :high_value_orders, -> { joins(:orders).where("orders.total > 100") }
scope :recent, -> { order(created_at: :desc) }

```

---

## 📌 Validaciones simples y especializadas

Las validaciones deben ser:

- Claras
- Predecibles
- Fáciles de testear

Cuando la validación crece o se reutiliza, usa **Validator Objects** para mantener el modelo limpio y reutilizable.

❌ Mala práctica

```ruby
class User < ApplicationRecord
  validate :email_format

  def email_format
    errors.add(:email, "invalid") unless email =~ /\A.+@.+\z/
  end
end
```

✅ Buena práctica

```ruby
class User < ApplicationRecord
  validates_with EmailFormatValidator
end

class EmailFormatValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:email, "invalid") unless record.email =~ URI::MailTo::EMAIL_REGEXP
  end
end

```

---

## 📌 Asociaciones explícitas y bien definidas

Rails facilita definir relaciones, pero eso no significa que deban usarse sin pensar.

Buenas prácticas:

- Evita asociaciones innecesarias
- Usa `dependent:` conscientemente
- Optimiza con `inverse_of` cuando aplique

❌ Mala práctica

```ruby
class User < ApplicationRecord
  has_many :orders
  has_many :payments
  has_many :subscriptions
end

```

Problemas:

- Modelo inflado
- Acoplamiento innecesario

✅ Buena práctica

```ruby
class User < ApplicationRecord
  has_many :orders, dependent: :restrict_with_error
end

```

Cada asociación tiene un propósito claro.

---

## 📌 Usa Concerns con moderación

Los **Concerns** ayudan a compartir lógica entre modelos.

Advertencias:

- No los uses como “cajón de sastre”
- Si un concern crece demasiado, probablemente merece su propia clase

❌ Mala práctica

```ruby
module CommonStuff
  extend ActiveSupport::Concern

  def normalize_name; end
  def log_activity; end
  def format_date; end
end

```

Problemas:

- Baja cohesión
- Difícil mantenimiento

✅ Buena práctica

```ruby
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(deleted_at: nil) }
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end

```

Un concern = una responsabilidad.

---

## 📌 Performance: piensa en la base de datos

Un modelo bien diseñado también considera performance.

Buenas prácticas:

- Evita N+1
- Usa `includes` para precarga
- Usa `pluck` y `select` cuando no necesitas objetos completos
- Asegura índices adecuados en la base de datos

❌ Mala práctica (N+1)

```ruby
User.all.each do |user|
  puts user.posts.count
end

```

✅ Buena práctica

```ruby
User.includes(:posts).each do |user|
  puts user.posts.size
end

```

---

## 📌 Modelos fáciles de probar

Un buen modelo debe ser:

- Fácil de testear
- Independiente de efectos externos
- Predecible

Pruebas recomendadas:

- Validaciones
- Scopes
- Métodos de dominio
- Casos límite

❌ Mala práctica

```ruby
class Payment < ApplicationRecord
  after_create { ExternalApi.charge(self) }
end

```

Tests lentos y frágiles.

✅ Buena práctica

```ruby
class ChargePayment
  def self.call(payment)
    ExternalApi.charge(payment)
  end
end

```

El modelo queda puro y predecible.

---

## 📌 Escala: patrones avanzados cuando el dominio crece

Cuando la lógica del negocio se vuelve compleja, considera patrones como:

- Domain-Driven Design (DDD)
- Arquitectura Hexagonal
- Event-driven architecture

❌ Mala práctica

```ruby
class User < ApplicationRecord
  def everything
    # auth
    # billing
    # permissions
    # reporting
  end
end

```

✅ Buena práctica

```ruby
Domain/
  Users/
  Billing/
  Auth/

```

---

## 🧩 Conclusión

Los modelos en Rails deben ser:

- Simples
- Legibles
- Fácil de testear
- Predecibles
- Enfocados en el dominio

Rails ofrece herramientas modernas, pero **la calidad del diseño depende de cómo separamos responsabilidades y respetamos el dominio del problema**.

> Código claro hoy es velocidad mañana.
