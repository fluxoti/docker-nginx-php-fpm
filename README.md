# Docker PHP-FPM Image

A simple image for Laravel Development.

## Image Contents

- Ubuntu 14.04
- NodeJS 5.x
- Npm
- Gulp
- PHP 7
- Composer
- Nginx
- Supervisor

## Usage

### With `AZK`

Example of using this image with [azk][azk]:

```javascript
systems({
  "app": {
    // Dependent systems
    depends: [], // postgres, mysql, mongodb ...
    // More images:  http://images.azk.io
    image: {"docker": "fluxoti/nginx-php-fpm:7"},
    // Steps to execute before running instances
    provision: [
      // "composer install",
    ],
    workdir: "/var/www/#{manifest.dir}",
    shell: "/bin/bash",
    wait: {"retry": 20, "timeout": 1000},
    mounts: {
      '/var/www/#{manifest.dir}': path(".")
    },
    scalable: {"default": 1},
    http: {
      // app.dev.azk.io
      domains: [ "#{system.name}.#{azk.default_domain}" ]
    },
    ports: {
      // exports global variables
      http: "80/tcp",
    },
    envs: {
      // set instances variables
    },
  },
});
```

### Usage with `docker`

To run the image and bind to port 80:

```sh
$ docker run -d -p 80:80 -v "$PWD":/var/www fluxoti/nginx-php-fpm:7
```

## Environment Variables

The following PHP settings can be customized via environment variables:

| Setting             | Env Var                 | Default |
|---------------------|-------------------------|---------|
| error_reporting     | PHP_ERROR_REPORTING     | E_ALL   |
| display_errors      | PHP_DISPLAY_ERRORS      | On      |
| memory_limit        | PHP_MEMORY_LIMIT        | 512M    |
| date.timezone       | PHP_TIMEZONE            | UTC     |
| upload_max_filesize | PHP_UPLOAD_MAX_FILESIZE | 100M    |
| post_max_size       | PHP_POST_MAX_SIZE       | 100M    |

So for example, if you want to change the error reporting and display errors you can override on the container
creation.

### With azk

```javascript
systems({
  "app": {
    ...
    envs: {
      // set instances variables
      PHP_ERROR_REPORTING: "E_STRICT",
      PHP_DISPLAY_ERRORS: "Off"
    }
  },
});
```

### With docker
```sh
$ docker run -d -p 80:80 -v -e PHP_ERROR_REPORTING=E_STRICT -e PHP_DISPLAY_ERRORS=Off "$PWD":/var/www lukz/php-fpm:latest
```

## Monitoring with New Relic

This image already contains the new relic agent for PHP, you just need to se the `NEWRELIC_LICENSE` and `NEWRELIC_APPNAME`
environment variables to the agent works. For example:

```sh
$ docker run -d -p 80:80 -v -e NEWRELIC_LICENSE=abcdefg -e NEWRELIC_APPNAME=example_app "$PWD":/var/www lukz/php-fpm:latest
```

When the php service starts, it will override the values and begin to send the information to New Relic. Then, you can
see the data directly in the New Relic's app menu.

[azk]: http://azk.io