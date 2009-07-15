class CreateArticles < ActiveRecord::Migration
  
  def self.up
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS articles;
EOF

ActiveRecord::Base.connection.execute <<EOF
CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `link_title` varchar(50) default NULL,
  `title` varchar(50) default NULL,
  `page_number` int(11) default NULL,
  `creator` int(11) default NULL,
  `date_created` datetime default NULL,
  `voided` tinyint(1) default NULL,
  `voided_by` int(11) default NULL,
  `content` text default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
EOF

  end

  def self.down
ActiveRecord::Base.connection.execute <<EOF
DROP TABLE IF EXISTS `articles`;
EOF
  end

end
