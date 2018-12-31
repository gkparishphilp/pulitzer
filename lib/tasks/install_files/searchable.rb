module Searchable
	extend ActiveSupport::Concern

	included do

		include Elasticsearch::Model

		after_create :elastic_search_create
		after_update :elastic_search_update
	end

	def self.search( term, options=nil )
		options ||= [Bazaar::Product, Bazaar::SubscriptionPlan,User]
		Elasticsearch::Model.search( term, options )
	end

	module ClassMethods
		def search( term, options = nil )
			if options.nil?
				self.__elasticsearch__.search term
			else
				self.__elasticsearch__.search term, options
			end
		end

		def drop_create_index!( args = { import: true } )
			self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
			self.__elasticsearch__.client.indices.create \
			  index: self.index_name,
			  body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
			self.import if args[:import]
		end
	end


	def elastic_search_create
		self.__elasticsearch__.index_document
	end

	def elastic_search_update
		self.__elasticsearch__.index_document rescue self.__elasticsearch__.update_document
	end
end
