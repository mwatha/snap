class Article < ActiveRecord::Base

  named_scope :active, :conditions => ['voided = 0']
    
  def self.last_update_time
    article_update_time = self.active.find(:first,:order => "date_created desc").date_created rescue "2009-05-13".to_time
    pictures_update_time = Album.active.find(:first,:order => "date_created desc").date_created rescue "2009-05-13".to_time
    return pictures_update_time if pictures_update_time >= article_update_time
    article_update_time
  end

  def self.create(link_title,title,content,page_number)
    return nil if title.blank? || content.blank? || page_number.blank? || link_title.blank?
    article = self.new() 
    article.creator = User.current_user.id
    article.date_created = Time.now()
    article.link_title = link_title.strip
    article.title = title.strip
    article.content = content.strip
    article.page_number = page_number.to_i
    article.save
  end


  def self.get_content_for_home_page
    self.active.find(:first,:conditions =>["page_number=0"] ,:order => "date_created desc") 
  end

  def self.get_articles
    self.active.find(:all,:conditions =>["page_number=1"] ,:order => "date_created desc limit 30") 
  end

  def self.edit!(article,title,link_title,content)
     unless article.blank?
      article.title = title unless title.blank?
      article.link_title = link_title unless link_title.blank?
      article.content = content unless content.blank?
      voided = article.voided
      article.date_voided = "0000-00-00 00:00:00" if voided
      article.voided_by = nil if voided
      article.voided = 0 if voided
      article.save
    end
  end 

end
