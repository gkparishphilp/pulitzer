module Pulitzer

	class ContentSection < ApplicationRecord

		belongs_to :parent, polymorphic: true

		has_one_attached :background_attachment
		has_many_attached :embedded_attachments

	end

end
