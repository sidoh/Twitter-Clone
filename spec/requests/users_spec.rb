require 'spec_helper'

describe "Users" do
  describe "signup" do
    describe "failure" do
      it "should not create a new user" do
        lambda do
          visit signup_path
          fill_in 'Name',             :with => ''
          fill_in 'Email',            :with => ''
          fill_in 'Password',         :with => ''
          fill_in 'Confirm Password', :with => ''
          click_button
          response.should render_template('users/new')
          response.should have_selector('div#error_explanation')
        end.should_not change(User, :count)
      end
    end
    
    describe "success" do
      it "should create a new user" do
        lambda do
          visit signup_path
          fill_in 'Name',             :with => 'bob'
          fill_in 'Email',            :with => 'bob@builder.com'
          fill_in 'Password',         :with => 'tonkatruck'
          fill_in 'Confirm Password', :with => 'tonkatruck'
          click_button
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "signin/signout" do
     describe "failure" do
      it "should not sign a user in" do
        visit signin_path
        fill_in :email,     :with => ''
        fill_in :password,  :with => ''
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success" do
      it "should sign a user in and out" do
        user = Factory(:user)
        visit signin_path
        fill_in :email,     :with => user.email
        fill_in :password,  :with => user.password
        click_button
        controller.should be_signed_in
        click_link "Sign out"
        response.should have_selector("a", :href => signin_path)
      end
    end
  end
end
