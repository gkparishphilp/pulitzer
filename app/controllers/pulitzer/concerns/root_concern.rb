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
					else
						begin

							@media = Media.friendly.find( page_id )

							if not( @media.redirect_url.blank? )
								pulitzer_redirect( @media )
								return false
							elsif not(@media.publish_at_before_now?) || not(@media.active?)
								raise ActionController::RoutingError.new( 'Not Found' )
							elsif @media.authorized_users?
								authorize( @media )
							elsif @media.just_me? && ( current_user.nil? || @media.user != current_user )
								raise ActionController::RoutingError.new( 'Not Found' )
							elsif @media.logged_in_users? && current_user.nil?
								raise ActionController::RoutingError.new( 'Not Found' )
							elsif not( %w( anyone logged_in_users just_me authorized_users ).include?( @media.availability.to_s ) )
								raise ActionController::RoutingError.new( 'Not Found - Invalid availability' )
							end

							return true

						rescue ActiveRecord::RecordNotFound
							raise ActionController::RoutingError.new( 'Not Found' )
						end
					end
				else
					redirect_to root_path
				end

				return false
			end

			def pulitzer_redirect( media )
				redirect_to media.redirect_url, status: :moved_permanently
			end

			def pulitzer_render( media )

				set_page_meta( media.page_meta )

				render media.template, layout: media.layout

			end

		end

	end
end
