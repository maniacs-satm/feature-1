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

  describe "#enabled?" do
    context "with no groups" do
      let(:feature) { described_class.new(:foo, backend) }

      it "returns true if globally enabled" do
        backend.expects(:globally_enabled?).
          with(feature.name).
          returns(true)

        feature.enabled?
      end

      it "returns the default otherwise" do
        backend.expects(:globally_enabled?).
          with(feature.name).
          returns(false)

        default = stub
        feature.stubs(:default).returns(default)

        feature.enabled?.should == default
      end
    end

    context "with groups" do
      let(:feature) { described_class.new(:foo, backend, groups: [:foo]) }

      it "returns true if globally enabled" do
        backend.expects(:globally_enabled?).
          with(feature.name).
          returns(true)

        feature.enabled?(for: :value).should == true
      end

      context "and not globally enabled" do
        before { backend.expects(:globally_enabled?).returns(false) }

        it "returns the default if not if in one of the groups" do
          Feature::Group.any_instance.
            expects(:member?).
            with(:value).
            returns(false)

          default = stub
          feature.stubs(:default).returns(default)

          feature.enabled?(for: :value).should == default
        end

        it "returns the default if there is no group value to check" do
          Feature::Group.any_instance.
            stubs(:member?).
            returns(true)

          default = stub
          feature.stubs(:default).returns(default)

          feature.enabled?.should == default
        end

        it "returns true if in one of the groups" do
          Feature::Group.any_instance.
            expects(:member?).
            with(:value).
            returns(true)

          feature.enabled?(for: :value).should be_true
        end
      end
    end
  end

  describe "#members" do
    it "returns ':all' if globally enabled" do
      feature = described_class.new(:foo, backend)

      backend.expects(:globally_enabled?).
        with(feature.name).
        returns(true)

      feature.members.should == :all
    end

    context "when not globally enabled and groups" do
      let(:feature) { described_class.new(:foo, backend, groups: [:g1, :g2]) }

      before { backend.stubs(:globally_enabled?).returns(false) }

      it "returns the members of all the groups" do
        Feature::Group.any_instance.stubs(:members).
          returns([:a, :b]).returns([:b, :c])
        members = feature.members
        members.size.should == 3
        members.should include(:a, :b, :c)
      end
    end

    context "when not globally enabled and no groups" do
      let (:feature) { described_class.new(:foo, backend) }

      before { backend.stubs(:globally_enabled?).returns(false) }

      it "returns ':all' if enabled by default" do
        feature.expects(:default).returns(true)
        feature.members.should == :all
      end

      it "returns an empty collection if disabled by default" do
        feature.expects(:default).returns(false)
        feature.members.should be_empty
      end
    end
  end
end
