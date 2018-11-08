
module Pulitzer 
	class ContentSectionAdminController < ApplicationAdminController


		def create
			parent = params[:parent_type].constantize.find( params[:parent_id] )
			@section = ContentSection.create( parent: parent, name: params[:name], description: params[:description] )
			redirect_back fallback_location: '/admin'
		end

		def update
			@section = ContentSection.find( params[:id] )
			@section.update( content_section_params )
			redirect_back fallback_location: '/admin'
		end


		private

			def content_section_params
				params.require( :content_section ).permit( :name, :description, :seq, :partial, :css_style, :css_classes, :content )
			end

	end
end
