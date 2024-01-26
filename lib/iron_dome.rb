# frozen_string_literal: true

require_relative "iron_dome/version"
require_relative "iron_dome/reader"

module IronDome
  class Error < StandardError; end

  # class entry, this is the entrypoint of the gem.
  class Entry
    def main
      Reader.new.call
    end
  end
end
