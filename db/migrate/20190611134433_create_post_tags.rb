
class CreatePostTags < ActiveRecord::Migration[5.2]
  def change
  	if (!ActiveRecord::Base.connection.table_exists? 'post_tags')
	    create_table :post_tags do |t|
	    	t.references :post, null: false
	    	t.references :tag, null: false
	    end
    end

#    add_index :post_tags, [:topic_id, :tag_id], unique: true
  end
end
