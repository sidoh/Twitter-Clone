require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have the right title" do
      get 'new'
      response.should have_selector('title', :content => 'Sign Up')
    end
    
    describe "for already logged-in users" do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should render their profile" do
        get :new
        response.should redirect_to(user_path(@user))
      end
      
      it "should inform the user that they are already logged in" do
        get :new
        flash[:info].should =~ /already/i
      end
    end
  end
  
  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Post134")
      mp2 = Factory(:micropost, :user => @user, :content => "Post234")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end
  end
  
  describe "POST 'create'" do
    before(:each) do
      @attr = {
        :name => '',
        :email => '',
        :password => '',
        :password_confirmation => ''
      }
    end
    
    it "should not create a user" do
      lambda do
        post :create, :user => @attr
      end.should_not change(User, :count)
    end
    
    it "should render the 'new' page" do
      post :create, :user => @attr
      response.should render_template('new')
    end
    
    describe "create a user" do
      before(:each) do
        @attr = {
          :name => 'steve',
          :email => 'steve@apple.com',
          :password => 'macsrule',
          :password_confirmation => 'macsrule'
        }
      end
      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /thanks for registering/i
      end
      
      it "should automatically log a user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url)
    end
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      before(:each) do
        @attr = {
          :email => '',
          :name => '',
          :password => '',
          :password_confirmation => ''
        }
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = {
          :name => @user.name + '2',
          :email => 'new-' + @user.email,
          :password => 'new-' + @user.password,
          :password_confirmation => 'new-' + @user.password
        }
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end
      
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed-in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        get :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe "GET 'index'" do
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
      
      it "should not display delete links" do
        get :index
        response.should_not have_selector("a", :content => 'delete')
      end
    end
    
    describe "for signed-in users" do
      before(:each) do
        @user  = test_sign_in(Factory(:user))
        second = Factory(:user, :email => '123@123.com')
        third  = Factory(:user, :email => '123@321.net')
        
        @users = [@user, second, third]
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end
      
      describe "that are non-admins" do
        it "should not display delete links" do
          get :index
          response.should_not have_selector("a", :content => 'delete')
        end
      end
      
      describe "that are admins" do
        before(:each) do
          admin = Factory(:user, :email => "123@123123.com", :admin => true)
          test_sign_in(admin)
        end
        
        it "should display delete links" do
          get :index
          response.should have_selector("a", :content => 'delete')
        end
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    
    describe "as an admin user" do
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        @other = Factory(:user, :email => "other@example.com")
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @other
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @other
        response.should redirect_to(users_path)
      end
      
      it "should not allow admins to delete themselves" do
        delete :destroy, :id => @admin
        flash[:error].should =~ /cannot/i
        response.should redirect_to(users_path)
      end
    end
  end

end
