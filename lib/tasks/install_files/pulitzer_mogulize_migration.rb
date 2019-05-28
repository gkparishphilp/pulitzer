class PulitzerMogulizeMigration < ActiveRecord::Migration[5.1]

	def change

		create_table 	:pulitzer_site_assets do |t|
			t.string	:asset_type			# document, image, audio, video, css, js
			t.string	:title
			
			t.integer	:status, 		default: 0
			t.timestamps
		end

		create_table 	:pulitzer_sites do |t|
			t.string	:name
			t.string 	:title
			t.string	:domain

			t.text 		:description
			t.string	:site_map_url
			t.string	:blog_path

			t.integer	:status, 		default: 0
			t.timestamps
		end


		add_column	:pulitzer_media, :site_id, :integer
		add_column	:pulitzer_categories, :site_id, :integer



	end
end
