# This script is designed to loop through all dependencies in a GitLab project,
# creating PRs where necessary.
#
# It is intended to be used as a stop-gap until Dependabot's hosted instance
# supports GitLab (coming soon!)

require "dependabot/file_fetchers"
require "dependabot/file_parsers"
require "dependabot/update_checkers"
require "dependabot/file_updaters"
require "dependabot/pull_request_creator"

credentials =
  [
    {
      "type" => "git_source",
      "host" => "gitlab.com",
      "password" => ENV["GITLAB_ACCESS_TOKEN"] # A Gitlab access token with API permission
    },
    {
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => ENV["GITHUB_ACCESS_TOKEN"] # A Github access token with read access to public repos
    }
]

# Full name of the GitLab repo you want to create pull requests for.
repo_name = "#{ENV["GITLAB_USERNAME"]}/#{ENV["PROJECT_NAME"]}"

# Directory where the base dependency files are.
directory = "/"

# Name of the package manager you'd like to do the update for. Options are:
# - bundler
# - pip (includes pipenv)
# - npm_and_yarn
# - maven
# - cargo
# - hex
# - composer
# - submodules
# - docker
package_manager = "bundler"

source = Dependabot::Source.new(
  provider: "gitlab",
  repo: repo_name,
  directory: directory,
  branch: nil
)

##############################
# Fetch the dependency files #
##############################
fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
  source: source,
  credentials: credentials,
)

files = fetcher.files
commit = fetcher.commit

##############################
# Parse the dependency files #
##############################
parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
  dependency_files: files,
  source: source,
  credentials: credentials,
)

dependencies = parser.parse

dependencies.each do |dep|
  #########################################
  # Get update details for the dependency #
  #########################################
  checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
    dependency: dep,
    dependency_files: files,
    credentials: credentials,
  )

  next if checker.up_to_date?
  next unless checker.can_update?(requirements_to_unlock: :own)
  updated_deps = checker.updated_dependencies(requirements_to_unlock: :own)

  #####################################
  # Generate updated dependency files #
  #####################################
  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
    dependencies: updated_deps,
    dependency_files: files,
    credentials: credentials,
  )

  updated_files = updater.updated_dependency_files

  ########################################
  # Create a pull request for the update #
  ########################################
  pr_creator = Dependabot::PullRequestCreator.new(
    source: source,
    base_commit: commit,
    dependencies: updated_deps,
    files: updated_files,
    credentials: credentials,
  )
  pr_creator.create
end
