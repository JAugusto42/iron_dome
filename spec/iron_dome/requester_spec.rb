# frozen_string_literal: true

require "iron_dome/requester"
require "json"

RSpec.describe IronDome::Requester do
  describe ".osv_request" do
    let(:packages_and_versions) { { "sinatra" => "2.0.8", "rails" => "6.0.3", "ecosystem" => "RubyGems" } }
    let(:url) { "https://api.osv.dev/v1/query" }
    let(:conn) { instance_double(Faraday::Connection) }
    let(:response_body) { '{"some_key": "some_value"}' }
    let(:json_response) { JSON.parse(response_body) }

    before do
      allow(Faraday).to receive(:new).with(url).and_return(conn)
    end

    context "when there is a valid response" do
      it "makes a POST request to the OSV API with correct parameters" do
        packages_and_versions.each do |package, version|
          request_body = { version: version, package: { name: package, ecosystem: "RubyGems" } }

          expect(conn).to receive(:post) do |&block|
            request = double("Faraday::Request")
            expect(request).to receive(:url).with("/v1/query")
            expect(request).to receive(:headers).and_return({})
            expect(request).to receive(:body=).with(request_body.to_json)
            block.call(request)
          end.and_return(double("Faraday::Response", body: response_body))
        end

        described_class.osv_request(packages_and_versions)
      end

      it "returns parsed JSON response" do
        allow(conn).to receive(:post).and_return(double("Faraday::Response", body: response_body))
        result = described_class.osv_request(packages_and_versions)
        expect(result).to contain_exactly(json_response, json_response, json_response)
      end
    end

    context "when there is an empty response body" do
      it "returns nil" do
        allow(conn).to receive(:post).and_return(double("Faraday::Response", body: "{}"))
        result = described_class.osv_request(packages_and_versions)
        expect(result).to contain_exactly(nil, nil, nil)
      end
    end
  end
end
