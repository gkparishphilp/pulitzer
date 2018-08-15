class PulitzerActiveStorageMigration < ActiveRecord::Migration[5.1]

	def change

		add_column :active_storage_blobs, :tags, :text, array: true, default: []
		add_column :active_storage_attachments, :tags, :text, array: true, default: []

	end
end
