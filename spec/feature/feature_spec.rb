require 'spec_helper'
require 'feature/feature'

describe Feature::Feature do
  let(:backend) { stub('Feature Backend') }

  describe "#groups" do
    it "returns an empty collection if it doesn't have any" do
      feature = described_class.new(:foo, backend)
      feature.groups.should be_empty
    end

    it "returns a collection of the groups if any" do
      feature = described_class.new(:foo, backend, groups: [:group1])
      feature.groups.size.should == 1
      feature.groups.first.name.should == :group1
    end
  end

  describe "#default" do
    it "is true when not configured" do
      feature = described_class.new(:foo, backend)
      feature.default.should be_true
    end

    it "can be configured to other values" do
      feature = described_class.new(:foo, backend, { default: false })
      feature.default.should be_false
    end
  end

  describe "#enable" do
    it "enables it through the backend" do
      feature = described_class.new(:foo, backend)
      feature.backend.expects(:enable).with(feature.name)
      feature.enable
    end
  end

  describe "#disable" do
    it "enables it through the backend" do
      feature = described_class.new(:foo, backend)
      feature.backend.expects(:disable).with(feature.name)
      feature.disable
    end
  end
end
