module Pulitzer
	class ArticleAdminController < ApplicationAdminController
		include Pulitzer::Concerns::ArticleAdminConcern

		before_action :get_article, except: [ :create, :empty_trash, :index ]

		def create
			@article = Article.new( article_params )
			@article.publish_at ||= Time.zone.now
			@article.user ||= current_user
			@article.status = 'draft'

			if params[:article][:category_name].present?
				@article.category = ArticleCategory.where( name: params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			authorize( @article )

			if @article.save
				set_flash 'Article Created'
				redirect_to edit_article_admin_path( @article )
			else
				set_flash 'Article could not be created', :error, @article
				redirect_back( fallback_location: '/admin' )
			end
		end


		def destroy
			authorize( @article )
			@article.trash!
			undo_link = view_context.link_to( "undo", revert_version_admin_path( @article.versions.last ), method: :put )
			set_flash 'Article Deleted ' + undo_link
			redirect_back( fallback_location: '/admin' )
		end


		def edit
			authorize( @article )
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
			authorize( Article )
			@articles = Article.trash.destroy_all
			redirect_back( fallback_location: '/admin' )
			set_flash "#{@articles.count} destroyed"
		end


		def index
			authorize( Article )
			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@articles = article_search( params[:q], sort_by: sort_by, sort_dir: sort_dir, status: params[:status], page: params[:page] )

		end

		def purge
			authorize( @article )

			attribute = 'avatar_attachment'
			attribute = 'cover_attachment' if params[:attribute] == 'cover_attachment'

			@article.try(attribute).purge

			if @article.try(attribute).attached?
				set_flash 'Could not remove file', :error
			else
				@article.avatar = nil
				@article.cover_image = nil
				@article.avatar = @article.avatar_attachment.url if @article.avatar_attachment.attached?
				@article.cover_image = @article.cover_attachment.url if @article.cover_attachment.attached?
				@article.save
				set_flash "File removed"
			end

			redirect_back( fallback_location: '/admin' )
		end


		def preview
			authorize( @article )


			if @version = @article.versions.find_by( id: params[:v] )
				@media = @version.next.reify
			else
				@media = @article
			end

			# copied from pulitzer_render
			set_page_meta( @media.page_meta )
			render @media.template, layout: @media.layout
		end


		def update

			@article.slug = nil if ( params[:article][:title] != @article.title ) || ( params[:article][:slug_pref].present? )

			@article.attributes = article_params
			@article.avatar_urls = params[:article][:avatar_urls] if params[:article].present? && params[:article][:avatar_urls].present?


			if params[:article][:category_name].present?
				@article.category = ArticleCategory.where( name: params[:article][:category_name] ).first_or_create( status: 'active' )
			end

			authorize( @article )

			if @article.save
				undo_link = view_context.link_to( "undo", undo_version_admin_path( @article.versions.last ), method: :put )
				set_flash 'Article Updated ' + undo_link
				redirect_to edit_article_admin_path( id: @article.id )
			else
				set_flash 'Article could not be Updated', :error, @article
				render :edit
			end

		end


		private
			def article_params
				params.require( :article ).permit( [ :title, :subtitle, :avatar_caption, :slug_pref, :description, :content, :category_id, :status, :parent_slug, :publish_at, :show_title, :is_commentable, :is_sticky, :user_id, :reviewed_by_id, :tags, :tags_csv, :redirect_url, :avatar_attachment, :cover_attachment, :meta_description,] + ( Pulitzer.admin_permit_additions[:article_admin] || [] ) + [{ embedded_attachments: [], other_attachments: [] }] )
			end

			def get_article
				@article = Article.friendly.find( params[:id] )
			end

			def info_for_paper_trail
				{ notes: params[:version_notes] }
			end

	end
end
