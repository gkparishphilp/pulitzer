class PulitzerAutoLinkMigration  < ActiveRecord::Migration[5.1]

	create_table 	:auto_links do |t|
		t.integer	:site_id
		
		t.string 	:phrase
		t.string	:url

		t.integer 	:status, default: 0
		t.timestamps
	end

end