module Pulitzer
	class Redirect < Pulitzer::Media

		include Pulitzer::RedirectSearchable if (Pulitzer::RedirectSearchable rescue nil)

		private
			def allow_blank_title?
				true
			end

	end
end