require 'spec_helper'
require 'feature/config'

describe Feature::Config do
  subject { described_class.new(Proc.new {}) }

  describe "#feature" do
    it "doesn't allow two features with the same name" do
      expect do
        subject.feature :foo, default: :on
        subject.feature :foo, default: :off
      end.to raise_error
    end

    it "adds features to the feature definitions list" do
      subject.feature :foo, default: :on
      subject.features.should include :foo
    end

    it "defaults 'default' to true" do
      subject.feature :foo
      subject.features[:foo][:default].should be_true
    end

    it "accepts definitions with no options" do
      expect { subject.feature :foo }.to_not raise_error
    end

    it "sets backend_obj to the given backend" do
      backend = stub
      subject.backend backend
      subject.backend_obj.should == backend
    end
  end
end
