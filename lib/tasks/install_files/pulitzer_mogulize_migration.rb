class PulitzerMogulizeMigration < ActiveRecord::Migration[5.1]

	def change

		create_table 	:auto_links do |t|
			t.string 	:phrase
			t.string	:url

			t.integer 	:status, default: 0
			t.timestamps
		end
		
		create_table 	:site_assets do |t|
			t.string	:asset_type			# document, image, audio, video, css, js
			t.string	:title
			
			t.integer	:status, 		default: 0
			t.timestamps
		end

		create_table 	:sits do |t|
			t.string	:name
			t.string	:domain

			t.integer	:status, 		default: 0
			t.timestamps
		end


		add_column	:pulitzer_media, :site_id, :integer



	end
end
