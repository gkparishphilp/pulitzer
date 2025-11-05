module Pulitzer
	require 'net/http'
	require 'uri'

	class Media < ApplicationRecord

		include Pulitzer::Concerns::UrlConcern
		#include Pulitzer::Concerns::ExpiresCache
		include Pulitzer::MediaSearchable if (Pulitzer::MediaSearchable rescue nil)

		mounted_at '/'

		#expires_cache :user_id, :managed_by_id, :public_id, :category_id, :parent_id, :lft, :rgt, :type, :sub_type, :title, :subtitle, :avatar, :cover_image, :avatar_caption, :layout, :template, :description, :content, :slug, :is_commentable, :is_sticky, :show_title, :modified_at, :keywords, :duration, :price, :status, :availability, :publish_at, :tags


		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 100, 'trash' => -50 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3, 'authorized_users' => 100 }

		before_create	:set_template_and_layout
		before_save		:set_publish_at, :set_cached_counts, :set_avatar

		validates		:title, presence: true, unless: :allow_blank_title?
		validate 		:validate_redirect_url_format
		validate 		:validate_redirect_url_not_same_as_slug
		validate 		:validate_redirect_url_redirect_chain
		validate 		:validate_redirect_url_not_matching_other_slugs

		attr_accessor	:slug_pref, :category_name

		belongs_to	:user, optional: true
		has_many 	:media_versions, -> { order("id DESC") }
		has_many 	:content_sections, -> { order("seq ASC") }, as: :parent

		belongs_to 	:managed_by, class_name: 'User', optional: true
		belongs_to 	:category, optional: true

		has_one_attached :avatar_attachment
		has_one_attached :cover_attachment
		has_many_attached :embedded_attachments
		has_many_attached :other_attachments

		include FriendlyId
		friendly_id :slugger, use: [ :slugged, :history ]

		acts_as_nested_set

		acts_as_taggable_array_on :tags

		accepts_nested_attributes_for :content_sections

		has_paper_trail ignore: [ :created_at, :updated_at ]


		# Class Methods

		def self.media_tag_cloud( args = {} )
			args[:limit] ||= 7
			media_relation = self.limit(nil)
			return Pulitzer::Media.unscoped.tags_cloud{ merge( media_relation ) }.to_a.sort_by(&:second)[-args[:limit]..-1]
		end

		# def self.other_attachments_with_tags( tags = [] )
		# 	query = self.all
		# 	tags.each do |tag|
		# 		query = query.where( "? = ANY(annotations)", tag )
		# 	end
		# 	query
		# end


		def self.published( args = {} )
			where( "pulitzer_media.publish_at <= :now", now: Time.zone.now ).active.anyone
		end


		def self.publish_at_before_now( args = {} )
			where( "pulitzer_media.publish_at <= :now", now: Time.zone.now )
		end

		def publish_at_before_now?( args = {} )
			publish_at <= Time.zone.now
		end

		def published?
			active? && anyone? && publish_at_before_now?
		end


		# Instance Methods

		def category_name=( name )
			self.category = Pulitzer::Category.where( name: name ).first_or_create
		end

		def char_count
			return 0 if self.content.blank?
			self.sanitized_content.gsub(URI.regexp(['http', 'https']), '').size
		end

		def comments( args = {} )
			user_posts = SwellSocial::UserPost.where( parent_obj_id: self.id, parent_obj_type: self.class.name )
			user_posts.order( created_at: (args[:order] || :desc) )
		end

		def page_meta
			if self.meta_title.present?
				title = "#{self.meta_title} | #{Pulitzer.app_name}"
			elsif self.title.present?
				title = "#{self.title} | #{Pulitzer.app_name}"
			else
				title = Pulitzer.app_name
			end

			return {
				page_title: title,
				title: title,
				description: self.meta_description,
				image: self.avatar,
				url: self.url,
				twitter_format: 'summary_large_image',
				type: 'article',
				og: {
					"article:published_time" => self.publish_at.iso8601,
					"article:author" => self.user.to_s
				},
				data: {
					'url' => self.url,
					'name' => self.title,
					'description' => self.sanitized_description,
					'datePublished' => self.publish_at.iso8601,
					'author' => self.user.to_s,
					'image' => self.avatar
				}

			}
		end

		def parent_slug=( slug )
			parent_media = Pulitzer::Media.find_by( slug: slug )
			if parent_media
				self.parent = parent_media
			end
		end

		def parent_slug
			self.parent.try(:slug)
		end

		# def new_embedded_attachments=( attachments )
		# 	self.embedded_attachments.attach( attachments )
		# end

		# def new_other_attachments=( attachments )
		# 	self.other_attachments.attach( attachments )
		# end


		def sanitized_content
			ActionView::Base.full_sanitizer.sanitize( self.content )
		end

		def sanitized_description
			ActionView::Base.full_sanitizer.sanitize( self.description )
		end

		def should_generate_new_friendly_id?
			self.slug.nil? || self.slug_pref.present?
		end

		def slugger
			if self.slug_pref.present?
				self.slug = nil # friendly_id 5.0 only updates slug if slug field is nil
				return self.slug_pref
			else
				return self.title
			end
		end

		def tags_csv
			self.tags.join(',')
		end

		def tags_csv=(tags_csv)
			self.tags = tags_csv.split(/,\s*/)
		end

		def to_s
			self.title.present? ? self.title : self.slug
		end

		def word_count
			return 0 if self.content.blank?
			self.sanitized_content.gsub(URI.regexp(['http', 'https']), '').scan(/[\w-]+/).size
		end

		# Validations

		def validate_redirect_url_format
			return unless respond_to?( :redirect_url )
			return if redirect_url.blank?

			# Allow path-style redirects (start with '/')
			# Allow host-style redirects that start with 'www.'
			if redirect_url.start_with?( '/' ) || redirect_url.start_with?( 'www.' )
				return
			end

			# Validate full URL format
			begin
				uri = URI.parse( redirect_url )
				unless uri.scheme && %w[http https www].include?( uri.scheme )
					errors.add( :redirect_url, "Must start with http, https, www. or be a path beginning with '/'" )
				end
			rescue URI::InvalidURIError
				errors.add( :redirect_url, "Must start with http, https, www. or be a path beginning with '/'" )
			end
		end

		def validate_redirect_url_not_same_as_slug
			return unless (respond_to?( :redirect_url ) && respond_to?( :slug ))
			return if redirect_url.blank?

			redirect_slug = redirect_url.to_s
			if redirect_slug == slug.to_s || redirect_slug == "/#{slug}"
				errors.add( :redirect_url, "Cannot be the same as the slug: #{slug}" )
			end
		end

		def validate_redirect_url_redirect_chain
			return unless respond_to?( :redirect_url )
			return if redirect_url.blank?

			# Build an absolute URL to follow redirects
			if redirect_url.start_with?( '/' )
				full_url = "#{Pulitzer.default_protocol}://#{Pulitzer.app_host}#{redirect_url}"
			elsif redirect_url.start_with?( 'www.' )
				full_url = "#{Pulitzer.default_protocol}://#{redirect_url}"
			else
				full_url = redirect_url
			end

			# Localhost adjustment for development/testing: localhost:3001 -> localhost:3000
			if full_url.include?('localhost:3001')
				full_url = full_url.gsub('localhost:3001', 'localhost:3000')
			end

			max_redirects = 2
			result = count_redirects( full_url )
			print "Redirect check for #{full_url}: #{result.inspect}"
			if result.nil?
				errors.add( :redirect_url, "Could not be validated (network error or invalid URL)" )
			else
				redirects, final_code = result
				if final_code.nil?
					errors.add( :redirect_url, "Could not determine final HTTP status" )
				elsif !(200..399).include?( final_code )
					errors.add( :redirect_url, "Returned HTTP status #{final_code}; It Must be 2xx or 3xx" )
				elsif redirects > max_redirects
					errors.add( :redirect_url, "Redirects too many times (#{redirects} redirects); It must be #{max_redirects} or fewer" )
				end
			end
		end

		# This validation ensures that the redirect_url path does not match another record's slug
		# Which can cause infinite redirect loops
		def validate_redirect_url_not_matching_other_slugs
			return unless respond_to?( :redirect_url )
			return if redirect_url.blank?

			# Extract path from redirect_url (handles both path-style and full URLs)
			path = if redirect_url.start_with?( '/' )
				redirect_url
			else
				begin
					URI.parse( redirect_url ).path
				rescue URI::InvalidURIError
					nil
				end
			end

			return if path.blank?

			segments = path.split('/').reject{ |s| s.blank? }
			return if segments.empty?

			redirect_url_slug = segments.last

			# If redirect_url equals it's own slug, that's already handled elsewhere
			if respond_to?( :slug ) && redirect_url_slug == slug.to_s
				return
			end

			if Pulitzer::Media.where.not(id: id).exists?( slug: redirect_url_slug )
				errors.add( :redirect_url, "Cannot point to an existing media slug ('#{redirect_url_slug}')" )
			end
		end

		private

			def allow_blank_title?
				self.slug_pref.present?
			end

			def set_avatar
				self.avatar = self.avatar_attachment.url if self.avatar_attachment.attached?
				self.cover_image = self.cover_attachment.url if self.cover_attachment.attached?
			end

			def set_cached_counts
				if self.respond_to?( :cached_word_count )
					self.cached_word_count = self.word_count
				end

				if self.respond_to?( :cached_char_count )
					self.cached_char_count = self.char_count
				end
			end

			def set_publish_at
				# set publish_at
				self.publish_at ||= Time.zone.now
			end

			def set_keywords_and_tags
				common_terms = ["able", "about", "above", "across", "after", "almost", "also", "among", "around", "back", "because", "been", "below", "came", "cannot", "come", "cool", "could", "dear", "does", "down", "each", "either", "else", "ever", "every", "find", "first", "from", "from", "gave", "give", "goodhave", "have", "hers", "however", "inside", "into", "its", "just", "least", "like", "likely", "little", "live", "long", "made", "make", "many", "might", "more", "most", "must", "neither", "number", "often", "only", "other", "our", "outside", "over", "part", "people", "place", "rather", "said", "says", "should", "show", "side", "since", "some", "sound", "take", "than", "that", "the", "their", "them",  "then", "there", "these", "they", "thing", "this", "those", "time", "twas", "under", "upon", "was", "wants", "were", "what", "whatever", "when", "where", "which", "while", "whom", "will", "with", "within", "work", "would", "write", "year", "you", "your"]

				# auto-tag hashtags
				unless self.description.blank?
					# hashtags must start with a # and must contain at least one letter
					hashtags = self.sanitized_description.scan( /#([a-zA-Z_0-9]*[a-zA-Z][a-zA-Z_0-9]*)/ ).flatten.uniq
					new_tags = (hashtags + self.tags).uniq.sort

					self.tags = new_tags unless new_tags & (self.tags || []) == new_tags
				end

				new_keywords = "#{self.user} #{self.title}".downcase.split( /\W/ ).delete_if{ |elem| elem.length <= 2 }.delete_if{ |elem| common_terms.include?( elem ) }.uniq
				self.tags.each{ |tag| new_keywords << tag.to_s unless new_keywords.include?( tag.to_s )}

				new_keywords = new_keywords.uniq.sort

				self.keywords = new_keywords unless new_keywords & (self.keywords || []) == new_keywords

			end

			def set_template_and_layout
				self.layout ||= ( Pulitzer.default_layouts[Media.class.name] || Pulitzer.default_layouts[self.class.name] || 'application' )
				self.template ||= "#{self.class.name.underscore.pluralize}/show"
			end

			def count_redirects( url )
				uri = URI.parse( url )
				redirects = 0
				visited = []
				while redirects <= 20
					break unless uri.is_a?( URI::HTTP )
					http = Net::HTTP.new( uri.host, uri.port )
					http.use_ssl = ( uri.scheme == 'https' )
					http.open_timeout = 5
					http.read_timeout = 5
					req = Net::HTTP::Head.new( uri.request_uri )
					response = http.request( req )
					case response
					when Net::HTTPRedirection
						location = response['location']
						return nil if location.blank?
						uri = URI.join( uri, location )
						redirects += 1
						# Detect loops
						return nil if visited.include?( uri.to_s )
						visited << uri.to_s
						next
					when Net::HTTPSuccess
						# Final successful response
						return [ redirects, response.code.to_i ]
					else
						# Final non-success, non-redirect status (e.g., 4xx, 5xx)
						return [ redirects, response.code.to_i ]
					end
				end
				# If we exit loop without explicit final response, return current redirects with nil status
				[ redirects, nil ]
				rescue StandardError
					nil
			end

	end

end
