
class CreateStemRatingSystem < ActiveRecord::Migration[5.2]

  def change

    if (!ActiveRecord::Base.connection.table_exists? 'stem_rating_systems')
        create_table :stem_rating_systems do |t|
        	t.string :name
        	t.timestamps
        end
    end

    if (!ActiveRecord::Base.connection.table_exists? 'stem_rating_system_category')
        create_table :stem_rating_system_category do |t|
        	t.references :category, null: false
        	t.references :stem_rating_system, null: false
        end
        # add_index :stem_rating_system_category, 
        # 	[:stem_rating_system_id, :category_id], unique: true
    end

    if (!ActiveRecord::Base.connection.table_exists? 'stem_criteria')
        create_table :stem_criteria do |t|
        	t.string :name
        	t.float :weight
        	t.references :stem_rating_system, null: false
        end
    end

    if (!ActiveRecord::Base.connection.table_exists? 'stem_post_ratings')
        create_table :stem_post_ratings do |t|
        	t.references :post, null: false
        	t.references :user, null: false
        	t.float :average_value
        end
    end

    if (!ActiveRecord::Base.connection.table_exists? 'stem_post_criteria_rating')
        create_table :stem_post_criteria_rating do |t|
        	t.references :stem_user_post_rating, null: false
        	t.references :stem_criteria, null: false
        	t. float :value
        end
    end

  end

end
