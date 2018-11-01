class PulitzerContentSectionsMigration < ActiveRecord::Migration[5.1]

	def change

		create_table :pulitzer_content_sections, force: true do |t|
			t.references		:parent, polymorphic: true
			t.string				:title, default: nil
			t.string				:key, default: 'content:after'
			t.integer				:position, default: 1
			t.string				:partial, default: nil
			t.string				:css_style, default: ''
			t.string				:css_classes, default: [], array: true
			t.text					:content
			t.hstore				:properties, default: {}
			t.timestamps
		end
		add_index :pulitzer_content_sections, [:parent_id,:parent_type,:key,:position]
	end
end
