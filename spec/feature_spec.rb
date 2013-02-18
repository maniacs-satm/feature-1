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

    let(:feature_obj) { described_class.features.first }
    let(:response) { stub }

    describe ".enabled?" do
      it "delegates the decision to the feature object" do
        opts = {}
        feature_obj.expects(:enabled?).with(opts).returns(response)

        described_class.enabled?(:foo).should == response
      end

      it "passes the object which the decision should be based on" do
        feature_obj.expects(:enabled?).
          with(has_entry(:for, 'bar'))
        described_class.enabled?(:foo, for: 'bar')
      end
    end

    describe ".enable" do
      it "delegates to the selected backend" do
        feature_obj.expects(:enable)
        described_class.enable(:foo)
      end
    end

    describe ".disable" do
      it "delegates to the selected backend" do
        feature_obj.expects(:disable)
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
      it "returns the collection of feature objects" do
        described_class.features.first.should be_instance_of(Feature::Feature)
        described_class.features.first.name.should == :foo
      end
    end

    describe ".groups" do
      it "returns the groups from the backend" do
        groups = stub
        described_class.backend.expects(:groups).returns(groups)
        described_class.groups.should == groups
      end
    end


    describe "group management" do
      let(:group) { mock }

      before do
        Feature::Group.expects(:new).with(:foo, described_class.backend).returns(group)
      end

      describe ".add_to_group" do
        it "delegates to the selected backend" do
          group.expects(:add).with(:bar)
          described_class.add_to_group(:foo, :bar)
        end
      end

      describe ".remove_from_group" do
        it "delegates to the selected backend" do
          group.expects(:remove).with(:bar)
          described_class.remove_from_group(:foo, :bar)
        end
      end
    end
  end
end

