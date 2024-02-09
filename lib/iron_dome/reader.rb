# frozen_string_literal: true

require "json"
require "faraday"

require_relative "requester"

module IronDome
  # The Reader class is responsible for reading lock files from the project and generating SARIF reports.
  class Reader
    URL = "https://api.osv.dev/v1/query"

    def initialize; end

    def call
      output_report_sarif
    end

    private

    def read_file
      lock_files = Dir.glob("*.lock")
      result = lock_files.map { |file| process_lock_file(file) }
      result.first.compact
    end

    def process_lock_file(file)
      file_lines = File.read(file).lines
      packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
      Requester.osv_request(packages_and_versions)
    end

    def output_report_sarif
      sarif_json = convert_to_sarif(read_file)
      File.write("result.sarif", JSON.pretty_generate(sarif_json))
    end

    def convert_to_sarif(result)
      sarif_result = sarif_schema
      result.each { |vulnerability| process_vulnerability(sarif_result, vulnerability) }
      JSON.pretty_generate(sarif_result)
    end

    def process_vulnerability(sarif_result, vulnerability)
      vulnerability["vulns"].each do |vuln|
        sarif_result[:runs][0][:results] << generate_sarif_result(vuln)
      end
    end

    def generate_sarif_result(vuln)
      {
        ruleId: vuln["id"],
        message: { text: vuln["summary"] },
        locations: build_physical_location(vuln),
        references: build_references(vuln)
      }
    end

    def build_physical_location(vuln)
      affected_package = vuln["affected"][0]["package"]
      {
        physicalLocation: {
          artifactLocation: { uri: affected_package["purl"] },
          region: { startLine: nil, startColumn: nil }
        }
      }
    end

    def build_references(vuln)
      vuln["references"].map { |ref| { type: "WEB", url: ref["url"] } }
    end

    def sarif_schema
      {
        schema: "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
        version: "2.1.0",
        runs: [build_run_info]
      }
    end

    def build_run_info
      {
        tool: {
          driver: {
            name: "OSv.dev API",
            version: "1.0"
          }
        },
        results: []
      }
    end
  end
end
