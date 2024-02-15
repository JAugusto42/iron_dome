# frozen_string_literal: true

require "json"
require "faraday"

module IronDome
  class Requester
    URL = "https://api.osv.dev/v1/query"
    FARADAY_OPTIONS = { headers: { "Content-Type" => "application/json" } }.freeze
    CONN = Faraday.new(URL, FARADAY_OPTIONS)

    def self.osv_request(packages_and_versions)
      packages_and_versions.each_slice(5).flat_map do |batch|
        batch.map { |package, version| query_osv(package, version) }
      end.compact
    rescue Faraday::ClientError, Faraday::ConnectionFailed, Faraday::TimeoutError => e
      puts "Error: #{e.message}"
      []
    end

    def self.query_osv(package, version)
      response = CONN.post("/v1/query", { version: version, package: { name: package, ecosystem: "RubyGems" } }.to_json)
      JSON.parse(response.body) unless response.body == "{}"
    end
  end
end
