class AlbumsController < ApplicationController

  def show
    @user = User.find(session[:user_id]) rescue nil
    @articles = Article.get_articles
    @albums = Album.get_albums
  end
  
  def upload
    file = params[:file_name]
    Album.current_album = params[:album_name].to_s

    new_image = Album.new(params[:file_name]) unless params[:file_name].blank?
    new_image = Album.new(params[:file_name2]) unless params[:file_name2].blank?
    new_image = Album.new(params[:file_name3]) unless params[:file_name3].blank?
    new_image = Album.new(params[:file_name4]) unless params[:file_name4].blank?

    redirect_to (:controller => "user",:action => "accounts",:id => "upload")
  end

  def pictures
    @user = User.find(session[:user_id]) rescue nil
    @articles = Article.get_articles
    redirect_to (:action => "show") if params[:id].blank?
    @album = Album.get_by_name(params[:id])
    @image_count = "Photo 1 of #{@album.length}"
    @next_image = Album.first_image_to_show(@album[0].file_name,@album[0].album) rescue nil
    @photo_count = "Photo 1 of #{@album.length}"
  end

  def next_picture
    current_image = params[:image_id]
    album_name = params[:image_name]
    album = Album.get_by_name(album_name)
    redirect_to (:controller => "albums",:action => "show") if album.blank?
    next_image_hash = Album.next_image(current_image.to_s,album_name.to_s,album) rescue nil
    redirect_to (:controller => "albums",:action => "show") if next_image_hash.blank?
    @next_image = next_image_hash.values.first
    @image_count = "Photo #{next_image_hash.keys[0]} of #{album.length}"
    render :partial => "image" and return
  end

  def previous_picture
    current_image = params[:image_id]
    album_name = params[:image_name]
    album = Album.get_by_name(album_name)
    redirect_to (:controller => "albums",:action => "show") if album.blank?
    next_image_hash = Album.previous_image(current_image.to_s,album_name.to_s,album) rescue nil
    redirect_to (:controller => "albums",:action => "show") if next_image_hash.blank?
    @next_image = next_image_hash.values.first
    @image_count = "Photo #{next_image_hash.keys[0]} of #{album.length}"
    render :partial => "image" and return
  end
  
  def delete
    Album.void!(params[:id])
    redirect_to (:action => "show")
  end  

end
