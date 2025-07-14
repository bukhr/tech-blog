---
trigger: always_on
---

# Reglas Generales

## Herramientas y tecnologías

- Ocupamos `Jekyll` para construir el blog.
- `Jekyll` ocupa [Front Matter](https://jekyllrb.com/docs/front-matter/) para definir los atributos de las paginas y posts.
- En Buk utilizamos `Ruby` como lenguaje principal y `Rails` como framework.
- Nuestra infraestructura está en `AWS`.
- Utilizamos otras tecnologías como: `Terraform`, `Jenkins`, `Prometheus`, `Grafana`, `Mimir`, `React`, `Vue`, `Javascript`, `Docker`, `Github`, `Git`, `Puma` (servidor web de `Rails`).

## Documentación

- `docs/como-agregar-un-post.md`: Cómo agregar un post en el blog.
- `docs/como-agregar-un-author.md`: Cómo agregar un autor (author) al blog.
- `docs/como-agregar-una-entrevista.md`: Cómo agregar una entrevista en el blog.

## Reglas específicas

- El contenido del post es escrito en formato markdown.
- El blog habla sobre tecnología, sobre los más variados temas (ejemplo: `Ruby on Rails`).
- Los posts no pueden contener secretos (`password`, `tokens`, etc).
- Los posts no pueden contener detalles sobre un producto interno que puedan comprometer la seguridad de la información.
- Los posts deben ser escritos en Español, pero deben mantener los términos técnicos en inglés con traducción en `()` siempre que sea necesario.
- Los chats con los usuarios deben ser siempre en español.
- No existe un archivo `_data/authors.yml`, los autores son definidos en la carpeta `_authors` con archivos markdown.
- El Blog no tiene una sección de comentarios.
- En el blog las imágenes de `background` son opcionales.
