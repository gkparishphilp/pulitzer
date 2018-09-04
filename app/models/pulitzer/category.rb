module Pulitzer

	class Category < ApplicationRecord

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }

	end

end
