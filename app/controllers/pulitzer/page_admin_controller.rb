
module Pulitzer
	class PageAdminController < ApplicationAdminController
		include Pulitzer::Concerns::PageAdminConcern

		before_action :get_page, except: [ :create, :empty_trash, :index ]


		def clone
			authorize( Page )
			@new_page = Page.new(
				title: 			@page.title + " (copy)",
				subtitle: 		@page.subtitle,
				category_id: 	@page.category_id,
				layout: 		@page.layout,
				template: 		@page.template,
				description: 	@page.description,
				content: 		@page.content,
				show_title: 	@page.show_title,
				keywords: 		@page.keywords,
				tags: 			@page.tags
				)
			@new_page.publish_at ||= Time.zone.now
			@new_page.user = current_user
			@new_page.status = 'draft'

			@page.content_sections.each do |section|
				s = @new_page.content_sections.push(section.clone)
			end

			if @new_page.save
				set_flash 'Page Cloned'
				redirect_to edit_page_admin_path( @new_page )
			else
				set_flash 'Page could not be created', :error, @new_page
				redirect_back( fallback_location: '/admin' )
			end

		end


		def create
			authorize( Page )
			@page = Page.new( page_params )
			@page.publish_at ||= Time.zone.now
			@page.user = current_user
			@page.status = 'draft'

			if @page.save
				set_flash 'Page Created'
				redirect_to edit_page_admin_path( @page )
			else
				set_flash 'Page could not be created', :error, @page
				redirect_back( fallback_location: '/admin' )
			end
		end


		def destroy
			authorize( @page )
			@page.trash!
			set_flash 'Page Trashed'
			redirect_back( fallback_location: '/admin' )
		end


		def edit
			authorize( @page )

			partial_path = "#{Rails.root}/app/views/pulitzer/content_sections/partials/"

			@partials = [ 'default', 'default_contained' ]
			@partials += Dir.glob( "#{partial_path}**/*" ).collect{ |f| f.gsub( '.html.haml', '' ).gsub( "#{partial_path}_", '' )  }
			@partials.sort!

			if params[:adv]
				render 'advanced_edit'
			else
				render 'edit'
			end
		end


		def empty_trash
			authorize( Page )
			@pages = Page.trash.destroy_all
			redirect_back( fallback_location: '/admin' )
			set_flash "#{@pages.count} destroyed"
		end


		def index
			authorize( Page )

			sort_by = params[:sort_by] || 'publish_at'
			sort_dir = params[:sort_dir] || 'desc'

			@pages = page_search( params[:q], sort_by: sort_by, sort_dir: sort_dir, status: params[:status], page: params[:page], redirects: params[:redirects] )

		end


		def preview
			authorize( @page )

			if @version = @page.versions.find_by( id: params[:v] )
				@media = @version.next.reify
			else
				@media = @page
			end

			# copied from pulitzer_render
			set_page_meta( @page.page_meta )
			render @page.template, layout: @page.layout
		end


		def update
			authorize( @page )

			@page.slug = nil if params[:page][:slug_pref].present? || params[:page][:title] != @page.title
			@page.attributes = page_params

			if @page.save
				undo_link = view_context.link_to( "undo", undo_version_admin_path( @page.versions.last ), method: :put )
				set_flash 'Page Updated ' + undo_link
				redirect_to edit_page_admin_path( id: @page.id )
			else
				set_flash 'Page could not be Updated', :error, @page
				render :edit
			end
		end

		private
			def page_params
				params.require( :page ).permit( :title, :subtitle, :avatar_caption, :slug_pref, :description, :content, :status, :availability, :publish_at, :show_title, :is_sticky, :is_commentable, :user_id, :tags, :tags_csv, :layout, :template, :avatar_attachment, :cover_attachment, :meta_description, :meta_tite,{ embedded_attachments: [], other_attachments: [] } )
			end

			def get_page
				@page = Page.friendly.find( params[:id] )
			end

			def info_for_paper_trail
				{ notes: params[:version_notes] }
			end

	end
end
