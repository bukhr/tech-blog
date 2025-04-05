---
layout: post
title: 'Migración paso a paso: De attr_encrypted al cifrado nativo de Rails 7+'
subtitle: Recientemente, en Buk, nos vimos en la necesidad de migrar el cifrado de
  datos sensibles desde la gema attr_encrypted al cifrado nativo de Rails
author: aboneto
tags: gem, rails, attr_encrypted, encryption, security
image: "/assets/images/2025-04-07-migración-paso-a-paso-de-attr-encrypted-al-cifrado-nativo-de-rails-7/img-metadata.jpeg"
background: "/assets/images/2025-04-07-migración-paso-a-paso-de-attr-encrypted-al-cifrado-nativo-de-rails-7/background.jpeg"
date: 2025-04-05 14:04 -0300
---
Recientemente, en Buk, nos vimos en la necesidad de migrar el cifrado de datos sensibles desde la gema [attr_encrypted](https://github.com/attr-encrypted/attr_encrypted) al cifrado nativo de Rails (Active Record Encryption) a partir de la versión 7+ (https://railsguides.es/active_record_encryption.html). Esta migración fue impulsada por la adopción del cifrado nativo en las versiones más recientes de algunas de las gemas que utilizamos, lo que nos llevó a cuestionar la necesidad de mantener dos métodos de cifrado. Además, considerando la evolución de Rails, concluimos que el cifrado nativo es la solución a futuro para nuestras aplicaciones.

Tras analizar ambas opciones, junto con los riesgos asociados, decidimos migrar al cifrado nativo con [Active Record Encryption](https://railsguides.es/active_record_encryption.html) debido a sus diversas ventajas.

#### Ventajas de Active Record Encryption sobre la gema attr_encrypted

##### Mantenimiento y Soporte

- **Active Record Encryption**: Al ser parte del core de Rails, recibe mantenimiento y actualizaciones continuas por el equipo de Rails. Esto asegura que se mantenga al día con las mejores prácticas de seguridad y las nuevas versiones de Rails.

- **attr_encrypted**: Es una gema de terceros. Su mantenimiento depende de la comunidad y de sus mantenedores. Aunque ha sido popular, el soporte y las actualizaciones pueden ser menos consistentes que con una funcionalidad del core.

##### Integración con Rails

- **Active Record Encryption**: Está diseñado específicamente para integrarse con Active Record, el ORM de Rails. Esto resulta en una experiencia de desarrollo más fluida y consistente, aprovechando las convenciones y características de Rails.
- **attr_encrypted**: Aunque funciona bien con Active Record, es una solución externa que puede requerir más configuración y adaptación.

##### Seguridad

- **Active Record Encryption**: Rails sigue las mejores prácticas de seguridad y actualiza el cifrado según sea necesario. Se centra en la seguridad por defecto, lo que reduce el riesgo de errores de implementación.
- **attr_encrypted**: La seguridad depende de la correcta configuración y uso de la gema. Si no se configura adecuadamente, puede haber vulnerabilidades.

##### Rendimiento

- **Active Record Encryption**: Al estar integrado en el core, puede ofrecer un mejor rendimiento en algunos casos, ya que se optimiza para funcionar con Rails.
- **attr_encrypted**: Puede introducir una sobrecarga adicional debido a la necesidad de cargar y ejecutar la gema.

##### Facilidad de Uso

- **Active Record Encryption**: Simplifica el proceso de cifrado con una API clara y concisa. Se integra bien con las migraciones de Rails, facilitando la gestión de las claves de cifrado.
- **attr_encrypted**: Requiere más configuración y puede ser más complejo de usar, especialmente en escenarios más avanzados.

##### Evolución y Futuro

- **Active Record Encryption**: Al ser parte del core, es la dirección futura para el cifrado en Rails. Invertir en él asegura que tu aplicación se mantenga actualizada con las últimas tendencias y mejoras.
- **attr_encrypted**: Puede volverse menos relevante a medida que Rails continúa mejorando su funcionalidad de cifrado nativo.

##### Ventajas adicionales del cifrado nativo de Rails

- Reducción de uso de gemas al pasar a un código nativo
- Eliminar la dependencia de gemas de terceros para una funcionalidad crítica en la aplicación
- Posibilidad de adaptarse fácilmente a las nuevas versiones de las gemas que utilizan ese cifrado
- Posibilidad de rotación de llaves y con retrocompatibilidad durante la rotación
- Facilidad para migrar datos entre estados cifrados y no cifrados
- Posibilidad de consultar datos cifrados en la base de datos sin comprometer la seguridad de los datos

## Nuestro proceso de migración

### 1. Configurando Active Record Encryption

Generamos las llaves de cifrado:

```shell
bin/rails db:encryption:init
```

Creamos las nuevas variables de entorno con las llaves generadas:

```shell
# .env.development
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=<valor de primary_key>
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=<valor de deterministic_key>
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=<valor de key_derivation_salt>
```

Configuramos el nuevo inicializador de Active Record Encryption:

```ruby
# config/initializers/active_record_encryption.rb
ActiveRecord::Encryption.configure(
  primary_key: ENV['ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY'],
  deterministic_key: ENV['ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY'],
  key_derivation_salt: ENV['ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT'],
  support_unencrypted_data: true,
  store_key_references: true,
  encrypt_fixtures: false,
)
```

Todas las posibles configuraciones de Active Record Encryption pueden ser encontradas en la [documentación de Active Record Encryption](https://railsguides.es/active_record_encryption.html#opciones-de-configuraci%C3%B3n).

### 2. Adicionando nuevos atributos para auxiliar la migración

Para no afectar la continuidad operativa, tuvimos que crear nuevos atributos para auxiliar la migración de los datos sensibles de `attr_encrypted` a `Active Record Encryption`.

Como teniamos el prefijo `encrypted_` para los atributos de `attr_encrypted` utilizamos los nombres originales de los atributos de `attr_encrypted` para los nuevos atributos de `Active Record Encryption`.

Por ejemplo, si teniamos un atributo `encrypted_token` en `attr_encrypted` lo convertimos en `token` en `Active Record Encryption`.

Para que eso fuera posible, tuvimos que crear métodos wrapper para los atributos cifrados. También hicimos uso de un feature flag para que la migración fuera gradual, permitiendo hacer pruebas controladas internas y posteriormente con algunos clientes y no afectar la continuidad operativa.

Métodos wrapper para consultar el atributo cifrado:

```ruby
class ApiAuthToken < ApplicationRecord
    ...
    def encryption_key
        # retorna la llave de cifrado de attr_encrypted
    end

    def token
        if Buk::Feature.enabled?(:feature_flag) && encrypted_attribute?(:token)
            self[:token]
        else
            iv = Base64.decode64(self[:encrypted_token_iv])
            ApiAuthToken.decrypt_token(self[:encrypted_token], iv: iv, key: encryption_key)
        end
    end
end
```

> Nota: `Buk::Feature.enabled?` es un método para verificar que la feature flag esté activada en Buk, es interno y no nativo de Rails. Caso no tenga feature flags, puede ocupar una variable de entorno o quitar el control de la feature flag, ocupando el código interno del `else`.

Antes de agregar los nuevos atributos, tuvimos que controlar el valor del atributo `token` para no almacenar el valor sin cifrar. Para eso creamos un método wrapper:

```ruby
class ApiAuthToken < ApplicationRecord
    ...
    def token=(value)
        iv = SecureRandom.random_bytes(12)
        encrypted_value = ApiAuthToken.encrypt_token(value, iv: iv, key: encryption_key)
        self[:encrypted_token_iv] = Base64.encode64(iv)
        self[:encrypted_token] = encrypted_value
        self[:token] = nil if ApiAuthToken.column_names.include? "token"
    end
    ...
end
```

> Nota: No podríamos simplesmente usar el `self.ignored_columns` ya que el nombre del atributo es el mismo utilizado en `attr_encrypted`.

Después que el código anterior estaba en producción, creamos una nueva migración para agregar los nuevos atributos:

```ruby
class AddTokenToApiAuthToken < ActiveRecord::Migration[7.0]
    def up
        add_column :api_auth_tokens, :token, :string
    end

    def down
        remove_column :api_auth_tokens, :token
    end
end
```

### 3. Agregando el cifrado nativo

Una vez que la migración anterior fue ejecutado en producción, agregamos el cifrado nativo de Rails 7+.

```ruby
class ApiAuthToken < ApplicationRecord
    ...
    encrypts :token, deterministic: true
    ...
end
```

> Nota: `deterministic: true` es para que el cifrado sea predecible, es decir, que el mismo valor siempre se cifre de la misma manera. Así podremos consultar el valor del atributo `token` cifrado en la base de datos, sin tener que ocupar su valor original.

Para mantener el valor del atributo `token` y el valor cifrado del atributo `encrypted_token` sincronizados, actualizamos el método wrapper de asignación de valor (ejemplo: `token=`):

```ruby
class ApiAuthToken < ApplicationRecord
    ...
    def token=(value)
        iv = SecureRandom.random_bytes(12)
        encrypted_value = ApiAuthToken.encrypt_token(value, iv: iv, key: encryption_key)
        self[:encrypted_token_iv] = Base64.encode64(iv)
        self[:encrypted_token] = encrypted_value
        self[:token] = value
    end
    ...
end
```

Para atributos que necesitamos consultar, en este ejemplo el `token`, hicimos un método wrapper que nos permitía decidir que atributo consultar, `token` o `encrypted_token` dependiendo de si la feature flag estaba activada o no:

```ruby
class ApiAuthToken < ApplicationRecord
    ...
    # Wrapper para evitar el cache cuando activamos y desactivamos la FF
    def self.find_by(conditions)
        where(conditions).take
    end

    # Wrapper para determinar que atributo debemos consultar para el token
    def self.where(conditions)
        if Buk::Feature.enabled?(:feature_flag)
            conditions = conditions.symbolize_keys
            if conditions[:encrypted_token].present?
                conditions[:token] = conditions[:encrypted_token]
                conditions.delete(:encrypted_token)
            end 
        end
        super
    end
    ...
end
```

> Nota: `Buk::Feature.enabled?` es un método para verificar que la feature flag esté activada en Buk, es interno y no nativo de Rails. Caso no tenga feature flags en su sistema, puede ocupar una variable de entorno o quitar ese código.

### 4. Sincronizando los datos

Para sincronizar los datos, hicimos una migración para actualizar los valores de `token` con el valor de `encrypted_token`.

```ruby
class SyncApiAuthTokenToken < ActiveRecord::Migration[7.0]
    class ApiAuthToken < ApplicationRecord
        encrypts :token, deterministic: true
        attr_encryptor :encrypted_token, key: :encryption_key, encode: true

        def encryption_key
            # retorna la llave de cifrado de attr_encrypted
        end

        def decrypt_token_with_attr_encrypted
            iv = Base64.decode64(self[:encrypted_token_iv])
            ApiAuthToken.decrypt_token(self[:encrypted_token], iv: iv, key: encryption_key)
        end

        def token=(value)
            iv = SecureRandom.random_bytes(12)
            encrypted_value = ApiAuthToken.encrypt_token(value, iv: iv, key: encryption_key)
            self[:encrypted_token_iv] = Base64.encode64(iv)
            self[:encrypted_token] = encrypted_value
            self[:token] = value
        end
    end

    def change
        ApiAuthToken.all.each do |token|
            token.token = token.decrypt_token_with_attr_encrypted
            token.save!
        end
    end
end
```

### 5. Activar la feature flag

Si utiliza una Feature Flag o variable de entorno para controlar qué variable cifrada debe devolver el valor, puede habilitarla gradualmente en sus entornos y observar el comportamiento del sistema. Una vez que alcance el 100% del despliegue, puede continuar con el paso 6.

De lo contrario, puede omitir este paso (ir al paso 6).

### 6. Eliminamos el not null del atributo encrypted_token

Creamos una migración para eliminar el not null del atributo `encrypted_token` y `encrypted_token_iv`:

```ruby
class RemoveNotNullFromEncryptedToken < ActiveRecord::Migration[7.0]
    def up
        change_column_null :api_auth_tokens, :encrypted_token, true
        change_column_null :api_auth_tokens, :encrypted_token_iv, true
    end

    def down
        change_column_null :api_auth_tokens, :encrypted_token, false
        change_column_null :api_auth_tokens, :encrypted_token_iv, false
    end
end
```

### 7. Eliminamos el código de attr_encrypted

Debemos eliminar todo el código relacionado con la gema attr_encrypted, incluyendo los helpers y los métodos wrapper que hicimos para consultar el atributo cifrado. Como utilizamos el nombre original del campo, todo quedará limpio.

Todo el código de attr_encrypted debe ser eliminado. Ejemplo:

```ruby
attr_encryptor :encrypted_token, key: :encryption_key, encode: true
```

Los métodos `encryption_key`, `token=`, `token`, `self.find_by` y `self.where` también deben ser eliminados.

Solo debería quedar ese código en el modelo:

```ruby
encrypts :token, deterministic: true
```

Que es el código que usamos para cifrar el atributo `token` con el cifrado nativo de Rails 7+.

### 8. Eliminamos los atributos de attr_encrypted

Debemos eliminar los atributos de la gema attr_encrypted (en el caso de nuestro ejemplo `encrypted_token` y `encrypted_token_iv`) con una migración.

```ruby
class RemoveEncryptedTokenFromApiAuthToken < ActiveRecord::Migration[7.0]
    def up
        remove_column :api_auth_tokens, :encrypted_token
        remove_column :api_auth_tokens, :encrypted_token_iv
    end

    def down
        add_column :api_auth_tokens, :encrypted_token, :string
        add_column :api_auth_tokens, :encrypted_token_iv, :string
    end
end
```

### 9. Documentar los cambios

La integridad de los datos, un aspecto crítico en el desarrollo de software, debe ser garantizada durante esta migración. Por lo tanto, es esencial que documentemos minuciosamente los cambios realizados y el nuevo método de cifrado de atributos. Esto nos permitirá entender el proceso de migración y hacerlo de manera correcta, principalmente para prevenir errores en el futuro.

## Conclusión

Active Record Encryption se presenta como una alternativa de cifrado moderna, segura y con un mantenimiento simplificado para aplicaciones Rails. Al estar integrado en el núcleo de Rails, ofrece una experiencia de desarrollo superior, un rendimiento potencialmente optimizado y una seguridad reforzada a largo plazo, consolidándose como la opción preferente para nuevos proyectos y actualizaciones.

El proceso de migración desde `attr_encrypted` hacia `Active Record Encryption` requiere una cuidadosa planificación y ejecución. Antes de realizar cualquier cambio, es crucial identificar todos los modelos que utilizan `attr_encrypted`, así como evaluar los riesgos y posibles fallas inherentes al proceso de migración. Con toda la información recopilada, se podrá proceder a la planificación detallada y, posteriormente, a la ejecución de la migración.

La implementación de pruebas automatizadas es fundamental a lo largo de todo el proceso de migración, con el fin de validar el correcto funcionamiento en cada etapa y mitigar el riesgo de incidencias en producción.

La prioridad máxima debe ser la continuidad operativa y la seguridad de los datos. Para ello, se recomienda trabajar con atributos nuevos y, si es posible, emplear scripts de validación que aseguren la sincronización de los datos en el entorno de producción, minimizando así el riesgo de sorpresas inesperadas.

Se ha elaborado una guía detallada del proceso de migración, tomando como ejemplo práctico el modelo `ApiAuthToken`. Es importante que este procedimiento se aplique de manera similar a todos los modelos reales del proyecto que dependen de la gema `attr_encrypted` para el cifrado de datos.
