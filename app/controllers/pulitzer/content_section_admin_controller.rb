
module Pulitzer 
	class ContentSectionAdminController < ApplicationAdminController


		def create
			parent = params[:parent_type].constantize.find( params[:parent_id] )

			seq = params[:seq]
			seq = 1 if seq == 'first'
			seq = ContentSection.maximum( :seq ) + 1 if seq == 'last'


			@section = ContentSection.create( parent: parent, name: params[:name], description: params[:description], seq: seq )
			redirect_back fallback_location: '/admin'
		end

		def destroy
			@section = ContentSection.friendly.find( params[:id] )
			@section.destroy
			redirect_back fallback_location: '/admin'
		end

		def update
			@section = ContentSection.friendly.find( params[:id] )
			params[:content_section][:seq] = 1 if params[:content_section][:seq] == 'first'
			params[:content_section][:seq] = ContentSection.maximum( :seq ) + 1 if params[:content_section][:seq] == 'last'
			@section.update( content_section_params )
			redirect_back fallback_location: '/admin'
		end


		private

			def content_section_params
				params.require( :content_section ).permit( :parent_id, :parent_type, :name, :header, :header_tag, :header_classes, :header_style, :description, :seq, :partial, :section_style, :section_classes, :content, :content_style, :content_classes, :background_attachment )
			end

	end
end
