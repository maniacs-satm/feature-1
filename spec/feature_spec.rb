require 'spec_helper'

describe Feature do
  before { Feature.configure { backend Feature::RedisBackend } }

  describe ".config" do
    it "passes the block to FeatureConfig's constructor" do
      block = Proc.new {}
      config = stub(features: {}, backend_obj: nil)
      Feature::Config.expects(:new).with(block).returns(config)
      described_class.configure(&block)
    end
  end

  context do
    before do
      # The backend should already be set up in config/initializers/feature.rb
      described_class.configure do
        feature :foo
      end
    end

    describe ".check_feature_defined" do
      it "does nothing when given a defined feature" do
        expect do
          described_class.check_feature_defined(:foo)
        end.to_not raise_error
      end

      it "throws an exception if the feature is undefined" do
        expect do
          described_class.check_feature_defined(:bar)
        end.to raise_error
      end
    end

    describe ".features" do
      it "returns the feature definition hash" do
        described_class.features.should include(foo: {default: true})
      end
    end

    describe ".add_to_group" do
      it "delegates to the selected backend" do
        described_class.backend.expects(:add_to_group).with(:foo, :bar)
        described_class.add_to_group(:foo, :bar)
      end
    end

    describe ".remove_from_group" do
      it "delegates to the selected backend" do
        described_class.backend.expects(:remove_from_group).with(:foo, :bar)
        described_class.remove_from_group(:foo, :bar)
      end
    end
  end

  describe "Feature method" do
    context "given an invalid name" do
      specify { expect { Feature(:bar) }.to raise_error }
    end

    context "given an valid name" do
      specify { Feature(:foo).should be_a Feature::Feature }
    end
  end
end

