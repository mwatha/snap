class CreateAlbums < ActiveRecord::Migration
  
  def self.up
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS albums;
EOF

ActiveRecord::Base.connection.execute <<EOF
CREATE TABLE `albums` (
  `id` int(11) NOT NULL auto_increment,
  `file_name` varchar(50) default NULL,
  `album` varchar(50) default NULL,
  `voided` tinyint(1) default 0,
  `date_created` datetime default NULL,
  `date_updated` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
EOF

  end

  def self.down
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS `albums`;
EOF
  end

end
