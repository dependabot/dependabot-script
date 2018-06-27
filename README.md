# Dependabot Update Script [![Dependabot Status](https://api.dependabot.com/badges/status?host=github&identifier=131328855)](https://dependabot.com)

This repo contains two scripts that demonstrates
[Dependabot Core][dependabot-core]. It is intended to give you a feel for how
Dependabot Core works so that you can use it in your own project.

If you're looking for a hosted, feature-rich dependency updater then you
probably want [Dependabot][dependabot] itself.

# Setup and usage

* `bundle install`
* Optional step for some langauges:
  * JS (Yarn): `cd "$(bundle show dependabot-core)/helpers/yarn" && yarn install && cd -`
  * JS (npm): `cd "$(bundle show dependabot-core)/helpers/npm" && yarn install && cd -`
  * Python: `cd "$(bundle show dependabot-core)/helpers/python" && pyenv exec pip install -r requirements.txt && pyenv local 2.7.15 && pyenv exec pip install -r requirements.txt && pyenv local --unset && cd -`
  * PHP: `cd "$(bundle show dependabot-core)/helpers/php" && composer install && cd -`
  * Elixir: `cd "$(bundle show dependabot-core)/helpers/elixir" && mix deps.get && cd -`
* `bundle exec irb`
* Edit the variables at the top of the script you're using
* Copy and paste the script into the Ruby session to see how Dependabot works

If you run into any trouble with the above please create an issue!

# The scripts

* [Single dependency update script][github-script]
* [GitLab update run script][gitlab-script]

[github-script]: update-script.rb
[gitlab-script]: gitlab-update-script.rb
[dependabot-core]: https://github.com/dependabot/dependabot-core
[dependabot]: https://dependabot.com
