module Pulitzer
	module Concerns

		module RootConcern
			extend ActiveSupport::Concern

			included do		
				
			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			
			def get_pulitzer_media( id )
				if id.present?
					page_id = id.downcase
					if page_id.match( /sitemap/i )
						redirect_to Pulitzer.site_map_url
						return false
					else
						begin
							@media = Media.friendly.find( page_id )
							if not( @media.redirect_url.blank? )
								redirect_to @media.redirect_url, status: :moved_permanently and return
							elsif not( @media.published? )
								raise ActionController::RoutingError.new( 'Not Found' )
							end
						rescue ActiveRecord::RecordNotFound
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					redirect_to root_path
					return false
				end
			end

		end

	end
end