class Album < ActiveRecord::Base
require 'paperclip'

set_table_name "images"

named_scope :active, :conditions => ['voided = 0']

cattr_accessor :current_album

  def image=(file)
    file_extension = file.original_filename 
    album_name = self.current_album

    #FileUtils.mkdir_p "public/images/uploads/#{album_name}" if !FileTest::directory?("public/images/uploads/#{album_name}")
    Dir::mkdir("#{RAILS_ROOT}/public/images/uploads/#{album_name}") unless FileTest::directory?("#{RAILS_ROOT}/public/images/uploads/#{album_name}")

    if File.exist?("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{file_extension}")  
      valid_file_extension = file_extension
      count = 1
      while File.exist?("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{valid_file_extension}")
        valid_file_extension = valid_file_extension.split(".")[0..-2].to_s +  "#{count+=1}." + valid_file_extension.split(".")[-1..-1].to_s
      end  
      file_extension = valid_file_extension
    end
    File.open("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{file_extension}","w+") do |f|
      f.write file.read 
      self.file_name = file_extension
      self.save 
    end

  end
  
  def before_create
    super
    self.album = self.current_album
    self.date_created = Time.now
    self.date_updated = Time.now
  end
#__________________________________________________________________________________________________________________



  def self.first_image_to_show(current_image,album_name)
    self.find(:first,:conditions => ["file_name=? and album=?",current_image,album_name])
  end

  def self.next_image(current_image,album_name,album)

    album_hash = {}
    image_hash = {}
    count = 1
    album.each{|al|
      album_hash[al.file_name] = count
      count+=1
    }
    
    file_name = ""
    current_count = album_hash.indexes(current_image)[0].to_i
    
    file_name =  album_hash.index(current_count+1) if current_count < album.length  rescue nil
    image_count = (current_count+1) if current_count < album.length  rescue nil
    file_name =  album_hash.index(album.length - (current_count - 1)) if current_count == album.length  rescue nil
    image_count = (album.length - (current_count - 1)) if current_count == album.length  rescue nil

    return if file_name.blank?



    image_hash[image_count] = self.find(:first,:conditions => ["file_name=? and album=?",file_name,album_name])
    image_hash
  end

  def self.previous_image(current_image,album_name,album)
    album_hash = {}
    image_hash = {}
    count = 1
    album.each{|al|
      album_hash[al.file_name] = count
      count+=1
    }
    
    current_count = album_hash.indexes(current_image)[0].to_i
    
    file_name =  album_hash.index(current_count - 1) if current_count > 1  rescue nil
    image_count = (current_count - 1) if current_count > 1  rescue nil
    file_name =  album_hash.index(album.length) if current_count == 1  rescue nil
    image_count = (album.length) if current_count == 1  rescue nil

    return if file_name.blank?

    image_hash[image_count] = self.find(:first,:conditions => ["file_name=? and album=?",file_name,album_name])
    image_hash
  end

#__________________________________________________________________________________________________________________


  def self.get_albums
    self.active.find(:all,:group => "album" ,:order => "album asc")
  end

  def self.get_by_name(name)
    self.active.find(:all,:conditions => ["album=?",name],:order => "id desc")
  end

  def length
    Album.active.count(:all,:conditions => ["album=?",self.album])
  end
  
  def created_date
    Album.active.find(:first,:conditions => ["album=?",self.album],:order => "date_created asc").date_created rescue nil
  end
  
  def updated_date
    Album.active.find(:first,:conditions => ["album=?",self.album],:order => "date_created desc").date_updated rescue nil
  end
  
  def self.void(album_name)  
     self.get_by_name(album_name).each{|pic|
            pic.voided = true
            pic.save
          } rescue nil

  end

end
