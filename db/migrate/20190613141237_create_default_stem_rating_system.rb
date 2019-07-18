
class CreateDefaultStemRatingSystem < ActiveRecord::Migration[5.2]
  
  def change

  	rating_system = ::StemRatingSystem.create(
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
        if (!::StemCriterium::where(name: criteria_name).first())
        	::StemCriterium.create(
        		:name => criteria_name, 
        		:weight => 1, 
        		:stem_rating_system_id => rating_system.id
        	)
        end
    end

    categories = Category::all()
    categories.each do |category|

        sql = "SELECT * FROM stem_rating_system_category WHERE "
        sql = sql + "category_id=" + category.id.to_s + "  AND "
        sql = sql + "stem_rating_system_id=" + rating_system.id.to_s
        result = ActiveRecord::Base.connection.execute(sql)

        if (result.ntuples == 0)
        	sql = "INSERT INTO stem_rating_system_category (category_id, stem_rating_system_id) "
        	sql = sql + "VALUES (" + category.id.to_s + ", " + rating_system.id.to_s + ")"
        	result = ActiveRecord::Base.connection.execute(sql)
        	# ::StemRatingSystemCategory.create(
        	# 	:category_id => category.id,
        	# 	:stem_rating_system_id => rating_system.id
        	# )
        end
    end

  end

end
