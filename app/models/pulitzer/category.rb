module Pulitzer

	class Category < ApplicationRecord

		include Pulitzer::CategorySearchable if (Pulitzer::CategorySearchable rescue nil)

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		belongs_to 	:parent, :class_name => "Pulitzer::Category", optional: true
		belongs_to 	:site

		include FriendlyId
		friendly_id :name, use: :slugged, :scoped, scope: :site_id

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
