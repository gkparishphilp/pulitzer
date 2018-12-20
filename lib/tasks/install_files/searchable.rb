module Searchable
	extend ActiveSupport::Concern

	included do

		include Elasticsearch::Model

		after_create :elastic_search_create
		after_update :elastic_search_update
	end

	def self.search( term, classes=nil )
		classes ||= [Bazaar::Product, Bazaar::SubscriptionPlan,User]
		Elasticsearch::Model.search(term, classes)
	end

	module ClassMethods
		def search( term, args = {} )
			self.__elasticsearch__.search term
		end

		def drop_create_index!
			self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
			self.__elasticsearch__.client.indices.create \
			  index: self.index_name,
			  body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
		end
	end


	def elastic_search_create
		self.__elasticsearch__.index_document
	end

	def elastic_search_update
		self.__elasticsearch__.index_document rescue self.__elasticsearch__.update_document
	end
end
