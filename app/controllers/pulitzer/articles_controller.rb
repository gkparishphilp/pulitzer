module Pulitzer
	class ArticlesController < ApplicationController

		def index
			@tags = []# Article.published.tags_counts

			@query = params[:q] if params[:q].present?
			@tagged = params[:tagged]
			@author = User.friendly.find( params[:by] ) if params[:by].present?
			@category = Category.friendly.find( params[:category] || params[:cat] ) if ( params[:category] || params[:cat] ).present?

			@title = @category.try(:name)
			@title ||= "Blog"

			@articles = Pulitzer::Article.order( publish_at: :desc )

			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the blog index" } )
			
		end

	end
end