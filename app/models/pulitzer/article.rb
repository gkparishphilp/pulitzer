module Pulitzer

	class Article < Pulitzer::Media
		include Pulitzer::ArticleSearchable if (Pulitzer::ArticleSearchable rescue nil)


		def page_meta
			super.merge( fb_type: 'article' )
		end


		def reading_time( args={} )
			wpm = args[:wpm] || 225

			estimated_time = self.word_count / wpm.to_f

			return { minutes_only: estimated_time.round, minutes: estimated_time.to_i, seconds: ( ( estimated_time % 1 ) * 60 ).round }

		end

	end

end
