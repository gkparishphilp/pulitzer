module Pulitzer

	class Category < ApplicationRecord

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		belongs_to :parent, :class_name => "Pulitzer::Category", optional: true

		include FriendlyId
		friendly_id :name, use: :slugged

		def self.published( args = {} )
			self.active.anyone
		end

		def title
			self.name
		end

		def to_s
			self.name
		end

	end

end
