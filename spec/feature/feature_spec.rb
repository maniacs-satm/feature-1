require 'spec_helper'

describe Feature::Feature do
  let(:backend) { Feature::RedisBackend.new($redis) }

  before do
    backend_cls = backend
    Feature.configure do
      feature :foo
      #backend backend_cls
    end
  end

  let(:feature) { Feature::Feature.new(:foo, default: true) }
  before { feature.stubs(backend: backend) }

  describe ".enabled?" do
    it "delegates the decision to the selected backend" do
      backend.expects(:enabled?).with(:foo, default: true)
      feature.enabled?
    end
  end

  describe ".enabled_for?" do
    it "passes the object which the decision should be based on" do
      backend.expects(:enabled?).with(:foo, has_entry(:for, 'bar'))
      feature.enabled_for?('bar')
    end

    it "cries if it gets an array" do
      expect { feature.enabled_for?(['bar']) }.to raise_error(ArgumentError)
    end
  end

  describe ".enabled_for_all?" do
    it "passes :for_all through" do
      backend.expects(:enabled?).with(:foo, has_entry(:for_all, ['1', '2']))
      feature.enabled_for_all?(['1', '2'])
    end

    it "cries if it doesn't get an array" do
      expect { feature.enabled_for_all?('bar') }.to raise_error(ArgumentError)
    end
  end

  describe ".enabled_for_any?" do
    it "passes :for_any through" do
      backend.expects(:enabled?).with(:foo, has_entry(:for_any, ['1', '2']))
      feature.enabled_for_any?(['1', '2'])
    end

    it "cries if it doesn't get an array" do
      expect { feature.enabled_for_any?('bar') }.to raise_error(ArgumentError)
    end
  end

  describe ".enable" do
    it "delegates to the selected backend" do
      backend.expects(:enable).with(:foo)
      feature.enable
    end
  end

  describe ".disable" do
    it "delegates to the selected backend" do
      backend.expects(:disable).with(:foo)
      feature.disable
    end
  end
end

