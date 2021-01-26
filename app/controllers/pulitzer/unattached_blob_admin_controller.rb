module Pulitzer
	class UnattachedBlobAdminController < ApplicationAdminController

		def create
			authorize( Pulitzer::UnattachedBlob )

			@blob = Pulitzer::UnattachedBlob.build_after_upload(
				io: params[:file],
				filename: params[:file].original_filename,
				content_type: params[:file].content_type
			)

			#@todo de dupe!!!!!!!!!!!!!!!
			if( blob = ActiveStorage::Blob.where( checksum: @blob.checksum ).first )
				@message = 'File already exists.'
				blob.update( type: Pulitzer::UnattachedBlob.name )
				blob = Pulitzer::UnattachedBlob.find( blob.id )
				@blob = blob
			end

			@blob.analyze()
			@blob.save


			respond_to do |format|
				format.json {
					render :json => { link: @blob.service_url, message: @message }
				}
				format.html {
					set_flash @message, :info, @blob
					if params[:redirect_to]
						url = Addressable::URI.parse(params[:redirect_to] || request.referer)
						url.query_values = url.query_values.merge( storage_blob_link: @blob.service_url )
						redirect_to url.to_s
					else
						redirect_to edit_unattached_blob_admin_path(@blob.id)
					end
				}
			end
		end

		def edit
			@blob = ActiveStorage::Blob.find( params[:id] )
			authorize( @blob )
		end

		def index

			@sort_by = 'created_at'
			@sort_by = params[:sort_by] if params[:sort_by].present? && %w(filename created_at).include?(params[:sort_by])

			@sort_dir = params[:sort_dir] == 'asc' ? 'asc' : 'desc'

			@blobs = Pulitzer::UnattachedBlob.all
			@blobs = @blobs.where( " filename ILIKE :q OR (metadata) ILIKE :q OR array_to_string(tags,',') ILIKE :q", q: "%#{params[:q].downcase}%" ) if params[:q].present?
			@blobs = @blobs.order( @sort_by => @sort_dir )
			@blobs = @blobs.page( params[:page] ).per( 10 )

			authorize( @blobs )
		end

		def update
			@blob = ActiveStorage::Blob.find( params[:id] )
			authorize( @blob )

			attributes = params.permit(:tags_csv,:tags,{ :metadata => [:title,:description,:alt,:author] })

			@blob.attributes = params.require(:blob).permit(:filename)
			@blob.metadata = @blob.metadata.merge( attributes[:metadata] ) if attributes.key? :metadata
			@blob.tags = attributes[:tags] if attributes.key? :tags
			@blob.tags_csv = attributes[:tags_csv] if attributes.key? :tags_csv

			if @blob.save
				set_flash "Blob updated.", :success, @blob
			else
				set_flash "Blob update failed.", :error, @blob
			end

			redirect_back fallback_location: edit_unattached_blob_admin_path(@blob.id)
		end

	end
end
