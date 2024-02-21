# frozen_string_literal: true

RSpec.describe IronDome::Reader do
  describe "#initialize" do
    it "initializes with options" do
      options = { sarif_output: true }
      reader = described_class.new(options)
      expect(reader.options).to eq(options)
    end
  end

  describe "#process_lock_file" do
    let(:file) { "Gemfile.lock" }

    it "reads the lock file and processes it" do
      allow(File).to receive(:read).with(file).and_return("package (1.0.0)\n")
      allow(IronDome::Requester).to receive(:osv_request).and_return([])

      reader = described_class.new({})
      results = reader.send(:process_lock_file, file)

      expect(results).to be_nil
    end
  end

  describe "#output_sarif_file_format" do
    it "generates SARIF output" do
      results = []
      expect_any_instance_of(IronDome::Sarif::Output).to receive(:output_report).with(results)
      reader = described_class.new(sarif_output: true)
      reader.send(:output_sarif_file_format, results)
    end
  end

  describe "#system_output" do
    it "outputs results to the shell" do
      results = []
      expect { described_class.new({}).send(:system_output, results) }.to output("\e[0;32;49mNo vulnerabiities founded\e[0m\n").to_stdout
    end
  end
end
