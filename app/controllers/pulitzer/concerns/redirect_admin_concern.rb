module Pulitzer
	module Concerns

		module RedirectAdminConcern
			extend ActiveSupport::Concern

			included do

			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods
			def redirect_search( term, options = {} )
				puts "redirect_search"
				sort_by = options[:sort_by] || 'publish_at'
				sort_dir = options[:sort_dir] || 'desc'

				@redirects = Redirect.order( Arel.sql("#{sort_by} #{sort_dir}") )
				@redirects = @redirects.where( status: options[:status] ) if options[:status].present? && options[:status] != 'all'
				@redirects = @redirects.where( "slug like :q OR redirect_url ilike :q", q: "%#{term.downcase}%" ) if term.present?
				@redirects = @redirects.page( options[:page] )

			end

		end

	end
end
