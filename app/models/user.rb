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

# For hashing capabilities
require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  has_many :microposts, :dependent => :destroy
  
  # regular expressions used for validation
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  user_regex  = /^[a-z0-9_. -]+$/i
  
  # Validation
  validates :name,      :presence     => true,
                        :length       => { :maximum => 50 },
                        :format       => { :with => user_regex }
  validates :email,     :presence     => true,
                        :format       => { :with => email_regex },
                        :uniqueness   => { :case_sensitive => false }
  validates :password,  :presence     => true,
                        :confirmation => true,
                        :length       => { :minimum => 6 }
                        
  # Active Record callbacks
  before_save :hash_password
  
  # Returns true if the user's password matches the submitted password.
  def password_is?( submitted_password )
    password_hash == secure_hash(submitted_password)
  end

  # Returns nil if auth fails, returns appropriate user if it passes.
  def self.authenticate( email, password )
    user = find_by_email(email)
    
    return nil  if user.nil?
    return user if user.password_is?(password)
  end
  
  def self.authenticate_with_salt( id, salt )
    user = find_by_id(id)
    (user && user.salt == salt) ? user : nil
  end
  
  # Returns some posts for the user's feed.
  def feed
    Micropost.where("user_id = ?", id)
  end
  
private

    def hash_password
      self.salt = generate_salt if new_record?
      self.password_hash = secure_hash(password)
    end
    
    def generate_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash( string )
      Digest::SHA2.hexdigest("#{salt}--#{string}")
    end
end
