require 'stronger_parameters'
Bundler.require(:test)

RSpec.configure do |config|
  config.color_enabled = true
end

shared_examples "nested parameters" do
  it "errors if not allowed params are passed" do
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

describe "nested parameters using block" do
  it_behaves_like "nested parameters"

  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates_nested :page do |page|
        page.validates :name, allowed: true
      end

    end
  end
end

describe "nested parameters using with option" do
  it_behaves_like "nested parameters"

  subject do
    with_option = Class.new(StrongerParameters) do
      validates :name, allowed: true
    end

    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates_nested :page, with: with_option
    end
  end
end

describe "options: on" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, presence: true, :on => :show
    end
  end

  it "does not add an error when validation passes for context" do
    c = subject.new(name: 'ok')
    c.valid?(:show)
    c.errors.should be_empty
  end

  it "adds an error when validation fails for context" do
    c = subject.new()
    c.valid?(:show)
    c.errors.should_not be_empty
  end

  it "only validates on the specified context" do
    c = subject.new()
    c.valid?
    c.errors.should be_empty
  end
end

describe "options: length" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, length: {minimum: 12}
    end
  end

  it "adds an error when validation fails" do
    c = subject.new(name: '< 12')
    c.valid?
    c.errors[:name].should == ["is too short (minimum is 12 characters)"]
  end

  it "does not add an error when validation passes" do
    c = subject.new(name: 'more than 12 characters')
    c.valid?
    c.errors.should be_empty
  end
end

describe "exclusion" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, exclusion: ['a', 'b']
    end
  end

  it "adds an error when the value is in the list" do
    c = subject.new(name: 'a')
    c.valid?
    c.errors[:name].should == ["is reserved"]
  end

  it "does not add an error when the value is not in the list" do
    c = subject.new(name: 'neither a nor b')
    c.valid?
    c.errors.should be_empty
  end
end

describe "inclusion" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, inclusion: ['a', 'b']
    end
  end

  it "adds an error when value is not in list" do
    c = subject.new(name: 'neither a nor b')
    c.valid?
    c.errors.should_not be_empty
  end

  it "does not add an error when value is in list" do
    c = subject.new(name: 'a')
    c.valid?
    c.errors.should be_empty
  end
end

describe "allowed" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, :age, allowed: true
    end
  end

  it "allows the parameters" do
    c = subject.new(name: 'a value', age: 22)
    c.valid?
    c.errors.should be_empty
  end

  it "adds an error when any other paramter is passed" do
    c = subject.new(notallowed: 'a value')
    c.valid?
    c.errors.messages[:notallowed].should == ["is not allowed"]
  end

  it "does not add an error when allowed params are omitted" do
    c = subject.new(age: 22) # name not passed
    c.valid?
    c.errors.should be_empty
  end
end

describe "required" do
  subject do
    Class.new(StrongerParameters) do
      def self.name
        "Anonymous"
      end

      validates :name, presence: true
    end
  end

  it "does not add an error when the parameter is present" do
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