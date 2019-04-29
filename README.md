# Dependabot Update Script [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&identifier=131328855)](https://dependabot.com)

This repo contains two scripts that demonstrates
[Dependabot Core][dependabot-core]. It is intended to give you a feel for how
Dependabot Core works so that you can use it in your own project.

If you're looking for a hosted, feature-rich dependency updater then you
probably want [Dependabot][dependabot] itself.

## Setup and usage

* `rben install` (Install Ruby version from `.ruby-version`)
* `bundle install`

### Native helpers

Languages that require native helpers to be installed

* Terraform
* Python
* Go
* Go
* Elixir
* PHP
* JS

To install the native helpers, export an environment variable that points to the
directory into which the helpers should be installed and add the relevant bins
to your PATH:

* `export DEPENDABOT_NATIVE_HELPERS_PATH="$(pwd)/native-helpers"`
* `mkdir -p $DEPENDABOT_NATIVE_HELPERS_PATH/{terraform,python,dep,go_modules,hex,composer,npm_and_yarn}`
* `export PATH="$PATH:$DEPENDABOT_NATIVE_HELPERS_PATH/terraform/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/python/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/bin:$DEPENDABOT_NATIVE_HELPERS_PATH/dep/bin"`
* `export MIX_HOME="$DEPENDABOT_NATIVE_HELPERS_PATH/hex/mix"`

Copy the relevant helpers from the gem source to the new install location

* Terraform: `cp $(bundle show dependabot-terraform)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/terraform/helpers`
* Python: `cp $(bundle show dependabot-python)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/python/helpers`
* Go Dep: `cp $(bundle show dependabot-dep)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/dep/helpers`
* Go Modules: `cp $(bundle show dependabot-go_modules)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/helpers`
* Elixir: `cp $(bundle show dependabot-hex)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/hex/helpers`
* PHP: `cp $(bundle show dependabot-composer)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/composer/helpers`
* JS: `cp $(bundle show dependabot-npm_and_yarn)/helpers $DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn/helpers`

Build the helpers you want to use (you'll also need the corresponding language installed)

* Terraform: `$DEPENDABOT_NATIVE_HELPERS_PATH/terraform/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/terraform`
* Python: `$DEPENDABOT_NATIVE_HELPERS_PATH/python/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/python`
* Go Dep: `$DEPENDABOT_NATIVE_HELPERS_PATH/dep/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/dep`
* Go Modules: `$DEPENDABOT_NATIVE_HELPERS_PATH/go_modules/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/go_modules`
* Elixir: `$DEPENDABOT_NATIVE_HELPERS_PATH/hex/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/hex`
* PHP: `$DEPENDABOT_NATIVE_HELPERS_PATH/composer/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/composer`
* JS: `$DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn/helpers/build $DEPENDABOT_NATIVE_HELPERS_PATH/npm_and_yarn`

### Running `update-script.rb`

* `bundle exec irb`
* Edit the variables at the top of the script you're using, or set the corresponding environment variables.
* Copy and paste the script into the Ruby session to see how Dependabot works.

If you run into any trouble with the above please create an issue!

### GitLab CI

The easiest configuration is to have a repository dedicated to the script.
Many pipeline schedules can be added on that single repo to manage multiple projects.  
Thus `https://[gitlab.domain/org/dependabot-script-repo]/pipeline_schedules` dashboard becomes your own dependabot admin interface.

* Clone or mirror this repository.
* Copy `.gitlab-ci.example.yml` to `.gitlab-ci.yml` or set [a custom CI config path for direct usage](https://docs.gitlab.com/ee/user/project/pipelines/settings.html#custom-ci-config-path).
* [Set the required global variables](https://docs.gitlab.com/ee/ci/variables/#variables) used in [`./generic-update-script.rb`][generic-script].
* Create [a pipeline schedule](https://docs.gitlab.com/ee/user/project/pipelines/schedules.html) for each managed repository.
* Set in the schedule the required variables:
  * `PROJECT_PATH`: `group/repository`
  * `PACKAGE_MANAGER_SET`: `bundler,composer,npm_and_yarn`

## The scripts

* [Single dependency update script][github-script]
* [GitLab/GHE update script][generic-script]

[github-script]: update-script.rb
[generic-script]: generic-update-script.rb
[dependabot-core]: https://github.com/dependabot/dependabot-core
[dependabot]: https://dependabot.com
