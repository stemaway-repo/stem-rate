class ::StemRatingSystem < ActiveRecord::Base
	has_many :stem_criteria
	has_many :stem_rating_system_category
	has_many :category, through: :stem_rating_system_category

	def to_s
		ret = ""
		for criterium in self.stem_criteria
			ret = ret + criterium.name + "(" + criterium.weight.to_s + "), "
		end
		return ret.delete_suffix!(', ')
	end
end
