require_relative 'lib'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
end

describe "validating nested params" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates_nested :page do |page|
        page.validates :name, allowed: true
      end

    end
  end

  it "errors if not allowed paras are passed" do
    c = subject.new(page: {notallowed: 'NO.'})
    c.valid?
    c.errors.should_not be_empty
  end

  it "works with nested hashes" do
    c = subject.new(page: {name: 'OK'})
    c.valid?
    c.errors.should be_empty
  end

  it "works with nested arrays" do
    c = subject.new(page: [ {name: 'OK'}, {name: 'OK'} ])
    c.valid?
    c.errors.should be_empty
  end
end


describe "supports on" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates :name, presence: true, :on => :show
    end
  end

  it "passes validation when correct properties are passed" do
    c = subject.new(name: 'ok')
    c.valid?(:show)
    c.errors.should be_empty
  end

  it "fails validation when bad properties are passed" do
    c = subject.new()
    c.valid?(:show)
    c.errors.should_not be_empty
  end

  it "only validates on the specified action" do
    c = subject.new()
    c.valid?
    c.errors.should be_empty
  end
end

describe "exclusion" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates :name, inclusion: ['a', 'b']
    end
  end

  it "errors" do
    c = subject.new(name: 'neither a nor b')
    c.valid?
    c.errors.should_not be_empty
  end
end

describe "inclusion" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates :name, inclusion: ['a', 'b']
    end
  end

  it "errors when not in list" do
    c = subject.new(name: 'neither a nor b')
    c.valid?
    c.errors.should_not be_empty
  end

  it "does not error when in list" do
    c = subject.new(name: 'a')
    c.valid?
    c.errors.should be_empty
  end
end

describe "allowed params" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates :name, allowed: true
    end
  end

  it "allows the parameter" do
    c = subject.new(name: 'a value')
    c.valid?
    c.errors.should be_empty
  end

  it "adds an error when the any other paramter is passed" do
    c = subject.new(notallowed: 'a value')
    c.valid?
    c.errors.messages[:notallowed].should == ["is not allowed"]
  end
end

describe "required params" do
  subject do
    Class.new(Parameters) do
      def self.name
        "Anonymous"
      end

      validates :name, presence: true
    end
  end

  it "allows the parameter" do
    c = subject.new(name: 'a value')
    c.valid?
    c.errors.should be_empty
  end

  it "adds an error when the parameter is missing" do
    c = subject.new()
    c.valid?
    c.errors.messages[:name].should == ["can't be blank"]
  end
end