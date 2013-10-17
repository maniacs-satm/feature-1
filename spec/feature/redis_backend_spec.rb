require 'spec_helper'
require 'feature/redis_backend'

describe Feature::RedisBackend do
  subject do
    Feature::RedisBackend.new($redis, namespace: 'feature-test')
  end
  let(:redis) { subject.redis }

  before { subject.reset! }

  describe "#initialize" do
    context "with a namespaced redis connection" do
      subject do
        ns = Redis::Namespace.new "ns", $redis
        Feature::RedisBackend.new(ns)
      end
      it "uses the namespaced connection" do
        redis.namespace.should == "ns"
      end
    end

    context "with a redis connection" do
      subject do
        Feature::RedisBackend.new($redis, namespace: 'feature-test')
      end
      it "creates a new namespaced connection" do
        redis.namespace.should == "feature-test"
      end
    end

    context "with an invalid connection" do
      it "raises an error" do
        expect { Feature::RedisBackend.new(nil) }.to raise_error
      end
    end
  end

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

        result = subject.enabled?(:foo, groups: [:employees],
                                        for: 'alan')
        result.should be_true
      end

      context "when globally disabled" do
        before { redis.set('foo', 'disabled') }

        context "with groups passed" do
          it "returns false with no group members passed" do
            result = subject.enabled?(:foo, groups: ["foo"], default: false)
            result.should be_false
          end
        end

        it "returns true if enabled at least in one of the groups" do
          subject.add_to_group('employees', 'alan')
          result = subject.enabled?(:foo, groups: [:employees, :beta],
                                          for: 'alan')
          result.should be_true
        end

        it "returns false if not enabled in any of the groups" do
          result = subject.enabled?(:foo, groups: [:employees, :beta],
                                          for: 'alan')
          result.should be_false
        end

        context "when for_any option is passed" do
          it "returns false if not enabled for any items" do
            subject.enabled?(:foo, for_any: true, for_any: ["a", "b"])
              .should be_false
          end

          it "returns true if enabled for one item" do
            subject.add_to_group('employees', 'alan')
            result = subject.enabled?(:foo, groups: [:employees],
                                        for_any: ["alan", "andy"])
            result.should be_true
          end
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

  describe "#add_to_group" do
    it "adds a value to the group set" do

      subject.add_to_group('admin', 'a')
      subject.add_to_group('admin', 'b')

      redis.smembers(subject.group_key('admin')).should include('a', 'b')
    end
  end

  describe "#remove_from_group" do
    it "removes a value from the group set" do

      subject.add_to_group('admin', 'a')
      subject.add_to_group('admin', 'b')

      subject.remove_from_group('admin', 'b')
      redis.smembers(subject.group_key('admin')).should == ['a']
    end
  end

  describe "#get_group_members" do
    before do
      subject.add_to_group("admin", "1")
      subject.add_to_group("admin", "2")
    end

    it "lists group members" do
      subject.get_group_members("admin").should == %w(1 2)
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

    context "with one item" do
      it "returns false if is not the group" do
        subject.add_to_group('admin', '1')

        subject.in_group?('admin', '2').should be_false
      end

      it "returns true if is in the group" do
        subject.add_to_group('admin', '1')

        subject.in_group?('admin', '1').should be_true
      end
    end

    context "with multiple items" do
      it "returns false if all are not in the group" do
        subject.add_to_group('admin', '1')

        subject.in_group?('admin', ['1', '2']).should be_false
      end

      it "returns true if all are in the group" do
        subject.add_to_group('admin', '1')
        subject.add_to_group('admin', '2')

        subject.in_group?('admin', ['1', '2']).should be_true
      end
    end
  end

  describe "#any_in_group?" do
    it "returns false if the group is not defined" do
      subject.any_in_group?('admin', ['1']).should be_false
    end

    it "returns true if one is in the group" do
      subject.add_to_group('admin', '1')

      subject.any_in_group?('admin', ['1', '2']).should be_true
    end

    it "returns true if all are in the group" do
      subject.add_to_group('admin', '1')
      subject.add_to_group('admin', '2')

      subject.any_in_group?('admin', ['1', '2']).should be_true
    end
  end
end
