# frozen_string_literal: true

require "iron_dome/reader"

RSpec.describe IronDome::Reader do
  let(:reader) { described_class.new }

  describe "#call" do
    context "when lock files are present" do
    end

    context "when no lock files are present" do
    end
  end

  describe "#read_file" do
    it "reads the lock file, extracts packages and versions, and makes an OSv API request" do
    end
  end

  describe "#output_report_sarif" do
  end
end
