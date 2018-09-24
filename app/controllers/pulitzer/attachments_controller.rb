module Pulitzer
	class AttachmentsController < ApplicationAdminController
		before_action :get_model

		def create
			authorize( @model.try( params[:attribute] ).new, attachments: active_storate_params[:attachments] )
			@model.try( params[:attribute] ).attach( active_storate_params[:attachments] )

			set_flash "Attachment Added"
			respond_to do |format|
				format.json {
					@model.reload
					render :json => { link: @model.try( params[:attribute] ).last.service_url }
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


		private
			def get_model
				puts "active_storate_params #{active_storate_params.to_json}"
				model_class = active_storate_params[:object_class].constantize
				raise Exception.new("Invalid model class: #{model_class}") unless model_class < ApplicationRecord
				@model = model_class.find( active_storate_params[:object_id] )
				raise Exception.new('Invalid attachment attribute') unless @model.respond_to?( active_storate_params[:attribute] ) && @model.try( active_storate_params[:attribute] ).is_a?( ActiveStorage::Attached::Many )
			end

			def active_storate_params
				params.permit([:object_class,:object_id,:attribute,:attachments])
			end

	end
end
