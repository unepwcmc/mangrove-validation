desc "generate test users"
task :fake_users => :environment do
  50.times do 
    User.create :username => Faker::Internet.user_name, :email => Faker::Internet.email, :password => 'xxxxxx', :password_confirmation => 'xxxxxx', :meters_explored => rand(30000)
  end  
end

desc "generate test map"
task :fake_map => :environment do
    (108500..109023).to_a.each do |x|
      (68550..68623).to_a.each do |y|
        Cell.create({:x => x, :y => y, :z => 17, :mangroves => true}) if rand >= 0.7
      end
    end
end