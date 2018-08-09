module Pulitzer

	class Page < Pulitzer::Media

		def page_meta
			super.merge( fb_type: 'article' )
		end
		
	end

end