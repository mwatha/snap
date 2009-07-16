class Album < ActiveRecord::Base
require 'paperclip'
require 'mini_magick'

named_scope :active, :conditions => ['voided = 0']

cattr_accessor :current_album

  def image=(file)
    product_image_title =  file.original_filename
    image_file_extension = product_image_title[product_image_title.rindex(".") .. product_image_title.length].strip.chomp
    file_name = "#{Date.today.strftime('%d%m%y')}#{rand(10000)}#{image_file_extension}"

    album_name = self.current_album

    #FileUtils.mkdir_p "public/images/uploads/#{album_name}" if !FileTest::directory?("public/images/uploads/#{album_name}")
    Dir::mkdir("#{RAILS_ROOT}/public/images/uploads/#{album_name}") unless FileTest::directory?("#{RAILS_ROOT}/public/images/uploads/#{album_name}")
=begin
    if File.exist?("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{file_extension}")  
      valid_file_extension = file_extension
      count = 1
      while File.exist?("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{valid_file_extension}")
        valid_file_extension = valid_file_extension.split(".")[0..-2].to_s +  "#{count+=1}." + valid_file_extension.split(".")[-1..-1].to_s
      end  
      file_extension = valid_file_extension
    end
=end

   #TODO
   thumb_image = Album.active.find(:first,:conditions => ["album=? and file_name like ?",album_name,"%thumb%"])
   #__________________

    File.open("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{file_name}","w+") do |f|
      File.open("#{RAILS_ROOT}/public/images/tmp/#{file.original_filename}", "wb") do |f|
        f.write(file.read)
      end 
      image = MiniMagick::Image.from_file("#{RAILS_ROOT}/public/images/tmp/#{file.original_filename}")
      size = image_size("#{RAILS_ROOT}/public/images/tmp/#{file.original_filename}") #  "600X500"
      unless size.blank?
        image.resize  size
      end
      image.write("#{RAILS_ROOT}/public/images/uploads/#{album_name}/#{file_name}")
      self.file_name = file_name
      self.save 
    end

    if thumb_image.blank?
      image = MiniMagick::Image.from_file("#{RAILS_ROOT}/public/images/tmp/#{file.original_filename}")
      image.resize  "180X180"
      image.write("#{RAILS_ROOT}/public/images/uploads/#{album_name}/thumb#{image_file_extension}")
      thumb = Album.new()
      thumb.file_name = "thumb#{image_file_extension}"
      thumb.save 
    end
#the following code is removing uploaded tmp files
    Dir.glob(File.join(RAILS_ROOT, 'public/images/tmp', '*')).each{|file|
      File.delete(file)    
    }
  end
  
  def image_size(file_path)
    size = (File.size(file_path) / 1000)

    if size > 500
      return "490X481"
    elsif size >= 120 and size <= 500
      return "400X390"
    elsif size <= 120 and size >= 100
      return "370X369"
    elsif size >= 80 and size < 100
      return "465X464"
    else
      return nil
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
    self.active.find(:all,:conditions => ["file_name like ?","%thumb%"],:group => "album" ,:order => "album asc")
  end

  def self.get_by_name(name)
    self.active.find(:all,:conditions => ["album=? and file_name NOT like ?",name,"%thumb%"],:order => "id desc")
  end

  def length
    Album.active.count(:all,:conditions => ["album=? and file_name NOT like ?",self.album,"%thumb%"])
  end
  
  def created_date
    Album.active.find(:first,:conditions => ["album=?",self.album],:order => "date_created asc").date_created rescue nil
  end
  
  def updated_date
    Album.active.find(:first,:conditions => ["album=?",self.album],:order => "date_created desc").date_updated rescue nil
  end
  
  def self.void!(album_name)  
     self.active.find(:all,:conditions =>["album =?",album_name]).each{|pic|
            pic.voided = true
            pic.save
          } rescue nil

  end

end
