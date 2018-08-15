class PulitzerMigration < ActiveRecord::Migration[5.1]

	def change

		create_table :pulitzer_categories, force: true do |t|
			t.references		:user 			# created_by
			t.references 		:parent
			t.string			:name
			t.string 			:type
			t.integer 			:lft
			t.integer 			:rgt
			t.text				:description
			t.string			:avatar
			t.string			:cover_image
			t.integer			:status, 					default: 1
			t.integer			:availability, 				default: 1 	# anyone, logged_in, just_me
			t.integer 			:seq
			t.string 			:slug
			t.hstore			:properties,				default: {}
			t.timestamps
		end
		add_index :pulitzer_categories, :type
		add_index :pulitzer_categories, :lft
		add_index :pulitzer_categories, :rgt
		add_index :pulitzer_categories, :slug, unique: true


		create_table :pulitzer_media do |t|
			t.references	:user 					# User who added it
			t.references	:managed_by 			# User acct that has origin acct (e.g. youtube) rights
			t.string		:public_id				# public id to spoof sequential id grepping
			t.references 	:category

			t.references 	:working_media_version

			t.references	:parent 				# for nested_set (podcasts + episodes, conversations, etc.)
			t.integer		:lft
			t.integer		:rgt

			t.string		:type 					# video, product, page, article, etc...
			t.string 		:media_type 			# text, html, audio, image, video
			t.string		:sub_type				# video, tv, dvd

			t.string		:title
			t.string		:subtitle
			t.text			:avatar
			t.string		:cover_image
			t.string		:avatar_caption
			t.string		:layout
			t.string		:template
			t.text			:description
			t.text			:meta_description
			t.text			:content
			t.string		:slug
			t.string		:redirect_url

			t.boolean 		:is_commentable, 				default: true
			t.boolean		:is_sticky,						default: false 		# for forum topics
			t.boolean		:show_title,					default: true
			t.datetime		:modified_at 								# because updated_at is inadequate when caching stats, etc.
			t.text			:keywords, 	array: true, 		default: []
			t.text 			:tags, array: true, 			default: []

			t.string		:duration
			t.integer		:cached_char_count, 			default: 0
			t.integer		:cached_word_count, 			default: 0

			t.integer		:status, 						default: 1
			t.integer		:availability, 					default: 1	# anyone, logged_in, just_me
			t.datetime		:publish_at
			t.hstore		:properties, default: {}


			t.timestamps
		end

		add_index :pulitzer_media, :tags, using: 'gin'
		add_index :pulitzer_media, :public_id
		add_index :pulitzer_media, :slug, unique: true
		add_index :pulitzer_media, [ :slug, :type ]
		add_index :pulitzer_media, [ :status, :availability ]


		create_table :pulitzer_media_versions do |t|
			t.references 		:media
			t.references		:user
			t.integer			:status, 					default: 1
			t.json				:versioned_attributes, 		default: {}

			t.timestamps
		end
		add_index :pulitzer_media_versions, [ :media_id, :id ]
		add_index :pulitzer_media_versions, [ :media_id, :status, :id ]

	end
end
