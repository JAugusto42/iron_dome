# frozen_string_literal: true

require "json"
require "faraday"

require_relative "requester"
require_relative "sarif/output"
require_relative "output"

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
      # read the lockfile, Gemfile.lock for now
      lock_files = Dir.glob("*.lock")
      lock_files.map { |file| process_lock_file(file) }
    end

    def process_lock_file(file)
      file_lines = File.read(file).lines
      packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
      puts "Verifying vulnerabilities on osv database ..."
      result = Requester.osv_request(packages_and_versions)
      result.compact!
      system_output(result)
      output_sarif_file_format(result) unless result # add options verification to do the output
    end

    def output_sarif_file_format(result)
      # method to call the module to generate the sarif report
      puts "Generating the sarif output ..."
      IronDome::Sarif::Output.new.output_report(result)
      puts ":: Sarif file outputed"
    end

    def system_output(result)
      # method to call module to output the result on current shell.
      puts "No vulnerabiities founded" if result.empty?
    end
  end
end
