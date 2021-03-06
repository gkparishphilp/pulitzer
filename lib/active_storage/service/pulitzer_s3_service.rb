
# frozen_string_literal: true

require "aws-sdk-s3"
require "active_support/core_ext/numeric/bytes"
require 'active_storage/service/s3_service'

module ActiveStorage
  class Service::PulitzerS3Service < Service::S3Service

		# Prettifies public URLS
		def url(key, expires_in:, disposition:, filename:, content_type:)
			if expires_in.to_f == 300 && ['attachment','inline'].include?(disposition.to_s)
				"#{Pulitzer.asset_host}/#{key}"
			else
				super( key, expires_in: expires_in, disposition: disposition, filename: filename, content_type: content_type )
			end
		end
	end
end
