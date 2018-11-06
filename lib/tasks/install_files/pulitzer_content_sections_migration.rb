class PulitzerContentSectionsMigration < ActiveRecord::Migration[5.1]

	def change

		create_table :pulitzer_content_sections, force: true do |t|
			t.references			:parent, polymorphic: true
			t.string				:name, default: nil
			t.text 					:description, defult: nil
			t.string 				:slug
			t.string				:content_zone, default: 'content:after' # header, sidebar
			t.integer				:seq, default: 1
			t.string				:partial, default: nil
			t.string				:css_style, default: ''
			t.string				:css_classes, default: [], array: true
			t.text					:content
			t.hstore				:properties, default: {}
			t.timestamps
		end
		add_index :pulitzer_content_sections, [:parent_id,:parent_type,:content_zone,:seq]
		add_index :pulitzer_content_sections, :slug, unique: true
	end
end
