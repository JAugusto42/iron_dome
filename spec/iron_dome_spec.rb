# frozen_string_literal: true

RSpec.describe IronDome do
  let(:body) { File.read("spec/files/requests_responses/success_response_with_vulns.json") }
  let(:request) do
    stub_request(:post, "https://api.osv.dev/v1/query")
      .with(
        body: { version: "2.8.6", package: { name: "addressable" } }.to_json,
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/json",
          "User-Agent" => "Faraday v2.9.0"
        }
      )
      .to_return(status: 200, body: body, headers: {})
  end

  it "has a version number" do
    expect(IronDome::VERSION).not_to be nil
  end

  describe "#Main" do
    context "when options are provided, but no vulnerabilities was founded" do
      it "output must include No vulnerabilities founded" do
        allow(OptionParser).to receive(:new).and_return(double(parse!: { sarif_output: true, detail: true }))
        expect { described_class::Entry.new.main }.to output(/Verifying vulnerabilities on osv database/).to_stdout
      end
    end

    context "when no options are provided, but no vulnerabilities was founded" do
      it "output must include No vulnerabilities founded" do
        allow(OptionParser).to receive(:new).and_return(double(parse!: {}))
        expect { described_class::Entry.new.main }.to output(/Verifying vulnerabilities on osv database/).to_stdout
      end
    end
  end
end
