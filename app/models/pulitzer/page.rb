module Pulitzer

	class Page < Pulitzer::Media

		include Pulitzer::PageSearchable if (Pulitzer::PageSearchable rescue nil)

		after_create :add_content_section

		def page_meta
			super.merge( fb_type: 'article' )
		end


		private
			def add_content_section
				section = self.content_sections.create( name: "#{self.title}-main") if self.content_sections.blank?
			end

	end

end
