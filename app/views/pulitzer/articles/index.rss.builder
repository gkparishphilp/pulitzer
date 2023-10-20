#encoding: UTF-8

if (request.user_agent || '').include?('Feedly/')

	xml.instruct! :xml, :version => "1.0"
	xml.rss :version => "2.0", 'xmlns:content'=>"http://purl.org/rss/1.0/modules/content/", 'xmlns:webfeeds' => "http://webfeeds.org/rss/1.0", 'xmlns:wfw'=>"http://wellformedweb.org/CommentAPI/", 'xmlns:dc'=>"http://purl.org/dc/elements/1.1/", 'xmlns:atom'=>"http://www.w3.org/2005/Atom", 'xmlns:sy'=>"http://purl.org/rss/1.0/modules/syndication/", 'xmlns:slash'=>"http://purl.org/rss/1.0/modules/slash/" do
		xml.channel do
			xml.title @title
			xml.link articles_url( params[:id], params.merge( format: 'html' ) )
			xml.description @subtitle
			# xml.lastBuildDate Time.now
			xml.language "en-US"
			xml.tag!( 'sy:updatePeriod', 'hourly' )
			xml.tag!( 'sy:updateFrequency', 1 )
			if @category.present?
				xml.category do
					xml.cdata!(@category.name)
				end
			end

			xml.tag!( 'atom:link', href: articles_url( params[:id], params.merge( format: 'atom' ) ), rel: 'self', type: 'application/rss+xml' )
			# xml.author "Shopswell"
			if @cover_img.present?
				xml.image do
					xml.title @title
					xml.url @cover_img
					xml.link articles_url( params[:id], params.merge( format: 'html' ) )
					# xml.width 0
					# xml.height 0
				end

				xml.tag!( 'webfeeds:cover', image: @cover_img )
			end
			# xml.tag!( 'webfeeds:icon', image_url('logo.svg') )
			# xml.tag!( 'webfeeds:accentColor', 'A97CB4' )
			xml.tag!( 'webfeeds:related', layout: 'card', target: 'browser' )

			for result in @articles
				xml.item do
					xml.title result.title
					xml.tag!( 'dc:creator' ) do
						xml.cdata!(result.user.full_name)
					end
					# xml.author result.user.full_name
					xml.pubDate result.created_at.to_fs(:rfc822)
					xml.link result.url
					xml.guid result.url, isPermaLink: false
					xml.category do
						xml.cdata!(result.category.name)
					end
					for tag in result.tags
						xml.category do
							xml.cdata!(tag)
						end
					end
					xml.description do
						xml.cdata! (result.description || result.try(:content_preview) || result.try(:description_preview) || result.try(:sanitized_description) || result.try(:sanitized_description) || '').truncate(150)
					end
					xml.tag!( 'content:encoded' ) do
						xml.cdata! render( 'content.html', result: result, args: { upsell: false } )
					end

				end
			end
		end
	end

else

	xml.instruct! :xml, :version => "1.0"
	xml.rss :version => "2.0", 'xmlns:content'=>"http://purl.org/rss/1.0/modules/content/", 'xmlns:wfw'=>"http://wellformedweb.org/CommentAPI/", 'xmlns:dc'=>"http://purl.org/dc/elements/1.1/", 'xmlns:atom'=>"http://www.w3.org/2005/Atom", 'xmlns:sy'=>"http://purl.org/rss/1.0/modules/syndication/", 'xmlns:slash'=>"http://purl.org/rss/1.0/modules/slash/" do
		xml.channel do
			xml.title @title
			xml.link articles_url( params[:id], params.merge( format: 'html' ) )
			xml.description @subtitle
			# xml.lastBuildDate Time.now
			xml.language "en-US"
			xml.tag!( 'sy:updatePeriod', 'hourly' )
			xml.tag!( 'sy:updateFrequency', 1 )
			if @category.present?
				xml.category do
					xml.cdata!(@category.name)
				end
			end

			xml.tag!( 'atom:link', href: articles_url( params[:id], params.merge( format: 'atom' ) ), rel: 'self', type: 'application/rss+xml' )
			# xml.author "Shopswell"
			if @cover_img.present?
				xml.image do
					xml.title @title
					# xml.url @cover_img
					xml.link articles_url( params[:id], params.merge( format: 'html' ) )
					# xml.width 0
					# xml.height 0
				end

			end

			for result in @articles
				xml.item do
					xml.title result.title
					xml.tag!( 'dc:creator' ) do
						xml.cdata!(result.user.full_name)
					end
					# xml.author result.user.full_name
					xml.pubDate result.created_at.to_fs(:rfc822)
					xml.link result.url
					xml.guid result.url, isPermaLink: false
					xml.category do
						xml.cdata!(result.category.name)
					end
					for tag in result.tags
						xml.category do
							xml.cdata!(tag)
						end
					end
					xml.description do
						xml.cdata! (result.description || result.try(:content_preview) || result.try(:description_preview) || result.try(:sanitized_description) || result.try(:sanitized_description) || '').truncate(150)
					end
					xml.tag!( 'content:encoded' ) do
						xml.cdata! render( 'content.html', result: result, args: {} )
					end

				end
			end
		end
	end

end
