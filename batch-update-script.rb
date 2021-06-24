# This script is designed to be copied into an interactive Ruby session, to
# give you an idea of how the different classes in Dependabot Core fit together.
#
# It's used regularly by the Dependabot team to manually debug issues, so should
# always be up-to-date.

require "dependabot/file_fetchers"
require "dependabot/file_parsers"
require "dependabot/update_checkers"
require "dependabot/file_updaters"
require "dependabot/omnibus"
require "./src/batch_pr_creator"
require "./src/batch_file_updaters"

credentials = [
  {
    "type" => "git_source",
    "host" => "github.com",
    "username" => "x-access-token",
    "password" => ENV["GITHUB_ACCESS_TOKEN"] # A GitHub access token with read access to public repos
  }
]

# Full name of the repo you want to create pull requests for.
repo_name = ENV["PROJECT_PATH"] # namespace/project

# Directory where the base dependency files are.
directory = ENV["DIRECTORY_PATH"] || "/"

# Branch to look at. Defaults to repo's default branch
branch = ENV["BRANCH"]

# Name of the package manager you'd like to do the update for. Options are:
# - bundler
# - pip (includes pipenv)
# - npm_and_yarn
# - maven
# - gradle
# - cargo
# - hex
# - composer
# - nuget
# - dep
# - go_modules
# - elm
# - submodules
# - docker
# - terraform
package_manager = ENV["PACKAGE_MANAGER"] || "bundler"

batch_size = ENV["BATCH_SIZE"].to_i || 1

if ENV["GITHUB_ENTERPRISE_ACCESS_TOKEN"]
  credentials << {
    "type" => "git_source",
    "host" => ENV["GITHUB_ENTERPRISE_HOSTNAME"], # E.g., "ghe.mydomain.com",
    "username" => "x-access-token",
    "password" => ENV["GITHUB_ENTERPRISE_ACCESS_TOKEN"] # A GHE access token with API permission
  }

  source = Dependabot::Source.new(
    provider: "github",
    hostname: ENV["GITHUB_ENTERPRISE_HOSTNAME"],
    api_endpoint: "https://#{ENV['GITHUB_ENTERPRISE_HOSTNAME']}/api/v3/",
    repo: repo_name,
    directory: directory,
    branch: branch,
  )
elsif ENV["GITLAB_ACCESS_TOKEN"]
  gitlab_hostname = ENV["GITLAB_HOSTNAME"] || "gitlab.com"

  credentials << {
    "type" => "git_source",
    "host" => gitlab_hostname,
    "username" => "x-access-token",
    "password" => ENV["GITLAB_ACCESS_TOKEN"] # A GitLab access token with API permission
  }

  source = Dependabot::Source.new(
    provider: "gitlab",
    hostname: gitlab_hostname,
    api_endpoint: "https://#{gitlab_hostname}/api/v4",
    repo: repo_name,
    directory: directory,
    branch: branch,
  )
elsif ENV["AZURE_ACCESS_TOKEN"]
  azure_hostname = ENV["AZURE_HOSTNAME"] || "dev.azure.com"

  credentials << {
    "type" => "git_source",
    "host" => azure_hostname,
    "username" => "x-access-token",
    "password" => ENV["AZURE_ACCESS_TOKEN"]
  }

  source = Dependabot::Source.new(
    provider: "azure",
    hostname: azure_hostname,
    api_endpoint: "https://#{azure_hostname}/",
    repo: repo_name,
    directory: directory,
    branch: branch,
  )
elsif ENV["BITBUCKET_ACCESS_TOKEN"]
  bitbucket_hostname = ENV["BITBUCKET_HOSTNAME"] || "bitbucket.org"

  credentials << {
    "type" => "git_source",
    "host" => bitbucket_hostname,
    "username" => nil,
    "token" => ENV["BITBUCKET_ACCESS_TOKEN"]
  }

  source = Dependabot::Source.new(
    provider: "bitbucket",
    hostname: bitbucket_hostname,
    api_endpoint: ENV["BITBUCKET_API_URL"] || "https://api.bitbucket.org/2.0/",
    repo: repo_name,
    directory: directory,
    branch: nil,
  )
else
  source = Dependabot::Source.new(
    provider: "github",
    repo: repo_name,
    directory: directory,
    branch: branch,
  )
end

##############################
# Fetch the dependency files #
##############################
puts "Fetching #{package_manager} dependency files for #{repo_name}"
fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
  source: source,
  credentials: credentials
)

files = fetcher.files
commit = fetcher.commit

##############################
# Parse the dependency files #
##############################
puts "Parsing dependencies information"
parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
  dependency_files: files,
  source: source,
  credentials: credentials,
)

dependencies = parser.parse
number_of_updated_dependencies = 0
deps = []
updater = nil

dependencies.select(&:top_level?).each do |dep|
  break if number_of_updated_dependencies == batch_size

  checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
      dependency: dep,
      dependency_files: files,
      credentials: credentials,
  )

  next if checker.up_to_date?

  requirements_to_unlock =
      if !checker.requirements_unlocked_or_can_be?
        if checker.can_update?(requirements_to_unlock: :none) then :none
        else :update_not_possible
        end
      elsif checker.can_update?(requirements_to_unlock: :own) then :own
      elsif checker.can_update?(requirements_to_unlock: :all) then :all
      else :update_not_possible
      end

  next if requirements_to_unlock == :update_not_possible

  updated_deps = checker.updated_dependencies(
    requirements_to_unlock: :own
  )

  #####################################
  # Generate updated dependency files #
  #####################################
  print "- Updating #{dep.name} (from #{dep.version})\n"
  deps = deps | updated_deps
  number_of_updated_dependencies = number_of_updated_dependencies + 1

  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
      dependencies: updated_deps,
      dependency_files: files,
      credentials: credentials,
  )

  updated_files = updater.updated_dependency_files
  updated_files_names = updated_files.map { |file| file.name }
  other_files = files.select { |file| not updated_files_names.include?(file.name) }
  files = other_files | updated_files
end

if updater
  # we might need to update the lockfile
  # after we finish updating all the dependencies
  print "Finalize...\n"
  files = updater.finalize
end

if number_of_updated_dependencies > 0
  print "Create PR...\n"
  pr_creator = Dependabot::MultipleDepsPullRequestCreator.new(
      source: source,
      base_commit: commit,
      dependencies: deps,
      files: files,
      credentials: credentials,
      label_language: true,
  )
  pr_creator.create
end

puts "Done"
