class CreateUsers < ActiveRecord::Migration

  def self.up
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS users;
EOF

ActiveRecord::Base.connection.execute <<EOF
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL auto_increment,
  `system_id` varchar(50) default NULL,
  `username` varchar(50) default NULL,
  `first_name` varchar(50) default NULL,
  `middle_name` varchar(50) default NULL,
  `last_name` varchar(50) default NULL,
  `password` varchar(50) default NULL,
  `salt` varchar(50) default NULL,
  `secret_question` varchar(50) default NULL,
  `secret_answer` varchar(50) default NULL,
  `creator` int(11) default NULL,
  `date_created`Datetime NOT NULL,
  `changed_by` int(11) default NULL,
  `date_changed` Datetime NOT NULL,
  `voided` tinyint(1) default NULL,
  `voided_by` int(11) default NULL,
  `date_voided` Datetime NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
EOF
  end

  def self.down
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS `users`;
EOF
  end

end
