# frozen_string_literal: true

require "json"
require "faraday"

require_relative "requester"

module IronDome
  # read the lock file from the project
  class Reader
    URL = "https://api.osv.dev/v1/query"

    def initialize; end

    def call
      read_file
    end

    private

    def read_file
      lock_files = Dir.glob(File.join("*.lock"))
      lock_files.each do |file|
        file_lines = File.read(file).lines
        packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
        result = Requester.osv_request(packages_and_versions)
        puts result
      end
    end
  end
end
