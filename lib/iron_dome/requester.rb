# frozen_string_literal: true

require "json"
require "faraday"
require "concurrent"

module IronDome
  # The requester class responsible to deal with osv database request and result.
  class Requester
    URL = "https://api.osv.dev/v1/query"
    FARADAY_OPTIONS = { headers: { "Content-Type" => "application/json" } }.freeze
    CONN = Faraday.new(URL, FARADAY_OPTIONS)

    def self.osv_request(packages_and_versions)
      futures = packages_and_versions.each_slice(5).map do |batch|
        Concurrent::Future.execute { process_batch(batch) }
      end

      futures.flat_map(&:value).compact
    end

    def self.process_batch(batch)
      batch.map { |package, version| query_osv(package, version) }
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
