# WP Dev Kit

> A collection tools and common codes for WordPress development.

Inspired by [WP Dev Lib](https://github.com/xwp/wp-dev-lib) from [XWP](https://github.com/xwp), **WP Dev Kit** puts together a set of tools, common codes, and some opinitiated development configurations used in WordPress development.

It includes:

- A localhost environment.
- A set of Shell (Bash) scripts to run common tasks such as performing unit test and code quality checks.
- A [PHPUnit](https://phpunit.de/) configuration, and a couple of bootstrap files to perform PHPUnit testing for WordPress plugin and theme.
- A PHPCS configuration to perform code quality check with [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer).
- A basic [Composer](https://getcomposer.org/) configuration to manage development dependencie.
- A `.editorconfig` file.

## Installing Docker

**WP Dev Kit** uses [Docker](https://www.docker.com/) to set up and run the localhost enviroment so you will need to have the Docker engine installed in your computer. Docker is available for Windows, Linux, and macOS.

Follow these instruction below to install Docker in the platform of your choice:

- **macOS**: [https://docs.docker.com/docker-for-mac/install/](https://docs.docker.com/docker-for-mac/install/)
- **Windows**: [https://docs.docker.com/docker-for-windows/install/](https://docs.docker.com/docker-for-windows/install/)

For Linux, Docker provides separate instructions for several Linux distributions, as follows:

- **Ubuntu**: [https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- **Debian**: [https://docs.docker.com/install/linux/docker-ce/debian/](https://docs.docker.com/install/linux/docker-ce/debian/)
- **CentOS**: [https://docs.docker.com/install/linux/docker-ce/centos/](https://docs.docker.com/install/linux/docker-ce/centos/)
- **Fedora**: [https://docs.docker.com/install/linux/docker-ce/fedora/](https://docs.docker.com/install/linux/docker-ce/fedora/)

Please keep in mind that the the Bash script

## Installation

To install it as a Git submodule, run the following command in your existing project directory:

```shell
git submodule add -b master https://github.com/tfirdaus/wp-dev-kit.git wp-dev-kit
git submodule update --init --recursive
git add wp-dev-kit
git commit -m "Add wp-dev-kit"
```

Copy the `.env` file and create a _symlink_ for the config files (e.g. `docker-compose.yml`, `phpunit.xml.dist`, etc.) to the main project directory.

```shell
cp wp-dev-kit/.env .
ln -s wp-dev-kit/docker-compose.yml . && git add docker-compose.yml
ln -s wp-dev-kit/phpunit-plugin.xml.dist phpunit.xml.dist && git add phpunit.xml.dist
ln -s wp-dev-kit/phpcs.xml.dist . && git add phpcs.xml.dist
ln -s wp-dev-kit/composer.json . && git add composer.json
ln -s wp-dev-kit/.editorconfig . && git add .editorconfig
```

Then install the development dependencies registered in the Composer config file such as the PHP_CodeSniffer, [WordPress Coding Standards](https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards), and [PHPCompatibilityWP](https://github.com/PHPCompatibility/PHPCompatibilityWP).

```shell
composer install
```

### Updating Git Submodule

To update **WP Dev Kit** with the latest changes from the repository, run:

```shell
git submodule update --recursive
git add wp-dev-kit
git commit -m "Update wp-dev-kit"
```

## Run Shell (Bash) Scripts

**WP Dev Kit** comes with a handful of Bash scripts that to perform some tasks within the Shell in the localhost environment. These scripts are currently mainteined in two different repositories, wp-shell-localhost and wp-shell-pipelines.

### Localhost Scripts

| Command | Description |
| --- | --- |
| `bash localhost/start.sh` | Starting the localhost with WordPress, the theme, and the plugins installed |
| `bash localhost/start.sh --https` | Starting the localhost to load with HTTPS; also install WordPress, theme, and plugins if it's not done so |
| `bash localhost/up.sh` | Build/rebuild the Docker image and spinning the localhost |
| `bash localhost/up.sh -d` | Spinning up the localhost in the background |
| `bash localhost/down.sh` | Shutting-down the container |
| `bash localhost/destroy.sh` | Shutting-down the container and remove everything |
| `bash localhost/ssl-cert.sh` | Generate a self-signed SSL cert; requires OpenSSL |
| `bash localhost/ssh.sh` | Sign-in to the running WordPress container |
| `bash localhost/ssh.sh --root` | Sign-in to the running WordPress container as a `root` |
| `bash localhost/replace-url.sh <new-url>` | Change the current site URL with the `new-url` passed in the argument |
| `bash localhost/mysql-export.sh` | Export the WordPress database. It may also create a new directory called `/dump` if it does not exist to store the SQL file |
| `bash localhost/mysql-import.sh <file>` | Import a WordPress database. The file parameter is required |
| `bash localhost/install.sh <file>` | Install WordPress, and Plugins and Themes specified in the `.env` |
| `bash localhost/init-apache.sh` | Script to override entrypoint in WordPress `php*-apache` Docker images |
| `bash localhost/exec.sh` | A wrapper script to run arbitrary shell script in a running WordPress Docker container |
| `bash localhost/logs.sh` | View the logs in all running containers |
| `bash localhost/logs.sh wordpress` | View the logs in the WordPress (running) container |
| `bash localhost/logs.sh -f` | View and follow the log output in all running containers |

### Pipelines Scripts

| Command | Description |
| --- | --- |
| `bash pipelines/run.sh` | Run an arbitrary command in a Docker container |
| `bash pipelines/tests.sh` | Run a series of tests (e.g. unit test, integration test, and _linting_ or code quality checking) |
| `bash pipelines/phpunit.sh` | Run PHPUnit |
| `bash pipelines/phpcs.sh` | Run PHPCS |
| `bash pipelines/install-wp-tests.sh.sh` | Install and setup WordPress for performing integration tests |

Keep in mind that somes of the pipelines scripts will only work reliably within a Docker container that's set it in the Docker Compose file.

### Aliasing

Running these commands can be bit tedious to do repeatedly, so it is generally a good idea to alias these scripts with an NPM or Yarn script, or a Composer script. Below is an example of how we set an alias with the NPM script:

```json
{
  "name": "acme",
  "version": "0.1.0",
  "description": "The Acme Project",
  "scripts": {
    "local:up": "bash wp-dev-kit/localhost/up.sh",
  }
}
```

Now, we could simply run `npm run local:up` or `yarn local:up`, if you're using Yarn to the get the localhost environment up and running. For more on creating custom scripts with NPM or Yarn, and Composer, you may refer to the following references:

- [https://docs.npmjs.com/misc/scripts](https://docs.npmjs.com/misc/scripts)
- [https://yarnpkg.com/lang/en/docs/cli/run/](https://yarnpkg.com/lang/en/docs/cli/run/)
- [https://getcomposer.org/doc/articles/scripts.md](https://getcomposer.org/doc/articles/scripts.md)

## Environment Variables

**WP Dev Kit** can be configured through the `.env` file. There are quite a number of variables within the file that we change, but possibly one of the most common to change is the `WP_IMAGE`.

The `WP_IMAGE` variable defines the Docker image to use to create the localhost environment. The variable defaults to run `tfirdaus/wp-stack:php7.2-apache` which will run the localhost with PHP 7.2 and Apache. Assuming you'd like to run the localhost with PHP 5.6, you can change the image as follows.

```shell
WP_IMAGE=tfirdaus/wp-stack:php5.6-apache
```

These images are maintained in a separate repository called [wp-stack](https://github.com/tfirdaus/wp-stack) and available in the [Docker Hub](https://hub.docker.com/r/tfirdaus/wp-stack/).

Below are a few more of variables you need to know:

| Variable | Description |
| --- | --- |
| `WP_PUBLISHED_PORT` | The port number to access the localhost |
| `DB_PUBLISHED_PORT` | The port number to access database from the outside of the localhost container. |
| `PMA_PUBLISHED_PORT` | The port number to access phpMyAdmin |
| `WP_SITE_DOMAIN` | The localhost site domain. Default: `localhost` |
| `WP_PLUGINS` | List of plugins to install in the localhost container e.g. `query-monitor` |
| `WP_THEMES` | List of themes to install in the localhost container |

## Example Projects

You can find the list below to see a more concrete example to integrate **WP Dev Kit** into your project.

- [WP Chimp](https://github.com/wp-chimp/wp-chimp): Lean MailChimp subscription form plugin for WordPress
