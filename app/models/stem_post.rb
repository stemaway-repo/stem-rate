
class ::StemPost < Post

	has_many :post_tags
	has_many :tags, through: :post_tags, dependent: :destroy
	has_many :tag_users, through: :tags

	class << StemPost

		def extract_tags(post)

			# drop old tags	
			PostTag.where(:post_id => post.id).destroy_all()
			
			# extract new tags
			tags = post.raw.scan(/#[a-zA-Z]+/)

			# create and link new tags
			tags.each do |tag_name|
				tag_name.slice!(0)
				tag = Tag.where(name: tag_name).first()
				if (!tag)
					tag = Tag.create(name: tag_name)
				end
				PostTag.create(tag_id: tag.id, post_id: post.id)
			end


		end

	end

end