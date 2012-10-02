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

  describe "#enabled?" do
    context "when the feature is enabled in redis" do
      before { redis.set('foo', 'enabled') }

      it "returns true with true as the default" do
        subject.enabled?(:foo, true).should be_true
      end

      it "returns true with false as the default" do
        subject.enabled?(:foo, false).should be_true
      end
    end

    context "when the feature is disabled in redis" do
      before { redis.set('foo', 'disabled') }

      it "returns false with true as the default" do
        subject.enabled?(:foo, true).should be_false
      end

      it "returns false with false as the default" do
        subject.enabled?(:foo, false).should be_false
      end
    end

    context "when the feature is missing from redis" do
      it "returns true with true as the default" do
        subject.enabled?(:foo, true).should be_true
      end

      it "returns false with false as the default" do
        subject.enabled?(:foo, false).should be_false
      end
    end
  end

  describe "#enable" do
    it "enables a previously unspecified feature" do
      subject.enable(:foo)
      subject.enabled?(:foo, false).should be_true
    end

    it "enables a previously disabled feature" do
      redis.set('foo', 'disabled')
      subject.enable(:foo)
      subject.enabled?(:foo, false).should be_true
    end
  end

  describe "#disable" do
    it "disables a previously unspecified feature" do
      subject.disable(:foo)
      subject.enabled?(:foo, true).should be_false
    end

    it "enables a previously disabled feature" do
      redis.set('foo', 'enabled')
      subject.disable(:foo)
      subject.enabled?(:foo, true).should be_false
    end
  end
end

