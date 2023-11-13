module Pulitzer
	class AttachmentsController < ApplicationAdminController
		before_action :get_model

		def create
			attachments = active_storate_params[:attachments]
			model_attribute = @model.try( params[:attribute] )
			authorize( model_attribute, attachments: attachments )
			model_attribute.attach( attachments )

			attachment = model_attribute.sort_by{|a| a.sequence }.last
			attachment.sequence = model_attribute.collect(&:sequence).max + 1
			attachment.save

			set_flash "Attachment Added"
			respond_to do |format|
				format.json {
					@model.reload
					render :json => { link: model_attribute.last.try(:url) }
				}
				format.html {
					redirect_back fallback_location: '/'
				}
			end
		end


		def destroy
			@attachment = @model.try( params[:attribute] ).find_by_id(params[:id])
			authorize( @attachment )
			@attachment.purge

			set_flash "Attachment Removed"

			redirect_back fallback_location: '/'
		end

		def update
			@attachment = @model.try( params[:attribute] ).find_by_id(params[:id])
			authorize( @attachment )

			attributes = params.permit([:sequence])

			if attributes[:sequence] == 'next'
				@model.try( params[:attribute] ).where( sequence: (@attachment.sequence + 1) ).update_all('sequence = sequence - 1')
				attributes[:sequence] = @attachment.sequence + 1
			elsif attributes[:sequence] == 'previous'
				@model.try( params[:attribute] ).where( sequence: (@attachment.sequence - 1) ).update_all('sequence = sequence + 1')
				attributes[:sequence] = @attachment.sequence - 1
			else
				
			end

			@attachment.update( attributes )

			set_flash "Attachment Updated"

			redirect_back fallback_location: '/'
		end


		private
			def get_model
				model_class = "::#{active_storate_params[:object_class]}".safe_constantize
				raise Exception.new("Invalid model class: #{model_class}") unless model_class < ::ApplicationRecord
				@model = model_class.find( active_storate_params[:object_id] )
				raise Exception.new('Invalid attachment attribute') unless @model.respond_to?( active_storate_params[:attribute] ) && @model.try( active_storate_params[:attribute] ).is_a?( ActiveStorage::Attached::Many )
			end

			def active_storate_params
				params.permit([:object_class,:object_id,:attribute,:attachments])
			end

	end
end
