class ArticleController < ApplicationController
  
  def index
    @user = User.find(session[:user_id]) rescue nil
    @articles = Article.get_articles
    @article = Article.find_by_id(params[:id]) unless params[:id].blank? rescue nil
    @article = Article.get_content_for_home_page if @article.blank?
  end

  def new
    title = params[:title].to_s
    link_title = params[:link_title].to_s
    content = params[:content].to_s
    unless title.blank? and content.blank? and link_title.blank?
      Article.create(link_title,title,content,1)
    end  
    redirect_to :controller => "user",:action => 'accounts' and return
  end

  def edit
    article = Article.find_by_title(params[:article])
    title = params[:new_title].to_s.strip rescue nil
    link_title = params[:new_link_title].to_s.strip rescue nil
    content = params[:content].to_s.strip rescue nil
    if article
      article.title = title unless title.blank?
      article.link_title = link_title unless link_title.blank?
      article.content = content unless content.blank?
      article.save
    end
    redirect_to :controller => "user",:action => 'accounts' and return
  end

end
