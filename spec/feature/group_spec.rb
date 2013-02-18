require 'spec_helper'
require 'feature/group'

describe Feature::Group do
  let(:backend) { stub('Feature Backend') }
  let(:group) { described_class.new(:foo, backend) }

  describe "#members" do
    it "gets them from the backend" do
      backend_response = stub
      backend.expects(:group_members).returns(backend_response)
      group.members.should == backend_response
    end
  end

  describe "#member?" do
    it "checks via the backend" do
      backend_response = stub
      backend.expects(:in_group?).with(:foo, :a).returns(backend_response)
      group.member?(:a).should == backend_response
    end
  end

  describe "#add" do
    it "adds value via the backend" do
      backend_response = stub
      backend.expects(:add_to_group).
        with(:foo, :a).
        returns(backend_response)
      group.add(:a).should == backend_response
    end
  end

  describe "#remove" do
    it "removes the value via the backend" do
      backend_response = stub
      backend.expects(:remove_from_group).
        with(:foo, :a).
        returns(backend_response)
      group.remove(:a).should == backend_response
    end
  end

  describe "#clear" do
    it "clears via the backend" do
      backend_response = stub
      backend.expects(:clear_group).
        with(:foo).
        returns(backend_response)
      group.clear.should == backend_response
    end
  end
end
