# frozen_string_literal: true

require "json"
require "faraday"

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
        result = osv_request(packages_and_versions)
        result.reject { |element| element.empty? }
      end
    end

    def osv_request(packages_and_versions)
      conn = Faraday.new(URL)

      packages_and_versions.map do |package, version|
        request_body = { version: version, package: { name: package } }

        response = conn.post do |req|
          req.url "/v1/query"
          req.headers["Content-Type"] = "application/json"
          req.body = request_body.to_json
        end

        JSON.parse(response.body)
      end
    end
  end
end
