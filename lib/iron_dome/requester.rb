# frozen_string_literal: true

require "json"
require "faraday"

module IronDome
  # Module responsible for requesting the vulnerability database
  class Requester
    URL = "https://api.osv.dev/v1/query"

    def self.osv_request(packages_and_versions)
      conn = Faraday.new(URL)

      packages_and_versions.map do |package, version|
        request_body = { version: version, package: { name: package } }

        response = conn.post do |req|
          req.url "/v1/query"
          req.headers["Content-Type"] = "application/json"
          req.body = request_body.to_json
        end

        JSON.parse(response.body) unless response.body == "{}"
      end
    end
  end
end
