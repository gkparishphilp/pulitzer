module Pulitzer
	class ArticlesController < ApplicationController

		def index

			@query = params[:q] if params[:q].present?
			@tagged = params[:tagged]
			@author = User.friendly.find( params[:by] ) if params[:by].present?
			@category = Category.friendly.find( params[:in] ) if params[:in].present?

			@title = @category.try(:name)
			@title ||= "Blog"

			@articles = Pulitzer::Article.published.order( publish_at: :desc )
			@articles = @articles.where( category: @category ) if @category
			@articles = @articles.with_any_tags( @tagged ) if @tagged
			@articles = @articles.where( user: @author ) if @author

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the blog index" } )

		end


	end
end
