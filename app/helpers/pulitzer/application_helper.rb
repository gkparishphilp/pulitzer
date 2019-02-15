module Pulitzer
	module ApplicationHelper

		def attachment_resolutions(attachment, options={})
			attached = ( attachment.attached? rescue false )
			attached = true if attachment.is_a?( ActiveStorage::Blob ) && attachment.service_url.present?
			blob = attachment if attachment.is_a?( ActiveStorage::Blob )
			blob ||= attachment.blob if attached

			fallback = options.delete(:fallback)

			# if no attachment, use the fallback
			if attachment.nil? || not( attached )
				return [{
					src: fallback,
					width: 0,
					height: 0,
					breakpoint: 0,
				}]
			end

			breakpoints_max = {
				xxs: 286,
				xs: 575,
				sm: 767,
				md: 991,
				lg: 1199,
				xl: nil,
			}
			breakpoints_min = {
				xxs: 0,
				xs: 287,
				sm: 576,
				md: 768,
				lg: 992,
				xl: 1200,
			}

			last_percent = nil
			breakpoints_max.keys.each do |breakpoint|
				if options[breakpoint] && options[breakpoint].end_with?('%x')
					last_percent = options[breakpoint]
				elsif options[breakpoint].present?
					last_percent = nil
				end

				options[breakpoint] ||= last_percent
			end

			breakpoints = breakpoints_min.select{ |key,value| options[key].present? }

			resolutions = []
			breakpoints.each do |breakpoint,breakpoint_size|
				size = options.delete(breakpoint)
				next unless size.present?

				if attachment.is_a? String
					size_parts = size.split(' ', 2)
					if size_parts.count > 1
						src = size_parts.first
					else
						src = attachment
					end

					size = size_parts.last
				elsif attached

					size = "#{(breakpoints_max[breakpoint]).to_f / 100 * size[0..-3].to_f}x" if size.end_with?('%x') && breakpoints_max[breakpoint].present?
					size = "auto" if size.end_with?('%x') && breakpoints_max[breakpoint].nil?
					size = "#{blob.metadata['width']}x#{blob.metadata['height']}" if size.to_s == 'auto' && blob.metadata['width']
					size = "#{size.split('x').first}x#{(size.split('x').first.to_f / blob.metadata['width'] * blob.metadata['height']).round(2)}" if size.last == 'x' && blob.metadata['width']
					size = "#{(size.split('x').last.to_f / blob.metadata['height'] * blob.metadata['width']).round(2)}x#{size.split('x').last}" if size.first == 'x' && blob.metadata['width']
					puts "size #{size}"
					src = "#{attachment.variant(resize: size).processed.service_url}\#resolution-#{size}" if size && size != 'auto'
					src ||= attachment.service_url
				end

				resolutions << {
					src: src,
					width: size.split('x').first,
					height: size.split('x').last,
					breakpoint_min: breakpoint_size,
					breakpoint_max: breakpoints_max[breakpoint],
				}
			end

			resolutions
		end

		# sample: = attachment_background_tag '#boo', ActiveStorage::Attachment.last, xs: '100x100', md: '500x500', lg: '1000x1000'
		# sample: = attachment_background_tag '#boo', 'https://cdn1.neurohacker.com/uploads/Header-eaed8404-255c-4f31-a865-ee81e445f5b6.jpg', xs: 'https://wp.neurohacker.com/wp-content/uploads/2017/07/media_left.jpg 100x100', lg: 'https://cdn1.neurohacker.com/uploads/Headline_Bottles-7542e2fd-bb9b-47f2-bf9b-d96958b229be.png 200x200', style: 'width: auto !important;'
		def attachment_background_tag(selector, attachment, options={})
			resolutions = attachment_resolutions(attachment, options)
			smallest_resolution = resolutions.sort_by{ |resolution| resolution[:width].to_f * resolution[:height].to_f }.first

			content = <<-EOS
#{selector} {
	background-image: url('#{smallest_resolution[:src]}') !important;
}
EOS
			resolutions.each do |resolution|
				media = "(min-width: #{resolution[:breakpoint_min]}px)"
				media = "#{media} and (max-width: #{resolution[:breakpoint_max]}px)" if resolution[:breakpoint_max]

				content = content + <<-EOS
@media #{media} {
	#{selector} {
		background-image: url('#{resolution[:src]}') !important;
	}
}
EOS
			end

			content_tag( :style, raw( content ) )

		end



		# sample: = attachment_image_tag ActiveStorage::Attachment.last, xs: '100x100', md: '500x500', lg: '1000x1000', style: 'width: auto !important;'
		# sample: = attachment_image_tag 'https://cdn1.neurohacker.com/uploads/Header-eaed8404-255c-4f31-a865-ee81e445f5b6.jpg', xs: 'https://wp.neurohacker.com/wp-content/uploads/2017/07/media_left.jpg 100x100', lg: 'https://cdn1.neurohacker.com/uploads/Headline_Bottles-7542e2fd-bb9b-47f2-bf9b-d96958b229be.png 200x200', style: 'width: auto !important;'
		def attachment_image_tag(attachment, options={})
			lazy = options.delete(:lazy)
			lazy = 'lazy' if lazy && ( !!lazy == lazy )

			resolutions = attachment_resolutions(attachment, options)
			smallest_resolution = resolutions.sort_by{ |resolution| resolution[:width].to_f * resolution[:height].to_f }.first

			srcset = resolutions.collect do |resolution|
				"#{resolution[:src]} #{resolution[:width].to_i}w"
			end.join(',')

			sizes = nil
			#sizes = resolutions.collect do |resolution|
			#	media = "(min-width: #{resolution[:breakpoint_min]}px)"
			#	media = "#{media} and (max-width: #{resolution[:breakpoint_max]}px)" if resolution[:breakpoint_max]
			#	"#{media} #{resolution[:breakpoint_max] || 9999999}w"
			#end.join(',')

			if lazy
				options['data-srcset'] = srcset
				options['data-sizes'] = sizes

				image_tag( 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', options.merge( 'data-src' => attachment.service_url, class: "#{options[:class]} #{lazy}" ) )
			else
				options['srcset'] = srcset
				options['sizes'] = sizes

				image_tag( attachment.service_url, options )
			end

			#if lazy
			#	content = image_tag( 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', options.merge( 'data-src' => smallest_resolution[:src], class: "#{options[:class]} #{lazy}" ) )
			#else
			#	content = image_tag( smallest_resolution[:src], options )
			#end
			#resolutions.each do |resolution|
			#	media = "(min-width: #{resolution[:breakpoint_min]}px)"
			#	media = "#{media} and (max-width: #{resolution[:breakpoint_max]}px)" if resolution[:breakpoint_max]
			#	content = content_tag( :source, '', media: media, srcset: resolution[:src] ) + content
			#end
			#content_tag( :picture, content )

		end

		# sample: = attachment_picture_tag ActiveStorage::Attachment.last, xs: '100x100', md: '500x500', lg: '1000x1000', style: 'width: auto !important;'
		# sample: = attachment_picture_tag 'https://cdn1.neurohacker.com/uploads/Header-eaed8404-255c-4f31-a865-ee81e445f5b6.jpg', xs: 'https://wp.neurohacker.com/wp-content/uploads/2017/07/media_left.jpg 100x100', lg: 'https://cdn1.neurohacker.com/uploads/Headline_Bottles-7542e2fd-bb9b-47f2-bf9b-d96958b229be.png 200x200', style: 'width: auto !important;'
		def attachment_picture_tag(attachment, options={})
			lazy = options.delete(:lazy)
			lazy = 'lazy' if lazy && ( !!lazy == lazy )

			resolutions = attachment_resolutions(attachment, options)
			smallest_resolution = resolutions.sort_by{ |resolution| resolution[:width].to_f * resolution[:height].to_f }.first

			if lazy
				content = image_tag( 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=', options.merge( 'data-src' => smallest_resolution[:src], class: "#{options[:class]} #{lazy}" ) )
			else
				content = image_tag( smallest_resolution[:src], options )
			end

			resolutions.each do |resolution|
				media = "(min-width: #{resolution[:breakpoint_min]}px)"
				media = "#{media} and (max-width: #{resolution[:breakpoint_max]}px)" if resolution[:breakpoint_max]
				content = content_tag( :source, '', media: media, srcset: resolution[:src] ) + content
			end

			content_tag( :picture, content )

		end

		def set_css_if( args={} )
			class_name = args[:class] || 'active'

			if args[:path].present? && args[:path].is_a?( Array )
				args[:path].each do |path|
					return class_name if current_page?( path )
				end
			elsif args[:path].present?
				return class_name if current_page?( args[:path].to_s )
			elsif args[:url].present? && args[:url].is_a?( Array )
				args[:url].each do |url|
					return class_name if current_url == url.to_s
				end
			elsif args[:url].present?
				return class_name if current_url == ( args[:url].to_s )
			elsif args[:controller].present? && args[:controller].is_a?( Array )
				args[:controller].each do |controller|
					return class_name if controller_name == controller.to_s
				end
			elsif args[:controller].present?
				return class_name if controller_name == args[:controller].to_s
			end

			return args[:else_class]

		end

		# def render_content_sections( args = {} )

		# 	if args[:content_sections].present?
		# 		content_sections = args[:content_sections]
		# 	elsif args[:parent].present?
		# 		content_sections = args[:parent].content_sections
		# 	end

		# 	content_sections = content_sections.where( key: args[:key] )

		# 	content_sections = content_sections.order( position: :asc, id: :asc )
		# end

		def render_section( section, args = {} )
			partial_path = 'pulitzer/content_sections/partials/'

			partial = args[:partial] || section.partial || 'default'
			partial = partial_path + partial

			render partial, section: section
		end
	end
end
