require 'spec_helper'
require 'feature/redis_backend'

describe Feature::RedisBackend do
  subject do
    Feature::RedisBackend.new($redis, namespace: 'feature-test')
  end
  let(:redis) { subject.redis }

  before { subject.reset! }

  describe "#reset!" do
    it "clears out any set keys" do
      redis.set('foo', 'bar')
      subject.reset!
      redis.get('foo').should be_nil
    end
  end

  describe "#feature_globally_enabled?" do
    context "when the feature is enabled in redis" do
      before { redis.set('foo', 'enabled') }

      it "returns true with true as the default" do
        subject.feature_globally_enabled?(:foo).should be_true
      end

      it "returns true with false as the default" do
        subject.feature_globally_enabled?(:foo).should be_true
      end
    end

    context "when the feature is disabled in redis" do
      before { redis.set('foo', 'disabled') }

      it "returns false with true as the default" do
        subject.feature_globally_enabled?(:foo).should be_false
      end

      it "returns false with false as the default" do
        subject.feature_globally_enabled?(:foo).should be_false
      end
    end

    context "when the feature is missing from redis" do
      it "returns true with true as the default" do
        subject.feature_globally_enabled?(:foo).should be_nil
      end

      it "returns false with false as the default" do
        subject.feature_globally_enabled?(:foo).should be_nil
      end
    end
  end

  describe "#enable" do
    it "enables a previously unspecified feature" do
      subject.enable(:foo)
      subject.enabled?(:foo, default: false).should be_true
    end

    it "enables a previously disabled feature" do
      redis.set('foo', 'disabled')
      subject.enable(:foo)
      subject.enabled?(:foo, default: false).should be_true
    end
  end

  describe "#disable" do
    it "disables a previously unspecified feature" do
      subject.disable(:foo)
      subject.enabled?(:foo, default: true).should be_false
    end

    it "enables a previously disabled feature" do
      redis.set('foo', 'enabled')
      subject.disable(:foo)
      subject.enabled?(:foo, default: true).should be_false
    end
  end

  describe "#add_to_group" do
    it "adds a value to the group set" do

      subject.add_to_group('admin', 'a')
      subject.add_to_group('admin', 'b')

      redis.smembers(subject.group_key('admin')).should include('a', 'b')
    end
  end

  describe "#remove_to_group" do
    it "removes a value from the group set" do

      subject.add_to_group('admin', 'a')
      subject.add_to_group('admin', 'b')

      subject.remove_from_group('admin', 'b')
      redis.smembers(subject.group_key('admin')).should == ['a']
    end
  end

  describe "#group_key" do
    it "prefixes the redis key with 'group:'" do
      subject.group_key('admin').should start_with('group:')
    end
  end

  describe "#in_group?" do
    it "returns false if the group is not defined" do
      subject.in_group?('admin', '1').should be_false
    end

    it "returns false if is not the group" do
      subject.add_to_group('admin', '1')

      subject.in_group?('admin', '2').should be_false
    end

    it "returns true if is in the group" do
      subject.add_to_group('admin', '1')

      subject.in_group?('admin', '1').should be_true
    end
  end
end
