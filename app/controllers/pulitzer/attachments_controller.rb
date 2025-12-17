module Pulitzer
	class AttachmentsController < ApplicationAdminController
		before_action :get_model

		def create

			attachments = active_storate_params[:attachments]
			model_attribute = @model.try( params[:attribute] )

			sequence = params[:sequence].presence || (model_attribute.maximum(:sequence).to_i + 1)

			authorize( model_attribute, attachments: attachments )

			model_attribute.attach( attachments ) #rescue nil

			attachment = model_attribute.reorder(id: :asc).last

			attachment.sequence = sequence
			attachment.save

			if params[:replace] && attachment.sequence.present?

				# Detach any attachments that are being replaced.
				model_attribute.where( sequence: attachment.sequence ).where.not( id: attachment.id ).each do |attachment|
					attachment.purge #rescue nil
				end
			else

				# Increment all items at or above the sequence of the added item
				model_attribute.where.not( id: attachment.id ).where( sequence: attachment.sequence..Float::INFINITY ).update_all('sequence = sequence + 1')
			end

			# Just in case iterate over the sequenced items and set their
			# sequence in order (remove repeated sequences, and any gaps)
			model_attribute.where.not(sequence: nil).order(sequence: :asc, id: :asc).each_with_index do |model,model_index|
				model.update( sequence: (model_index + 1) )
			end

			set_flash "Attachment Added"
			respond_to do |format|
				format.js {
				}
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
			@attachment.purge #rescue nil

			@model.try( params[:attribute] ).where.not(sequence: nil).order(sequence: :asc).each_with_index do |model,model_index|
				model.update( sequence: (model_index + 1) )
			end

			set_flash "Attachment Removed"

			respond_to do |format|
				format.js {
				}
				format.html {
					redirect_back fallback_location: '/'
				}
			end
			
		end

		def update
			@attachment = @model.try( params[:attribute] ).find_by_id(params[:id])
			authorize( @attachment )

			attributes = params.permit([:sequence])

			sequence_param = attributes[:sequence]

			attributes[:sequence] = @attachment.sequence + 1 if sequence_param == 'next'
			attributes[:sequence] = @attachment.sequence - 1 if sequence_param == 'previous'

			@attachment.update( attributes )

			# Move the rest of the elements away from the new position
			@model.try( params[:attribute] ).where.not( id: @attachment.id ).where( sequence: (-Float::INFINITY)..@attachment.sequence ).update_all('sequence = sequence - 1') if sequence_param == 'next'
			@model.try( params[:attribute] ).where.not( id: @attachment.id ).where( sequence: @attachment.sequence..Float::INFINITY ).update_all('sequence = sequence + 1') unless sequence_param == 'next'

			# For all sequenced items, put them in order, removing gaps and 
			@model.try( params[:attribute] ).where.not(sequence: nil).order(sequence: :asc).each_with_index do |model,model_index|
				model.update( sequence: (model_index + 1) )
			end

			set_flash "Attachment Updated"


			respond_to do |format|
				format.js {
				}
				format.html {
					redirect_back fallback_location: '/'
				}
			end
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
