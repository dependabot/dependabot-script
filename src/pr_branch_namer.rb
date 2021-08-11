# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Dependabot
  class PullRequestCreator
    require "dependabot/pull_request_creator/branch_namer"

    class MultipleDepsBranchNamer < BranchNamer
      # rubocop:disable Metrics/PerceivedComplexity
      def new_branch_name
        @name ||=
            begin
              if dependencies.count > 1 && updating_a_property?
                property_name
              elsif dependencies.count > 1 && updating_a_dependency_set?
                dependency_set.fetch(:group)
              else
                dependencies.map(&:name).first() + "-plus-#{dependencies.count - 1}-more"
              end
            end

        # Some users need branch names without slashes
        sanitize_ref(File.join(prefixes, @name).gsub("/", separator))
      end
    end
  end
end
