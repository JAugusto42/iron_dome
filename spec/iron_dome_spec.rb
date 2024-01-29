# frozen_string_literal: true

RSpec.describe IronDome do
  let(:result) { IronDome::Entry.new.main }

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
      .to_return(status: 200, body: "", headers: {})
  end

  it "has a version number" do
    expect(IronDome::VERSION).not_to be nil
  end

  describe ".Main" do
    context "success" do
      it "return an json object" do
        request
        expect(request.response.status.first).to eq(200)
      end
    end
  end
end
