# This repo is deprecated!

> [!CAUTION]
> Using dependabot-script is no longer the preferred way to run a self-hosted version of Dependabot. See the [Example CLI Usage](https://github.com/dependabot/example-cli-usage) repo for how to use the [Dependabot CLI](https://github.com/dependabot/cli) instead for this purpose.

----

# Dependabot Script

This repo is a collection of scripts to use as entrypoints to the [Dependabot Core][dependabot-core] library. It is intended as a starting point for advanced users to run a self-hosted version of Dependabot within their own projects.

If you're looking for a hassle-free Dependabot experience, check out the hosted [Dependabot Service][dependabot service].

### Note: Community Maintained Project
This is a community-maintained project. As such, the Dependabot team at GitHub will review PR contributions to update this repo, but is unable to provide further support such as debugging why something doesn't work. 

## Local setup and usage

```shell
rbenv install # (Install Ruby version from ./.ruby-version)
bundle install
```

### Native helpers

Languages that require native helpers to be installed: Terraform, Python, Go, Elixir, PHP, JS

To install the native helpers, export an environment variable that points to the
directory into which the helpers should be installed and add the relevant bins
to your PATH:

```shell
export DEPENDABOT_NATIVE_HELPERS_PATH="$(pwd)/native-helpers"
mkdir -p $DEPENDABOT_NATIVE_HELPERS_PATH/{terraform,python,dep,go_modules,hex,composer,npm_and_yarn}
export PATH="$PATH:$DEPENDABOT_NATIVE_HELPERS_PATH/terraform/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/python/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/dep/bin"
export MIX_HOME="$DEPENDABOT_NATIVE_HELPERS_PATH/hex/mix"
```

Copy the relevant helpers from the gem source to the new install location

| Language   | Command                                                                                                  |
| ---------- | -------------------------------------------------------------------------------------------------------- |
| Terraform  | `cp -r $(bundle show dependabot-terraform)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/terraform/helpers`       |
| Python     | `cp -r $(bundle show dependabot-python)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/python/helpers`             |
| Go         | `cp -r $(bundle show dependabot-go_modules)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/helpers`     |
| Elixir     | `cp -r $(bundle show dependabot-hex)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/hex/helpers`                   |
| PHP        | `cp -r $(bundle show dependabot-composer)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/composer/helpers`         |
| JS         | `cp -r $(bundle show dependabot-npm_and_yarn)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn/helpers` |

Build the helpers you want to use (you'll also need the corresponding language installed)

| Language   | Command                                                                                                   |
| ---------- | --------------------------------------------------------------------------------------------------------- |
| Terraform  | `$DEPENDABOT_NATIVE_HELPERS_PATH/terraform/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/terraform`       |
| Python     | `$DEPENDABOT_NATIVE_HELPERS_PATH/python/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/python`             |
| Go         | `$DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/go_modules`     |
| Elixir     | `$DEPENDABOT_NATIVE_HELPERS_PATH/hex/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/hex`                   |
| PHP        | `$DEPENDABOT_NATIVE_HELPERS_PATH/composer/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/composer`         |
| JS         | `$DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn` |

### Environment Variables

The update scripts are configured using environment variables. The available
variables are listed in the table below. (See
[./generic-update-script.rb][generic-script] for more context.)

Variable Name             | Default          | Notes
:------------             | :--------------- | :----
`DIRECTORY_PATH `         | `/`              | Directory where the base dependency files are.
`PACKAGE_MANAGER`         | `bundler`        | Valid values: `bundler`, `cargo`, `composer`, `dep`, `docker`, `elm`,  `go_modules`, `gradle`, `hex`, `maven`, `npm_and_yarn`, `nuget`, `pip` (includes pipenv), `submodules`, `terraform`
`PROJECT_PATH`            | N/A (Required) | Path to repository. Usually in the format `<namespace>/<project>`.
`BRANCH         `         | N/A (Optional) | Branch to fetch manifest from and open pull requests against.
`PULL_REQUESTS_ASSIGNEE`  | N/A (Optional) | User to assign to the created pull request.
`OPTIONS`                 | `{}`           | JSON options to customize the operation of Dependabot

There are other variables that you must pass to your container that will depend on the Git source you use:

**Github**

Variable            | Default
:-------            | :------
GITHUB_ACCESS_TOKEN | N/A (Required)

**Github Enterprise**

Variable                       | Default
:-------                       | :------
GITHUB_ENTERPRISE_ACCESS_TOKEN | N/A (Required)
GITHUB_ENTERPRISE_HOSTNAME     | N/A (Required)

**Gitlab**

Variable            | Default
:-------            | :------
GITLAB_ACCESS_TOKEN | N/A (Required)
GITLAB_AUTO_MERGE   | N/A (Optional)
GITLAB_HOSTNAME     | `gitlab.com`
GITLAB_ASSIGNEE_ID  | N/A Deprecated. Use `PULL_REQUESTS_ASSIGNEE` instead.

**Azure DevOps**

Variable           | Default
:-------           | :------
AZURE_ACCESS_TOKEN | N/A (Required)
AZURE_HOSTNAME     | `dev.azure.com`

Also note that the `PROJECT_PATH` variable should be in the format: `organization/project/_git/package-name`.

**Bitbucket**

Variable               | Default
:------                | :------
BITBUCKET_ACCESS_TOKEN | N/A (Required*)
BITBUCKET_APP_USERNAME | N/A (Required*)
BITBUCKET_APP_PASSWORD | N/A (Required*)
BITBUCKET_API_URL      | `https://api.bitbucket.org/2.0`
BITBUCKET_HOSTNAME     | `bitbucket.org`

\* Either `BITBUCKET_ACCESS_TOKEN` must be passed, or `BITBUCKET_APP_USERNAME` and `BITBUCKET_APP_PASSWORD`.

### Running dependabot

There are a few ways of running the script:
  * interactively with `./update-script.rb`,
  * non-interactively with `./generic-update-script.rb`,
  * and non-interactively using Docker.

You can also set it up to run as part of your repositories workflows
  * [GitHub Actions Standalone](#github-actions-standalone)
  * [GitLab](#gitlab-ci)

#### Running `update-script.rb` (GitHub only)

1. `bundle exec irb`
2. Edit the variables at the top of the script you're using, or set the corresponding [environment variables](#environment-variables).
3. Copy and paste the script into the Ruby session to see how Dependabot works.

If you run into any trouble with the above please create an issue!

#### Running `generic-update-script.rb`

1. Configure your shell with the correct [environment variables](#environment-variables).
2. Execute the script with Bundler:
    ```shell
    bundle exec ruby ./generic-update-script.rb
    ```

#### Running script with dependabot-script Dockerfile

If you don't want to setup the machine where the script will be executed, you
could run the script within a `dependabot/dependabot-script` container.

You can build and run the `Dockerfile` in order to do that. You'll also have to
set several [environment variables](#environment-variables) to make the script
work with your configuration, as specified above. (You can find how to pass
environment variables to your container in [Docker run
reference](https://docs.docker.com/engine/reference/run/#env-environment-variables).)


Steps:

1. Build the dependabot-script Docker image

```shell
git clone https://github.com/dependabot/dependabot-script.git
cd dependabot-script

docker build -t "dependabot/dependabot-script" -f Dockerfile .
```

2. Run dependabot

```shell
docker run --rm \
  --env "PROJECT_PATH=organization/project" \
  --env "PACKAGE_MANAGER=bundler" \
  "dependabot/dependabot-script"
```

If everything goes well you should be able to see something like:

```shell
/home/dependabot/dependabot-script# ./generic-update-script.rb
Fetching gradle dependency files for myorganisation/project
Parsing dependencies information
...
```

#### Running scripts with dependabot-core Dockerfile only

The dependabot-core `Dockerfile` installs dependencies as the `dependabot` user,
so volume mounting won't work unless you build the image by passing in the
`USER_UID` and `USER_GID` arguments. This creates the `dependabot` user with the
same IDs ensuring it owns the mounted files and can write to them from within
the container.

Steps:

1. Build dependabot-core image

```
git clone https://github.com/dependabot/dependabot-core.git
cd dependabot-core

docker build \
  --build-arg "USER_UID=$(id -u)" \
   --build-arg "USER_GID=$(id -g)" \
  -t "dependabot/dependabot-core" .
cd ..
```

2. Install dependencies
```
git clone https://github.com/dependabot/dependabot-script.git
cd dependabot-script

docker run -v "$(pwd):/home/dependabot/dependabot-script" -w /home/dependabot/dependabot-script dependabot/dependabot-core bundle install -j 3 --path vendor
```

3. Run dependabot
```
docker run --rm -v "$(pwd):/home/dependabot/dependabot-script" -w /home/dependabot/dependabot-script -e ENV_VARIABLE=value dependabot/dependabot-core bundle exec ruby ./generic-update-script.rb
```
### GitHub Actions Standalone
The easiest and most common way to run Dependabot on GitHub is using the built-in
Dependabot service as described [here](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/automating-dependabot-with-github-actions). This is recommended for most users.

However, sometimes you may need to run Dependabot manually either for testing, or to enable features/plugins that are
not currently available in Dependabot. This is relatively straight-forward to achieve with a shell-based GitHub action.

  * In your GitHub repository, create a directory `.github/workflows` if it doesn't already exist.
  * Copy [manual-github-actions.yaml](./manual-github-actions.yaml) into that directory.
  * Customize `PACKAGE_MANAGER` to suit your needs, see the [possible values above.](#environment-variables)
  * (Optional) Customize `OPTIONS` to suit your needs or delete

By default this action is set to run on workflow dispatch, which means that you need to manually trigger the workflow run.
If you would rather run it on a set schedule, you can switch to [schedule dispatch](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule).

### GitLab CI

The easiest configuration is to have a repository dedicated to the script.
Many pipeline schedules can be added on that single repo to manage multiple projects.
Thus `https://[gitlab.domain/org/dependabot-script-repo]/pipeline_schedules` dashboard becomes your own dependabot admin interface.

* Clone or mirror this repository.
* Copy `.gitlab-ci.example.yml` to `.gitlab-ci.yml` or set [a custom CI config path for direct usage](https://docs.gitlab.com/ee/ci/pipelines/settings.html#specify-a-custom-cicd-configuration-file).
* [Set the required global variables](https://docs.gitlab.com/ee/ci/variables/#variables) used in [`./generic-update-script.rb`][generic-script].
* Create [a pipeline schedule](https://docs.gitlab.com/ee/ci/pipelines/schedules.html) for each managed repository.
* Set in the schedule the required variables:
  * `PROJECT_PATH`: `group/repository`
  * `PACKAGE_MANAGER_SET`: `bundler,composer,npm_and_yarn`
* If you'd like to specify the directory that contains the manifest file in the repository, you can set the following environment variable:
  * `DIRECTORY_PATH`: `/path/to/point`
* If you'd like Merge Requests to be assigned to a user, set the following environment variable:
  * `PULL_REQUESTS_ASSIGNEE`: Integer ID of the user to assign. This can be found at `https://gitlab.com/api/v4/users?username=<your username>`

## The scripts

* [Single dependency update script][github-script]
* [GitLab/GHE update script][generic-script]

[github-script]: update-script.rb
[generic-script]: generic-update-script.rb
[dependabot-core]: https://github.com/dependabot/dependabot-core
[dependabot service]: https://docs.github.com/en/github/administering-a-repository/about-dependabot-version-updates
