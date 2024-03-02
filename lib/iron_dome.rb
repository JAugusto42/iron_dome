# frozen_string_literal: true

require "json"
require "faraday"
require "colorize"
require "optparse"

require_relative "iron_dome/requester"
require_relative "iron_dome/sarif/output"
require_relative "iron_dome/output"
require_relative "iron_dome/version"
require_relative "iron_dome/reader"

module IronDome
  class Error < StandardError; end

  # class entry, this is the entrypoint of the gem.
  class Entry
    # rubocop:disable Metrics/MethodLength
    def main
      puts display_ascii_art

      options = {}
      OptionParser.new do |opts|
        opts.on("-o", "--output", "Generate a sarif format file report.") do |output|
          options[:sarif_output] = output
        end

        opts.on("-d", "--detail", "Show vulnerability details.") do |detail|
          options[:detail] = detail
        end
      end.parse!

      Reader.new(options).call
    end
    # rubocop:enable Metrics/MethodLength

    def display_ascii_art
      <<-ART
  ██╗██████╗  ██████╗ ███╗   ██╗██████╗  ██████╗ ███╗   ███╗███████╗
  ██║██╔══██╗██╔═══██╗████╗  ██║██╔══██╗██╔═══██╗████╗ ████║██╔════╝
  ██║██████╔╝██║   ██║██╔██╗ ██║██║  ██║██║   ██║██╔████╔██║█████╗
  ██║██╔══██╗██║   ██║██║╚██╗██║██║  ██║██║   ██║██║╚██╔╝██║██╔══╝
  ██║██║  ██║╚██████╔╝██║ ╚████║██████╔╝╚██████╔╝██║ ╚═╝ ██║███████╗
  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝

      ART
    end
  end
end
