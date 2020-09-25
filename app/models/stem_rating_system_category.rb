class ::StemRatingSystemCategory < ActiveRecord::Base
	self.table_name = "stem_rating_system_category"
	belongs_to :category
	belongs_to :stem_rating_system
end
