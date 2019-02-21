module Pulitzer

	class ContentSection < ApplicationRecord

		belongs_to :parent, polymorphic: true

		has_one_attached :background_attachment
		has_many_attached :embedded_attachments


		include FriendlyId
		friendly_id :name, use: :slugged

		has_paper_trail

		before_save	:set_seq



		private
			def set_seq
				#self.seq ||= ( Pulitzer::ContentSection.maximum( :seq ) || 0 ) + 1
				Pulitzer::ContentSection.where.not( id: self.id ).where( 'seq >= :seq', seq: self.seq ).update_all( "seq = seq + 1" ) if self.seq_changed?
			end

	end

end
