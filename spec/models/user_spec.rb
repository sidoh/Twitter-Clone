require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => 'chris.mullins',
      :email => 'user@example.com',
      :password => 'vagabond',
      :password_confirmation => 'vagabond'
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
  
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => '', :password_confirmation => ''))
        .should_not be_valid
    end
    
    it "should have matching password and password confirmation" do
      User.new(@attr.merge(:password_confirmation => 'hermit'))
        .should_not be_valid
    end
    
    it "should NOT accept short passwords" do
      User.new(@attr.merge(:password => 'a', :password_confirmation => 'a'))
        .should_not be_valid
    end
  end
  
  describe "password hashing" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have a password hash attribute" do
      @user.should respond_to(:password_hash)
    end
    
    it "should generate the password hash" do
      @user.password_hash.should_not be_blank
    end

    describe "password authentication" do
      it "should pass if the passwords match" do
        @user.password_is?(@attr[:password]).should be_true
      end
      
      it "should fail if passwords do not match" do
        @user.password_is?(@attr[:password]+'wrong').should be_false
      end
    end
    
    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], @attr[:password]+'wrong')
          .should be_nil
      end
      
      it "should return nil for an e-mail address with no user" do
        User.authenticate('wrong-'+@attr[:email], @attr[:password])
          .should be_nil
      end
      
      it "should return the appropriate user when email/password match" do
        User.authenticate(@attr[:email], @attr[:password])
          .should == @user
      end
    end
  end
  
  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  
  describe "user micropost associations" do
    before(:each) do
      @user = User.create(@attr)
      @mp1  = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2  = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
    
    it "should have the microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end
  end
  
  describe "status feed" do
    before(:each) do
      @user = User.create(@attr)
      @mp1  = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2  = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end
    
    it "should have a feed" do
      @user.should respond_to(:feed)
    end
    
    it "should include the user's microposts" do
      @user.feed.include?(@mp1).should be_true
      @user.feed.include?(@mp2).should be_true
    end
  end
  
end
