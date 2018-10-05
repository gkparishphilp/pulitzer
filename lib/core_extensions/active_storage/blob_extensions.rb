module CoreExtensions
	module ActiveStorage
		module BlobExtensions
			def key
				# We can't wait until the record is first saved to have a key for it
				if self[:filename]
					self[:key] ||= "#{self.class.generate_unique_secure_token}#{self.filename.try(:extension_with_delimiter)}"
				else
					self[:key] ||= "#{self.class.generate_unique_secure_token}"
				end
			end
		end
	end
end
