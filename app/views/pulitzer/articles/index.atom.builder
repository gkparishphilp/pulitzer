atom_feed( language: 'en-US', url: articles_url( params.merge( format: 'html' ) ) ) do |feed|
	feed.title @title
	feed.updated @articles.try(:first).try(:created_at)

	@articles.each do |result|
		feed.entry result, { published: result.publish_at } do |entry|
			entry.title result.title

			entry.content render( 'content.html', result: result, args: {} )

			entry.author do |author|
				author.name result.user.full_name
			end
			entry.url result.url
			entry.summary (result.try(:content_preview) || result.try(:description_preview) || result.try(:sanitized_description) || result.try(:sanitized_description) || '').truncate(150)
		end
	end
end