module Pulitzer
	class ArticleCategory < SwellMedia::Category

		def article_count
			SwellMedia::Article.published.where( category_id: self.id ).count
		end
	end

end
