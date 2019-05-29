module Pulitzer
	class SiteAdminController < ApplicationAdminController


		before_action :get_site, except: [ :create, :index ]

		def create
			@site = Site.new( site_params )
			
			@site.status = 'active'

			authorize( @site )

			if @site.save
				set_flash 'Site Created'
				redirect_to edit_site_admin_path( @site )
			else
				set_flash 'Site could not be created', :error, @site
				redirect_back( fallback_location: '/admin' )
			end
		end


		def destroy
			authorize( @site )
			@site.destroy
			set_flash 'Site Deleted'
			redirect_back( fallback_location: '/admin' )
		end


		def edit
			authorize( @site )
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
			authorize( Site )
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@sites = Site.order( "#{sort_by} #{sort_dir}" )


			@sites = @sites.page( params[:page] )
		end


		def update

			@site.attributes = site_params

			authorize( @site )

			if @site.save
				set_flash 'Updated'
				redirect_to edit_site_admin_path( id: @site.id )
			else
				set_flash 'site could not be Updated', :error, @site
				render :edit
			end

		end


		private
			def site_params
				params.require( :site ).permit( :name, :domain, :description )
			end

			def get_site
				@site = Site.find( params[:id] )
			end



	end
end