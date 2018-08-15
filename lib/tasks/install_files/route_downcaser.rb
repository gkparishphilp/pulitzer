RouteDowncaser.configuration do |config|

	# force-downcase all URLs
	config.redirect = true
	config.exclude_patterns = [
		/rails\/active_storage\//i,
	]
end
