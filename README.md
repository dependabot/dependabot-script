# Dependabot Update Script [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&identifier=131328855)](https://dependabot.com)

This repo contains two scripts that demonstrates
[Dependabot Core][dependabot-core]. It is intended to give you a feel for how
Dependabot Core works so that you can use it in your own project.

If you're looking for a hosted, feature-rich dependency updater then you
probably want [Dependabot][dependabot] itself.

## Setup and usage

### Interactive

* `bundle install`
* Optional step for some langauges (for other languages no setup is needed):
  * JS: `cd "$(bundle show dependabot-npm_and_yarn)/helpers" && ./build install-dir/npm_and_yarn && cd -`
  * Python: `cd "$(bundle show dependabot-python)/helpers" && pyenv exec pip install -r requirements.txt && pyenv local 2.7.15 && pyenv exec pip install -r requirements.txt && pyenv local --unset && cd -`
  * PHP: `cd "$(bundle show dependabot-composer)/helpers" && composer install && cd -`
  * Elixir: `cd "$(bundle show dependabot-hex)/helpers" && mix deps.get && cd -`
* `bundle exec irb`
* Edit the variables at the top of the script you're using, or set the corresponding environment variables.
* Copy and paste the script into the Ruby session to see how Dependabot works.

If you run into any trouble with the above please create an issue!

### GitLab CI

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
