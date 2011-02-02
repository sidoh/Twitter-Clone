Factory.define :user do |user|
  user.name                         "chris"
  user.email                        "chris@sidoh.org"
  user.password                     "foobar"
  user.password_confirmation        "foobar"
end

Factory.define :micropost do |micropost|
  micropost.content     "Test micropost"
  micropost.association :user
end