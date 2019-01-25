class PulitzerUnattachedBlobsMigration < ActiveRecord::Migration[5.1]

	def change

		add_column :active_storage_blobs, :type, :string, default: nil

	end
end
