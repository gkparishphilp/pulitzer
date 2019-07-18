module Pulitzer

	class AutoLink < ApplicationRecord

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }

		belongs_to :site, optional: true


	end

end