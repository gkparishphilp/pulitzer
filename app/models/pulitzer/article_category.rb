module Pulitzer
	class ArticleCategory < Pulitzer::Category
		include Pulitzer::ArticleCategorySearchable if (Pulitzer::ArticleCategorySearchable rescue nil)

		def article_count
			SwellMedia::Article.published.where( category_id: self.id ).count
		end
	end

end
