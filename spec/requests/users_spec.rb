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
end
