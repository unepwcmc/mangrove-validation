class User < ActiveRecord::Base
  acts_as_authentic
  has_many :tracks
  after_create { User.refresh_rank }
  
  def refresh_stats
    cx = Classification.count(:joins => [:track => :user], :conditions => "value IS NOT NULL AND user_id = #{self.id}")
    self.meters_explored = cx * APP_CONFIG["meters_per_cell"]
    save
    User.refresh_rank
  end
  
  #NICE. PG 8.4 RANK
  def self.refresh_rank
    User.connection.update "UPDATE users SET rank = u2.rank FROM (SELECT id, meters_explored, rank() OVER(ORDER BY meters_explored DESC) FROM users) as u2 WHERE users.id = u2.id"
  end
  
  def game_json current_user
    
    md = self.meters_explored - current_user.meters_explored
    md = md > 0 ? "+#{md}" : "-#{md}"
    
    {:id => self.id,
     :username => self.username,
     :avatar => "http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5.new.update(email)}",
     :rank => self.rank,
     :meters_explored => self.meters_explored,
     :meters_different => md,
     :current_user => self == current_user ? true : false}    
  end
end
