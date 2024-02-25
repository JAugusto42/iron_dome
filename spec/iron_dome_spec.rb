# frozen_string_literal: true

RSpec.describe IronDome do
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
