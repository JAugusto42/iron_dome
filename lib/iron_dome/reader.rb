# frozen_string_literal: true

require "json"
require "faraday"

require_relative "requester"
require_relative "sarif/output"

module IronDome
  # The Reader class is responsible for reading lock files from the project and generating SARIF reports.
  class Reader
    URL = "https://api.osv.dev/v1/query"

    def initialize; end

    def call
      read_file
    end

    private

    def read_file
      lock_files = Dir.glob("*.lock")
      lock_files.map { |file| process_lock_file(file) }
    end

    def process_lock_file(file)
      file_lines = File.read(file).lines
      packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
      result = Requester.osv_request(packages_and_versions)
      result.compact!
      output_sarif_file_format(result)
    end

    def output_sarif_file_format(result)
      IronDome::Sarif::Output.new.output_report(result) # add options verification to do the output
      puts ":: Sarif file outputed"
    end
  end
end
