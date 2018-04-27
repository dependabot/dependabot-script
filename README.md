# Dependabot Update Script

This repo contains a [simple script][script] that demonstrates
[Dependabot Core][dependabot-core]. It is intended to give you a feel for how
Dependabot Core works so that you can use it in your own project.

If you're looking for a hosted, feature-rich version then you probably want
[Dependabot][dependabot] itself.

# Usage

* `bundle install`
* Optional step for some langauges:
  * JS (Yarn): `cd "$(bundle show dependabot-core)/helpers/yarn" && yarn install && cd -`
  * JS (npm): `cd "$(bundle show dependabot-core)/helpers/npm" && yarn install && cd -`
  * Python: `cd "$(bundle show dependabot-core)/helpers/python" && pip install -r requirements.txt && cd -`
  * PHP: `cd "$(bundle show dependabot-core)/helpers/php" && composer install && cd -`
  * Elixir: `cd "$(bundle show dependabot-core)/helpers/elixir" && mix deps.get && cd -`
* `bundle exec irb`
* Copy and paste the script into the Ruby session to see how Dependabot works

If you run into any trouble with the above please create an issue!

[script]: update-script.rb
[dependabot-core]: https://github.com/dependabot/dependabot-core
[dependabot]: https://dependabot.com
