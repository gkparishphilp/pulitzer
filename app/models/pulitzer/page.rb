module Pulitzer

	class Page < Pulitzer::Media

		after_create :add_content_section

		def page_meta
			super.merge( fb_type: 'article' )
		end


		private
			def add_content_section
				section = self.content_sections.create( name: "#{self.title}-main")
			end

	end

end
