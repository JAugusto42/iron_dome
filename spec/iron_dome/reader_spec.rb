# frozen_string_literal: true

require "iron_dome/reader"

RSpec.describe IronDome::Reader do
  let(:reader) { described_class.new }

  describe "#call" do
    context "when lock files are present" do
      it "reads the lock file and makes an OSv API request" do
        allow(reader).to receive(:read_file)
        expect(IronDome::Requester).to receive(:osv_request).and_return("result")

        reader.call
      end
    end

    context "when no lock files are present" do
      it "does not make an OSv API request" do
        allow(Dir).to receive(:glob).and_return([]) # no lock files
        expect(IronDome::Requester).not_to receive(:osv_request)

        reader.call
      end
    end
  end

  describe "#read_file" do
    it "reads the lock file, extracts packages and versions, and makes an OSv API request" do
      file_content = "package1 (1.0)\npackage2 (2.0)\n"
      allow(File).to receive(:read).and_return(file_content)
      expect(IronDome::Requester).to receive(:osv_request).with({ "package1" => "1.0",
                                                                  "package2" => "2.0" }).and_return("result")

      reader.send(:read_file)
    end
  end

  describe "#output_report_sarif" do
  end
end
