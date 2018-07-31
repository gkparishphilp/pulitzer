module Pulitzer
	class User < ApplicationRecord
		self.table_name = 'users'

		attr_accessor	:login



		### Plugins   	     --------------------------------------
		include FriendlyId
		friendly_id :slugger, use: :slugged

		acts_as_taggable_array_on :tags



		### Class Methods    --------------------------------------
		# over-riding Deivse method to allow login via name or email

		def self.find_for_database_authentication(warden_conditions)
			conditions = warden_conditions.dup
			if login = conditions.delete(:login)
				where(conditions.to_h).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
			elsif conditions.has_key?(:username) || conditions.has_key?(:email)
				where(conditions.to_h).first
			end
		end

		def self.find_first_by_auth_conditions( warden_conditions )
			conditions = warden_conditions.dup
			if login = conditions.delete( :login )
				where( conditions ).where( ["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }] ).first
			else
				where( conditions ).first
			end
		end



		### Instance Methods --------------------------------------





	end
end