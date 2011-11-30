desc "generate test users"
task :fake_users => :environment do
  50.times do 
    User.create :username => Faker::Internet.user_name, :email => Faker::Internet.email, :password => 'xxxxxx', :password_confirmation => 'xxxxxx', :meters_explored => rand(30000)
  end  
end

desc "generate test map"
task :fake_map => :environment do
    (63520..63600).to_a.each do |x|
      (51220..51300).to_a.each do |y|
        Map.create({:x => x, :y => y, :z => 17}) if rand >= 0.5
      end
    end
end