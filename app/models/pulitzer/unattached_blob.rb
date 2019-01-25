module Pulitzer

	class UnattachedBlob < ActiveStorage::Blob
		include Pulitzer::UnattachedBlobSearchable if (Pulitzer::UnattachedBlobSearchable rescue nil)

		acts_as_taggable_array_on :tags

		def purge( options = {} )
			if options[:force]
				super()
			else
				true
			end
		end

		def tags_csv
			self.tags.join(',')
		end

		def tags_csv=(tags_csv)
			self.tags = tags_csv.split(/,\s*/)
		end

	end

end
