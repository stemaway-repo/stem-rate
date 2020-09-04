class ::StemPostCriteriaRating < ActiveRecord::Base
	self.table_name = "stem_post_criteria_rating"

	has_one :stem_post_rating
end
