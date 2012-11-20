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
        subject.enabled?(:foo, default: true).should be_true
      end

      it "returns true with false as the default" do
        subject.enabled?(:foo, default: false).should be_true
      end
    end

    context "when the feature is disabled in redis" do
      before { redis.set('foo', 'disabled') }

      it "returns false with true as the default" do
        subject.enabled?(:foo, default: true).should be_false
      end

      it "returns false with false as the default" do
        subject.enabled?(:foo, default: false).should be_false
      end
    end

    context "when the feature is missing from redis" do
      it "returns true with true as the default" do
        subject.enabled?(:foo, default: true).should be_true
      end

      it "returns false with false as the default" do
        subject.enabled?(:foo, default: false).should be_false
      end
    end

    context "when is enabled for a group" do
      it "returns true if globally enabled (regardless of the groups)" do
        redis.set('foo', 'enabled')

        result = subject.enabled?(:foo, enabled_groups: [:employees],
                                        value: 'alan')
        result.should be_true
      end

      context "when globally disabled" do
        before { redis.set('foo', 'disabled') }

        it "returns true if enabled at least in one of the groups" do
          subject.new_group('employees', 'alan')
          result = subject.enabled?(:foo, enabled_groups: [:employees, :beta],
                                          value: 'alan')
          result.should be_true
        end

        it "returns false if not enabled in any of the groups" do
          result = subject.enabled?(:foo, enabled_groups: [:employees, :beta],
                                          value: 'alan')
          result.should be_false
        end
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

  describe "#new_group" do
    it "adds the values to the group set" do
      subject.new_group('admin', 'a', 'c', 'r')

      group_members = redis.smembers(subject.group_key('admin'))
      group_members.size.should == 3
      group_members.should include('a', 'c', 'r')
    end

    it "deletes the previous group" do
      subject.new_group('admin', 'a')
      subject.new_group('admin', 'b')

      redis.smembers(subject.group_key('admin')).should_not include('a')
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
      subject.new_group('admin', '1')

      subject.in_group?('admin', '2').should be_false
    end

    it "returns true if is in the group" do
      subject.new_group('admin', '1')

      subject.in_group?('admin', '1').should be_true
    end
  end
end
