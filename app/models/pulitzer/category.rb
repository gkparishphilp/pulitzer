module Pulitzer

	class Category < ApplicationRecord

		include Pulitzer::CategorySearchable if (Pulitzer::CategorySearchable rescue nil)

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		belongs_to :parent, :class_name => "Pulitzer::Category", optional: true

		has_one_attached :avatar_attachment
		has_one_attached :cover_attachment

		has_many_attached :embedded_attachments
		has_many_attached :other_attachments

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
