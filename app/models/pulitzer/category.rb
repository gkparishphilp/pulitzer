module Pulitzer

	class Category < ApplicationRecord

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }


		def self.published( args = {} )
			self.active.anyone
		end

	end

end
