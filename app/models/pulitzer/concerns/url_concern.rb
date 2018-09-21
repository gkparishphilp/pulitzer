module Pulitzer
	module Concerns

		module URLConcern
			extend ActiveSupport::Concern

			included do
			end


			####################################################
			# Class Methods

			module ClassMethods

				def mounted_at( mounted_at )
					@mounted_at = mounted_at
				end

				def mounted_path
					@mounted_at
				end

				#def mounted_at
				#	return @@mounted_at
				#end

			end

			def path( args={} )
				mounted_at = args[:mounted_at] || self.class.mounted_path

				if mounted_at.nil? || mounted_at == '/'
					if self.slug == 'homepage'
						path = "/"
					else
						path = "/#{self.slug}"
					end
				else
					path = "#{mounted_at}/#{self.slug}"
				end

				if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
					path += '?' unless args.empty?
					path += args.map{ |k,v| "#{k}=#{URI.encode(v)}"}.join( '&' )
				end
				return path
			end

			def url( args={} )
				domain = ( args.present? && args.delete( :domain ) ) || Pulitzer.app_host
				protocol = ( args.present? && args.delete( :protocol ) ) || Pulitzer.default_protocol
				path = self.path( args )
				url = "#{protocol}://#{domain}#{self.path( args )}"

				return url

			end

		end

	end
end
