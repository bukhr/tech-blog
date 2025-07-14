# Cómo ejecutar el blog localmente

1. Ejecutar el siguiente comando en tu terminal:

    ```sh
    bundle exec jekyll serve --livereload --drafts
    ```

2. Abrir la URL [http://localhost:4000](http://localhost:4000) en tu navegador web.

## Cómo ejecutar el blog localmente (usando devbox)

1. Asegúrate de tener instalado [nix](https://nixos.org/) y [devbox](https://www.jetpack.io/devbox/) en tu sistema.
2. Ejecutar el siguiente comando en tu terminal para iniciar el entorno de desarrollo:

    ```sh
    devbox shell
    ```

3. Una vez dentro del entorno virtual, ejecutar los siguientes comandos:

    ```sh
    bundle install
    bundle exec jekyll serve --livereload --drafts
    ```

4. Abrir la URL [http://localhost:4000](http://localhost:4000) en tu navegador web para visualizar el blog.
