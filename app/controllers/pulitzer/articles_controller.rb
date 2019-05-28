module Pulitzer
	class ArticlesController < ApplicationController


		def by_author

			@author = User.friendly.find( params[:id] )

			@title = "Articles by #{@author}"

			@articles = Pulitzer::Article.where( site_id: @current_site.id ).published.order( publish_at: :desc )

			@articles = @articles.where( user: @author ) if @author

			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the author: #{@author}index" } )

		end

		def in_category

			@category = Category.friendly.find( params[:id] ) if ( params[:id] ).present?

			@title = "Articles in #{@category.try(:name)}"

			@articles = Pulitzer::Article.where( site_id: @current_site.id, category: @category ).published.order( publish_at: :desc )

			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the category: #{@category} index" } )

		end

		def tagged

			@tag params[:id] ) if ( params[:id] ).present?

			@title = "Articles tagged #{@tag}"

			@articles = Pulitzer::Article.where( site_id: @current_site.id ).published.order( publish_at: :desc )

			@articles = @articles.with_any_tags( @tag )
			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the category: #{@category} index" } )

		end




		def index

			@title = "Blog"

			@articles = Pulitzer::Article.where( site_id: @current_site.id ).published.order( publish_at: :desc )

			# set count before pagination
			@count = @articles.count

			@articles = @articles.page( params[:page] )

			set_page_meta title: @title, og: { type: 'blog' }, twitter: { card: 'summary' }

			log_event( { name: 'pageview', content: "viewed the blog index" } )

		end


	end
end
