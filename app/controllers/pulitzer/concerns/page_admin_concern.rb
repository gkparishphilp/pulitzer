module Pulitzer
	module Concerns

		module PageAdminConcern
			extend ActiveSupport::Concern

			included do

			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			def page_search( term, options = {} )

				sort_by = options[:sort_by] || 'publish_at'
				sort_dir = options[:sort_dir] || 'desc'

				@pages = Page.order( Arel.sql("#{sort_by} #{sort_dir}") )

				@pages = @pages.where( redirect_url: nil ) unless options[:redirects]
				@pages = @pages.where( status: options[:status] ) if options[:status].present? && options[:status] != 'all'
				@pages = @pages.where( "array[:q] && keywords", q: term.downcase ) if term.present?

				@pages = @pages.page( options[:page] )

			end

		end

	end
end
