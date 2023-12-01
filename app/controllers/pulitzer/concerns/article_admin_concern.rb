module Pulitzer
	module Concerns

		module ArticleAdminConcern
			extend ActiveSupport::Concern

			included do

			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			def article_search( term, options = {} )

				sort_by = options[:sort_by] || 'publish_at'
				sort_dir = options[:sort_dir] || 'desc'

				@articles = Article.order( Arel.sql("#{sort_by} #{sort_dir}") )

				
				@articles = eval "@articles.#{options[:status]}" if options[:status].present? && options[:status] != 'all'
				@articles = @articles.where( "array[:q] && keywords", q: term.downcase ) if term.present?

				@articles = @articles.page( options[:page] )
			end

		end

	end
end
