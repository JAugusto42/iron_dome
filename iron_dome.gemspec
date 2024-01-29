# frozen_string_literal: true

require_relative "lib/iron_dome/version"

Gem::Specification.new do |spec|
  spec.name = "iron_dome"
  spec.version = IronDome::VERSION
  spec.authors = ["Jose Augusto"]
  spec.email = ["joseaugusto.881@outlook.com"]

  spec.summary = "A vulnerability scanner for dependencies."
  spec.homepage = "https://github.com/JAugusto42/iron_dome"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/JAugusto42/iron_dome"
  spec.metadata["changelog_uri"] = "https://github.com/JAugusto42/iron_dome/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.9"
  spec.add_dependency "rake", "~> 13.0"
end
