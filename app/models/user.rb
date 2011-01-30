# == Schema Information
# Schema version: 20110130114622
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  attr_accessible :name, :email
  
  # Email regular expression used for validation
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  # Validation
  validates :name,    :presence   => true,
                      :length     => { :maximum => 50 }
  validates :email,   :presence   => true,
                      :format     => { :with => email_regex },
                      :uniqueness => { :case_sensitive => false }
end
