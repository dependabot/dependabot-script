# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Dependabot
  class PullRequestCreator
    require "dependabot/pull_request_creator/message_builder"

    class MultipleDepsMessageBuilder < MessageBuilder
      def multidependency_intro
        if dependencies.count > 3
          other_length = dependencies.count - 1
          "Bumps #{dependency_links.first}"\
          ", and " + other_length + " others."
        else
          "Bumps #{dependency_links[0..-2].join(', ')} "\
          ", and #{dependency_links[-1]}."
        end
      end
    end
  end
end
