module Pulitzer
	class RedirectAdminController < ApplicationAdminController
		before_action :get_redirect, except: [ :create, :index ]

		def create
			@redirect = Redirect.new( redirect_params )
			
			@redirect.user ||= current_user
			@redirect.status = 'active'

			authorize( @redirect )

			if @redirect.save
				set_flash 'redirect Created'
				redirect_to edit_redirect_admin_path( @redirect )
			else
				set_flash 'redirect could not be created', :error, @redirect
				redirect_back( fallback_location: '/admin' )
			end
		end


		def destroy
			authorize( @redirect )
			@redirect.destroy
			set_flash 'Redirect Deleted'
			redirect_back( fallback_location: '/admin' )
		end


		def edit
			authorize( @redirect )
			# create new working version if none exists or if not a draft
			# unless @article.working_media_version.try(:draft?)
			#
			# 	@article.update working_media_version: @article.media_versions.create
			#
			# end
			#
			# @current_draft = @article.working_media_version
		end


		def index
			authorize( Redirect )
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@redirects = Redirect.order( "#{sort_by} #{sort_dir}" )

			if params[:q].present?
				@redirects = @redirects.where( "array[:q] && keywords", q: params[:q].downcase )
			end

			@redirects = @redirects.page( params[:page] )
		end


		def update

			@redirect.attributes = redirect_params

			@redirect.slug = nil if params[:redirect][:slug_pref].present?

			authorize( @redirect )

			if @redirect.save
				set_flash 'Updated'
				redirect_to edit_redirect_admin_path( id: @redirect.id )
			else
				set_flash 'Redirect could not be Updated', :error, @redirect
				render :edit
			end

		end


		private
			def redirect_params
				params.require( :redirect ).permit( :title, :slug_pref, :redirect_url )
			end

			def get_redirect
				@redirect = Redirect.friendly.find( params[:id] )
			end


	end
end
