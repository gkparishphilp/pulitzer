module Pulitzer
	class VersionAdminController < ApplicationAdminController
		before_action :get_version, except: [ :index ]


		def index
			
			@parent_obj = params[:parent_obj_type].constantize.find(params[:parent_obj_id])

			@versions = @parent_obj.versions

			@versions = @versions.page( params[:page] )
		end

		def restore
			@version.next.reify.save
			redirect_back fallback_location: '/admin'
		end

		def undo
			@version.reify.save
			redirect_back fallback_location: '/admin'
		end


		private

			def get_version
				@version = PaperTrail::Version.find( params[:id] )
			end


	end
end
