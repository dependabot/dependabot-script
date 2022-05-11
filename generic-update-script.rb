# This script is designed to loop through all dependencies in a GHE, GitLab or
# Azure DevOps project, creating PRs where necessary.

require "dependabot/file_fetchers"
require "dependabot/file_parsers"
require "dependabot/update_checkers"
require "dependabot/file_updaters"
require "dependabot/pull_request_creator"
require "dependabot/omnibus"
require "gitlab"
require 'optparse'
require 'slack-notifier'

options = {}

options[:project] = ENV["PROJECT_PATH"]
options[:directory_path] = ENV["DIRECTORY_PATH"] || "/"
options[:github_access_token] = ENV["GITHUB_ACCESS_TOKEN"]
options[:slack_webhook_url] = ENV["SLACK_WEBHOOK_URL"]
options[:update_type] = ENV["UPDATE_TYPE"]
options[:create_pull_request] = ENV["CREATE_PULL_REQUEST"]

# to be able to pass parameters in cli
# OptionParser.new do |opts|
#   opts.banner = "Usage: example.rb [options]"
#
#   opts.on("--project PROJECT", "Project name") do |v|
#     options[:project] = v
#   end
#
#   opts.on("--directory_path DIRECTORY_PATH", "Directory path") do |v|
#     options[:directory_path] = v
#   end
#
#   opts.on("--github_access_token GITHUB_ACCESS_TOKEN", "Github access token") do |v|
#     options[:github_access_token] = v
#   end
#
#   opts.on("--slack_webhook_url SLACK_WEBHOOK_URL", "Slack webhook url") do |v|
#     options[:slack_webhook_url] = v
#   end
#
#   opts.on("--update_type UPDATE_TYPE", "Update type: security or up_to_date") do |v|
#     options[:update_type] = v
#   end
#
#   opts.on("--create_pull_request CREATE_PULL_REQUEST", "Create a pull request") do |v|
#     options[:create_pull_request] = v
#   end
# end.parse!
# rubocop:enable Metrics/BlockLength

credentials = [
  {
    "type" => "git_source",
    "host" => "github.com",
    "username" => "x-access-token",
    "password" => options[:github_access_token] # A GitHub access token with read access to public repos
  }
]

# Full name of the repo you want to create pull requests for.
repositoryName = options[:project] # namespace/project

# Directory where the base dependency files are.
directory = options[:directory_path] || "/"

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
package_manager = "composer"

source = Dependabot::Source.new(
    provider: "github",
    repo: repositoryName,
    directory: directory,
    branch: branch,
)

# Create array for storing commits
commits = Array.new

##############################
# Fetch the dependency files #
##############################
puts "Fetching #{package_manager} dependency files for #{repositoryName}"
fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
  source: source,
  credentials: credentials,
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

dependencies.select(&:top_level?).each do |dep|
  #########################################
  # Get update details for the dependency #
  #########################################
  checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
    dependency: dep,
    dependency_files: files,
    credentials: credentials,
  )

  if options[:update_type] == "security"
    next unless checker.vulnerable?
  else
    next if checker.up_to_date?
  end

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
    requirements_to_unlock: requirements_to_unlock
  )

  #####################################
  # Generate updated dependency files #
  #####################################
  print "  - Updating #{dep.name} (from #{dep.version})…"
  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
    dependencies: updated_deps,
    dependency_files: files,
    credentials: credentials,
  )

  updated_files = updater.updated_dependency_files

  msg = Dependabot::PullRequestCreator::MessageBuilder.new(
    dependencies: updated_deps,
    files: updated_files,
    credentials: credentials,
    source: source,
    commit_message_options: {}.to_h,
    github_redirection_service: Dependabot::PullRequestCreator::DEFAULT_GITHUB_REDIRECTION_SERVICE
  ).message

  puts "Pull Request Title: #{msg.pr_name}"
  commits.append(msg.pr_name)
  puts "______________________________________________"
  puts commits

  if options[:create_pull_request]
      ########################################
      # Create a pull request for the update #
      ########################################
      assignee = (ENV["PULL_REQUESTS_ASSIGNEE"] || ENV["GITLAB_ASSIGNEE_ID"])&.to_i
      assignees = assignee ? [assignee] : assignee
      pr_creator = Dependabot::PullRequestCreator.new(
        source: source,
        base_commit: commit,
        dependencies: updated_deps,
        files: updated_files,
        credentials: credentials,
        assignees: assignees,
        author_details: { name: "Dependabot", email: "no-reply@github.com" },
        label_language: true,
      )
      pull_request = pr_creator.create
      puts " submitted"

      next unless pull_request
  end
end

if options[:slack_webhook_url]
    SlackClient = Slack::Notifier.new options[:slack_webhook_url]

    commits.each_slice(50) do | batch |
        message = "Repository: " + repositoryName + "\n"
        message = message +  "Commits: \n"
        batch.each do | element |
            message = message + element + "\n"
        end
        puts message

		SlackClient::ping message
    end

    puts "End sending messages to slack"
end

puts "Done"
