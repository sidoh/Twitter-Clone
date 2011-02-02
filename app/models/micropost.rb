class Micropost < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  
  # The default order should be in reverse order from when it was created.
  default_scope :order => 'microposts.created_at DESC'
end
