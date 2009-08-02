require 'digest/sha1'

class User < ActiveRecord::Base
  cattr_accessor :current_user

  set_table_name "users"
  validates_presence_of:username,:password, :message =>"Fill in Username"
  validates_length_of:username, :within => 3..20
  validates_uniqueness_of:username
 #validates_length_of:password, :within => 4..50
  
  

  set_primary_key "user_id"

  def name
    self.first_name + " " + self.last_name
  end
  
  def before_create
    super
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password,self.salt) 

    self.creator = User.current_user.user_id if self.attributes.has_key?("creator") && User.current_user
    self.date_created = Time.now if self.attributes.has_key?("date_created")
    self.date_changed = Time.now 

  end
  
  def before_update
    super
    self.salt = User.random_string(10) if !self.salt?
    self.password = User.encrypt(self.password,self.salt) 

  end
  
  def self.encrypt(password,salt)
    Digest::SHA1.hexdigest(password+salt)
  end 
   
  def after_create
    super
    @password=nil
  end
  
  def self.authenticate(username,password)
    @user = User.find(:first ,:conditions =>["username=? ", username])
   
    salt=@user.salt unless @user.nil?
    
    return nil if @user.nil?
    return @user if encrypt(password, salt)==@user.password
  end 
  
  def try_to_login
    User.authenticate(self.username,self.password)
  end
  
  
  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
  
end


### Original SQL Definition for users #### 
#   `user_id` int(11) NOT NULL auto_increment,
#   `system_id` varchar(50) NOT NULL default '',
#   `username` varchar(50) default NULL,
#   `first_name` varchar(50) default NULL,
#   `middle_name` varchar(50) default NULL,
#   `last_name` varchar(50) default NULL,
#   `password` varchar(50) default NULL,
#   `salt` varchar(50) default NULL,
#   `secret_question` varchar(255) default NULL,
#   `secret_answer` varchar(255) default NULL,
#   `creator` int(11) NOT NULL default '0',
#   `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
#   `changed_by` int(11) default NULL,
#   `date_changed` datetime default NULL,
#   `voided` tinyint(1) NOT NULL default '0',
#   `voided_by` int(11) default NULL,
#   `date_voided` datetime default NULL,
#   `void_reason` varchar(255) default NULL,
#   PRIMARY KEY  (`user_id`),
#   KEY `user_creator` (`creator`),
#   KEY `user_who_changed_user` (`changed_by`),
#   KEY `user_who_voided_user` (`voided_by`),
#   CONSTRAINT `user_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
#   CONSTRAINT `user_who_changed_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
#   CONSTRAINT `user_who_voided_user` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
