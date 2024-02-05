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
      output_report_sarif
    end

    private

    def read_file
      lock_files = Dir.glob(File.join("*.lock"))
      result = []

      lock_files.each do |file|
        file_lines = File.read(file).lines
        packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
        result << Requester.osv_request(packages_and_versions)
      end
      result.first.compact
    end

    def output_report_sarif
      # output the scan result in a sarif file
      sarif_json = convert_to_sarif(read_file)

      File.open("result.sarif", "w") do |file|
        file.puts sarif_json
      end
    end

    def convert_to_sarif(result)
      sarif_result = {
        schema: "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
        version: "2.1.0",
        runs: [
          {
            tool: {
              driver: {
                name: "OSv.dev API",
                version: "1.0"
              }
            },
            results: []
          }
        ]
      }

      result.each do |vulnerability|
        vulnerability["vulns"].each do |vuln|
          sarif_result[:runs][0][:results] << {
            ruleId: vuln["id"],
            message: {
              text: vuln["summary"]
            },
            locations: [
              physicalLocation: {
                artifactLocation: {
                  uri: vuln["affected"][0]["package"]["purl"]
                },
                region: {
                  startLine: 1, # Adjust line number based on the actual information in your response
                  startColumn: 1
                }
              }
            ],
            references: vuln["references"].map { |ref| { type: "WEB", url: ref["url"] } }
          }
        end
      end

      JSON.pretty_generate(sarif_result)
    end
  end
end
