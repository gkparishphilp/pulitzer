module Pulitzer
	class AutoLinkAdminController < ApplicationAdminController
		before_action :get_link, except: [ :create, :empty_trash, :index ]

		def create
			@link = AutoLink.new( link_params )

			authorize( @link )

			if @link.save
				set_flash 'Link Created'
				redirect_to edit_auto_link_admin_path( @link.id )
			else
				set_flash 'link could not be created', :error, @link
				redirect_back( fallback_location: '/admin' )
			end
		end

		def destroy
			authorize( @link )

			if @link.trash?
				@link.destroy
			else
				@link.update( status: :trash )
			end
			set_flash 'Link Deleted'
			redirect_back( fallback_location: '/admin' )
		end

		def edit
			authorize( @link )
		end

		def index
			authorize( AutoLink )

			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'asc'

			@links = AutoLink.order( Arel.sql("#{sort_by} #{sort_dir}") )
			@links = @links.page( params[:page] )
		end

		def update
			@link.attributes = link_params

			authorize( @link )

			if @link.save
				set_flash 'link Updated'
				redirect_to edit_auto_link_admin_path( id: @link.id )
			else
				set_flash 'link could not be Updated', :error, @link
				render :edit
			end
		end


		private
			def link_params
				params.require( :link ).permit( :phrase, :url, :description, :status )
			end

			def get_link
				@link = AutoLink.find( params[:id] )
			end
	end
end
