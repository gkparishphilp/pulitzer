module Pulitzer
	class ArticleAdminController < ApplicationAdminController
		before_action :get_article, except: [ :create, :empty_trash, :index ]

		def create
			@article = Article.new( article_params )
			@article.publish_at ||= Time.zone.now
			@article.user ||= current_user
			@article.status = 'draft'

			if params[:article][:category_name].present?
				@article.category = Category.where( name: params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			if @article.save
				set_flash 'Article Created'
				redirect_to edit_article_admin_path( @article )
			else
				set_flash 'Article could not be created', :error, @article
				redirect_back( fallback_location: '/admin' )
			end
		end


		def destroy
			@article.trash!
			set_flash 'Article Deleted'
			redirect_back( fallback_location: '/admin' )
		end


		def edit
			# create new working version if none exists or if not a draft
			# unless @article.working_media_version.try(:draft?)
			#
			# 	@article.update working_media_version: @article.media_versions.create
			#
			# end
			#
			# @current_draft = @article.working_media_version
		end


		def empty_trash
			@articles = Article.trash.destroy_all
			redirect_back( fallback_location: '/admin' )
			set_flash "#{@articles.count} destroyed"
		end


		def index
			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@articles = Article.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@articles = eval "@articles.#{params[:status]}"
			end

			if params[:q].present?
				@articles = @articles.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@articles = @articles.page( params[:page] )
		end


		def preview

			@media = @article

			#@media_comments = SwellSocial::UserPost.active.where( parent_obj_id: @media.id, parent_obj_type: @media.class.name ).order( created_at: :desc ) if defined?( SwellSocial )

			# layout = @media.class.name.underscore.pluralize
			# layout = @media.layout if @media.layout.present?

			# render "swell_media/articles/show", layout: layout
		end


		def update

			@article.slug = nil if ( params[:article][:title] != @article.title ) || ( params[:article][:slug_pref].present? )

			@article.attributes = article_params
			@article.avatar_urls = params[:article][:avatar_urls] if params[:article].present? && params[:article][:avatar_urls].present?


			if params[:article][:category_name].present?
				@article.category = Category.where( name: params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			if @article.save
				set_flash 'Article Updated'
				redirect_to edit_article_admin_path( id: @article.id )
			else
				set_flash 'Article could not be Updated', :error, @article
				render :edit
			end

		end


		private
			def article_params
				params.require( :article ).permit( :title, :subtitle, :avatar_caption, :slug_pref, :description, :content, :category_id, :status, :publish_at, :show_title, :is_commentable, :user_id, :tags, :tags_csv, :avatar, :avatar_asset_file, :avatar_asset_url, :cover_image, :avatar_urls, :redirect_url )
			end

			def get_article
				@article = Article.friendly.find( params[:id] )
			end


	end
end
