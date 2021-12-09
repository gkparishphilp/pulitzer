
# require 'codemirror-rails'
require 'core_extensions/active_storage/blob_extensions'
require 'awesome_nested_set'
require 'haml'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'paper_trail'
require 'route_downcaser'

module Pulitzer

	class << self
		mattr_accessor :app_description
		mattr_accessor :app_host
		mattr_accessor :app_logo
		mattr_accessor :app_name
		mattr_accessor :app_time_zone

		mattr_accessor :article_path

		mattr_accessor :article_avatars

		mattr_accessor :category_types

		mattr_accessor :asset_host

		mattr_accessor :contact_email_to
		mattr_accessor :contact_email_from

		mattr_accessor :default_layouts
		mattr_accessor :default_page_meta
		mattr_accessor :default_protocol
		mattr_accessor :default_user_status

		mattr_accessor :froala_editor_key

		mattr_accessor :reserved_words

		mattr_accessor :site_map_url



		self.app_description = 'A Very Swell App indeed'
		self.app_host = ENV['APP_DOMAIN'] || 'localhost:3000'
		self.app_name = 'SwellApp'
		self.app_time_zone = "Pacific Time (US & Canada)"

		self.article_path = 'articles'
		self.article_avatars = []

		self.asset_host = ENV['ASSET_HOST']

		self.category_types = [ ['ArticleCategory', 'Article Category'] ]

		self.default_layouts = {}
		self.default_protocol = 'http'
		self.default_page_meta = {}

		self.froala_editor_key = nil


		self.reserved_words = [ 'about', 'aboutus', 'account', 'admin', 'adm1n', 'administer', 'administor', 'administrater', 'administrator', 'anonymous', 'api', 'app', 'apps', 'auth', 'auther', 'author', 'blog', 'blogger', 'cache', 'changelog', 'ceo', 'config', 'contact', 'contact_us', 'contributer', 'contributor', 'cpanel', 'create', 'delete', 'directer', 'director', 'download', 'dowloads', 'edit', 'editer', 'editor', 'email', 'emailus', 'faq', 'favorites', 'feed', 'feeds', 'follow', 'followers', 'following', 'get', 'guest', 'help', 'home', 'hot', 'how_it_works', 'how-ti-works', 'howitworks', 'info', 'invitation', 'invitations', 'invite', 'jobs', 'list', 'lists', 'loggedin', 'loggedout', 'login', 'logout', 'member', 'members', 'moderater', 'moderator', 'mysql', 'new', 'news', 'nobody', 'oauth', 'openid', 'open_id', 'operater', 'operator', 'oracle', 'organizations', 'owner', 'popular', 'porn', 'postmaster', 'president', 'promo', 'promos', 'promotions', 'privacy', 'put', 'registar', 'register', 'registrar', 'remove', 'replies', 'retailer', 'retailers', 'root', 'rss', 'save', 'search', 'security', 'sessions', 'settings', 'signout', 'signup', 'sitemap', 'ssl', 'staff', 'status', 'stories', 'subscribe', 'support', 'terms', 'test', 'tester', 'tour', 'top', 'trending', 'unfollow', 'unsubscribe', 'update', 'url', 'user', 'users', 'vicepresident', 'viagra', 'webmaster', 'widget', 'widgets', 'wiki', 'wishlist', 'xfn', 'xmpp', 'xxx' ]

		self.site_map_url = "https://s3.amazonaws.com/#{ENV['FOG_DIRECTORY']}/sitemaps/sitemap.xml.gz"

	end

	# this function maps the vars from your app into your engine
     def self.configure( &block )
        yield self
     end


	class Engine < ::Rails::Engine
		isolate_namespace Pulitzer


		initializer "pulitzer.active_storage_blob" do
			ActiveSupport.on_load(:active_storage_blob) do
				ActiveStorage::Blob.prepend CoreExtensions::ActiveStorage::BlobExtensions
			end
		end

	end
end
