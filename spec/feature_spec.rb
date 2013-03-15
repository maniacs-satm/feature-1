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

    describe ".enabled?" do
      it "delegates the decision to the selected backend" do
        described_class.backend.expects(:enabled?).with(:foo, default: true)
        described_class.enabled?(:foo)
      end

      it "passes the object which the decision should be based on" do
        described_class.backend.expects(:enabled?).
          with(:foo, has_entry(:for, 'bar'))
        described_class.enabled?(:foo, for: 'bar')
      end

      it "prefers :for over :for_all" do
        described_class.backend.expects(:enabled?).
          with(:foo, has_entry(:for, "1"), Not(has_entry(:for_any, ["2"])))
        described_class.enabled?(:foo, for: "1", for_all: ["2"])
      end

      it "passes :for_any through" do
        described_class.backend.expects(:enabled?).
          with(:foo, has_entry(:for_any, ["1", "2"]))
        described_class.enabled?(:foo, for_any: ["1", "2"])
      end
    end

    describe ".enable" do
      it "delegates to the selected backend" do
        described_class.backend.expects(:enable).with(:foo)
        described_class.enable(:foo)
      end
    end

    describe ".disable" do
      it "delegates to the selected backend" do
        described_class.backend.expects(:disable).with(:foo)
        described_class.disable(:foo)
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
end

