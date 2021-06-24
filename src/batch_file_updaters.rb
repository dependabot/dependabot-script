# frozen_string_literal: true

require "dependabot/file_updaters"
require "dependabot/file_updaters/base"
require "dependabot/bundler/file_updater"
require "dependabot/cargo/file_updater"
require "dependabot/composer/file_updater"
require "dependabot/dep/file_updater"
require "dependabot/docker/file_updater"
require "dependabot/elm/file_updater"
require "dependabot/git_submodules/file_updater"
require "dependabot/go_modules/file_updater"
require "dependabot/gradle/file_updater"
require "dependabot/hex/file_updater"
require "dependabot/maven/file_updater"
require "dependabot/npm_and_yarn/file_updater"
require "dependabot/nuget/file_updater"
require "dependabot/python/file_updater"
require "dependabot/terraform/file_updater"

module FileUpdatersBaseExtras
  def finalize
    # pass
  end
end

Dependabot::FileUpdaters::Base.class_eval { include FileUpdatersBaseExtras }

module Dependabot
  module Bundler
    class MultiDepFileUpdater < Dependabot::Bundler::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Cargo
    class MultiDepFileUpdater < Dependabot::Cargo::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Composer
    class MultiDepFileUpdater < Dependabot::Composer::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Dep
    class MultiDepFileUpdater < Dependabot::Dep::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Docker
    class MultiDepFileUpdater < Dependabot::Docker::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Elm
    class MultiDepFileUpdater < Dependabot::Elm::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module GitSubmodules
    class MultiDepFileUpdater < Dependabot::GitSubmodules::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module GoModules
    class MultiDepFileUpdater < Dependabot::GoModules::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Gradle
    class MultiDepFileUpdater < Dependabot::Gradle::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Hex
    class MultiDepFileUpdater < Dependabot::Hex::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Maven
    class MultiDepFileUpdater < Dependabot::Maven::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module NpmAndYarn
    class MultiDepFileUpdater < Dependabot::NpmAndYarn::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Nuget
    class MultiDepFileUpdater < Dependabot::Nuget::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Python
    class MultiDepFileUpdater < Dependabot::Python::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
  module Terraform
    class MultiDepFileUpdater < Dependabot::Terraform::FileUpdater
      def finalize
        self.updated_dependency_files
      end
    end
  end
end

Dependabot::FileUpdaters.register("bundler", Dependabot::Bundler::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("cargo", Dependabot::Cargo::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("composer", Dependabot::Composer::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("dep", Dependabot::Dep::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("docker", Dependabot::Docker::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("elm", Dependabot::Elm::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("submodules", Dependabot::GitSubmodules::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("go_modules", Dependabot::GoModules::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("gradle", Dependabot::Gradle::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("hex", Dependabot::Hex::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("maven", Dependabot::Maven::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("npm_and_yarn", Dependabot::NpmAndYarn::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("nuget", Dependabot::Nuget::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("pip", Dependabot::Python::MultiDepFileUpdater)
Dependabot::FileUpdaters.register("terraform", Dependabot::Terraform::MultiDepFileUpdater)
