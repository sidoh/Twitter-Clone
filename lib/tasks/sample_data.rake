require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(
      :name => 'Chris Mullins',
      :email => 'chris.mullins10@gmail.com',
      :password => 'asdfasdf',
      :password_confirmation => 'asdfasdf')
    admin.toggle!(:admin)
    99.times do |n|
      name     = Faker::Name.name
      email    = "example-#{n}@sidoh.org"
      password = "default"
      User.create!(:name => name,
        :email => email,
        :password => password,
        :password_confirmation => password)
    end
    User.all.each do |user|
      50.times do
        user.microposts.create!(:content => Faker::Lorem.sentence(5))
      end
    end
  end
end