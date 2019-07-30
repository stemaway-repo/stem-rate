
class CreateDefaultStemRatingSystem < ActiveRecord::Migration[5.2]

  class StemRatingSystem < ActiveRecord::Base
  end

  class StemCriterium < ActiveRecord::Base
  end

  class StemRatingSystemCategory < ActiveRecord::Base
    self.table_name = "stem_rating_system_category"
  end
  
  def change

  	rating_system = StemRatingSystem.create(
  				:name => 'Default Rating System')

    criteria_names = [
    	"Originality/Creativity",
    	"Clear Communication",
    	"Technical Excellence",
    	"Stimulates Thinking & Understanding",
    	"Provides Actionable Guidance",
    	"Useful Site Information"
    ]

    criteria_names.each do |criteria_name|
    	# sql = "INSERT INTO stem_criteria (name, weight, stem_rating_system_id) "
    	# sql = sql + "VALUES (" + criteria_name +", 1, " + rating_system.id.to_s + ")"
    	# result = ActiveRecord::Base.connection.execute(sql)
        if (!StemCriterium::where(name: criteria_name).first())
        	StemCriterium.create(
        		:name => criteria_name, 
        		:weight => 1, 
        		:stem_rating_system_id => rating_system.id
        	)
        end
    end

    categories = Category::all()
    categories.each do |category|
        StemRatingSystemCategory.create(
            :category_id => category.id,
            :stem_rating_system_id => rating_system.id
        )
    end

  end

end
