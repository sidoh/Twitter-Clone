require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => 'Example User',
      :email => 'user@example.com'
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    User.new(@attr.merge(:name => '')).should_not be_valid
  end
  
  it "should reject names that are too long" do
    User.new(@attr.merge(:name => 'a'*51)).should_not be_valid
  end
  
  it "should accept valid e-mail addresses" do
    %w{user@foo.com THE_USER@foo.bar.org first.last@foo.ip}.each do |a|
      User.new(@attr.merge(:email => a)).should be_valid
    end
  end
  
  it "should NOT accept INVALID e-mail addresses" do
    %w{!#@f.com user_at_foo.org example.user@foo. user@foo,com}.each do |a|
      User.new(@attr.merge(:email => a)).should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    User.new(@attr.merge(:email => @attr[:email].upcase)).should_not be_valid
  end
end
