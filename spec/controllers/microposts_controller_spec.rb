require 'spec_helper'

describe MicropostsController do
  render_views
  
  describe "access control" do
    describe "for users who are not signed in" do
      it "should deny access to 'create'" do
        post :create
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'destroy'" do
        delete :destroy, :id => 1
        response.should redirect_to(signin_path)
      end
    end
  end
  
  describe "POST 'create'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end
    
    describe "failure" do
      before(:each) do
        @attr = { :content => "" }
      end
      
      it "should not create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count)
      end
    
      it "should render the home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :content => "Lorem Ipsum" }
      end
      
      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count).by(1)
      end
      
      it "should redirect to the home page" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end
      
      it "should have a flash message" do
        post :create, :micropost => @attr
        flash[:success].should =~ /created/i
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
      @mp   = @user.microposts.create!(:content => "Lorem Ipsum")
    end
    
    describe "as a non-signed in user" do
      it "should redirect to login page" do
        delete :destroy, :id => @mp
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as a signed in user" do
      before(:each) do
        test_sign_in(@user)
      end
      
      describe "deleting someone else's post" do
        it "should deny access" do
          other = Factory(:user, :email => "example@example.net")
          mp    = other.microposts.create!(:content => "asdasdf")
          
          delete :destroy, :id => mp
          response.should redirect_to(root_path)
        end
      end
      
      describe "deleting their own post" do
        it "should delete a post" do
          lambda do
            delete :destroy, :id => @mp
          end.should change(Micropost, :count).by(-1)
        end
      end
      
      describe "as an admin deleting someone else's post" do
        before(:each) do
          @admin = Factory(:user, :email => "admin@example.net", :admin => true)
          @other = Factory(:user, :email => "example@example.net")
          @mp    = @other.microposts.create!(:content => "adfasdfasfd")
          
          test_sign_in(@admin)
        end
        
        it "should delete the post" do
          lambda do
            delete :destroy, :id => @mp
          end.should change(Micropost, :count).by(-1)
        end
      end
    end
  end
end
