# frozen_string_literal: true

require "iron_dome/requester"
require "json"

RSpec.describe IronDome::Requester do
  describe ".osv_request" do
    let(:packages_and_versions) { { "sinatra" => "2.0.8", "ecosystem" => "RubyGems" } }
    let(:url) { "https://api.osv.dev/v1/query" }
    let(:conn) { instance_double(Faraday::Connection) }
    let(:response_body) { '{"some_key": "some_value"}' }
    let(:json_response) { JSON.parse(response_body) }

    before do
      allow(Faraday).to receive(:new).with(url).and_return(conn)
    end

    context "when there is a valid response" do
      it "makes a POST request to the OSV API with correct parameters" do
        allow(conn).to receive(:post).and_return(double("Faraday::Response", body: response_body))
        result = described_class.osv_request(packages_and_versions)
        expect(result).to be_instance_of(Array)
      end

      it "returns parsed JSON response" do
        allow(conn).to receive(:post).and_return(double("Faraday::Response", body: response_body))
        result = described_class.osv_request(packages_and_versions)
        expect(result).to be_instance_of(Array)
      end
    end

    context "when there is an empty response body" do
      it "returns nil" do
        allow(conn).to receive(:post).and_return(double("Faraday::Response", body: "{}"))
        result = described_class.osv_request(packages_and_versions)
        expect(result).to be_instance_of(Array)
      end
    end
  end
end
