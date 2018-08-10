module Pulitzer
	module Concerns

		module ApplicationControllerConcern
			extend ActiveSupport::Concern

			included do		
				helper Pulitzer::ApplicationHelper
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods

			
			
			def set_flash( msg, code=:success, *objs )
				if flash[code].blank?
					flash[code] = "<p>#{msg}</p>"
				else
					flash[code] += "<p>#{msg}</p>"
				end
				objs.each do |obj|
					obj.errors.each do |error|
						flash[code] += "<p>#{error.to_s}: #{obj.errors[error].join(';')}</p>"
					end
				end
			end

			def set_page_meta( args={} )

				type = args[:type] || 'Article'

				default_page_meta_og = ( Pulitzer.default_page_meta[:og] || {})

				@page_meta = Pulitzer.default_page_meta.deep_merge({
					title: args[:page_title] || args[:title] || Pulitzer.default_page_meta[:title] || Pulitzer.app_name,
					description: args[:description] || Pulitzer.default_page_meta[:description] || Pulitzer.app_description,
					url: request.url,
					og: {
						title: args[:title] || default_page_meta_og[:title] || Pulitzer.app_name,
						type: type,
						site_name: default_page_meta_og[:site_name] || Pulitzer.app_name,
						url: request.url,
						description: args[:description] || default_page_meta_og[:description] || Pulitzer.app_description,
						image: args[:image] || default_page_meta_og[:image] || Pulitzer.app_logo
					}
				})

				@page_meta = @page_meta.deep_merge( args )
				@page_meta[:schema] = { "@context" => "http://schema.org/", "@type" => type }.deep_merge( @page_meta[:data] ) if @page_meta[:data].present?

			end



		end

	end
end