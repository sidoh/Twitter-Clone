require 'spec_helper'

describe SessionsController do
  
  render_views

  describe "GET 'new'" do
    describe "for users who are not yet signed in" do
      it "should be successful" do
        get 'new'
        response.should be_success
      end
    end
    
    describe "for users who are already signed in" do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should redirect to user profile" do
        get :new
        response.should redirect_to user_path(@user)
      end
      
      it "should inform the user that they are already logged in" do
        get :new
        flash[:info].should =~ /already/i
      end
    end
  end
  
  describe "POST 'create'" do
    describe "invalid signin" do
      before(:each) do
        @attr = {
          :email => 'asdf@asdf.com',
          :password => 'short'
        }
      end
      
      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
      
      it "should have an error message" do
        post :create, :session => @attr
        flash[:error].should =~ /invalid login/i
      end
    end
    
    describe "valid signin" do
      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end
      
      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
      
      it "should redirect to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    it "should sign a user out" do
      test_sign_in(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end

end