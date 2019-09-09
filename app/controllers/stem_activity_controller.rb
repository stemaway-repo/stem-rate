
class ::StemactivityController < ::ApplicationController
	
	def posts_by_tag

		tag_name = params[:tag]
		tag = Tag.where(name: tag_name).first()
		
		user = fetch_user_from_params(include_inactive: true)

		result = {}

		topics = user.topics
		posts = user.posts

		# todo: efficient select :)

		for topic in topics do
			if topic.tags.include? tag_name
				if result[topic.id] == nil

					post_ids = Post.where(topic_id: topic.id).pluck(:id)
					rating = StemPostRating.where(post_id: post_ids).average(:average_value)
					count = StemPostRating.where(post_id: post_ids).count()

					result[topic.id] = {}
					result[topic.id]['topic'] = topic
					result[topic.id]['comments'] = []
					result[topic.id]['comments'].append(topic)

					result[topic.id]['topic_rating'] = rating
					result[topic.id]['topic_vote_count'] = count
					result[topic.id]['topic_category_name'] = topic.category.name
				end
			end
		end

		for post in posts do
			topic = post.topic

			tags = PostTag.includes(:tag).where(post_id: post.id)
			tags = tags.map {|post_tag| post_tag.tag}
			if topic != nil
				tags = tags + topic.tags
			end
			tags = tags.select {|tag| tag != nil}
			tag_names = tags.map {|tag| tag.name}

			if tag_names.include? tag_name
				if result[topic.id] == nil
					post_ids = Post.where(topic_id: topic.id).pluck(:id)
					rating = StemPostRating.where(post_id: post_ids).average(:average_value)
					count = StemPostRating.where(post_id: post_ids).count()

					result[topic.id] = {}
					result[topic.id]['topic'] = topic
					result[topic.id]['comments'] = []

					result[topic.id]['topic_rating'] = rating
					result[topic.id]['topic_vote_count'] = count
					result[topic.id]['topic_category_name'] = topic.category.name
				end

				data = {}
				data['post'] = post
				data['post_rating'] = StemPostRating.where(:post_id => post.id)
				                        .average(:average_value)
				data['post_vote_count'] = StemPostRating.where(:post_id => post.id)
							.count()
				
				result[topic.id]['comments'].append(data)
			end
		end

		# for post in posts do
		# 	topic = post.topic
		# 	tags = PostTag.includes(:tag).where(post_id: post.id)
		# 	tags = tags.map { |post_tag| post_tag.tag }
		# 	tags = tags + topic.tags
		# 	for tag in tags
		# 		if posts_by_tag[tag.name] == nil
		# 			posts_by_tag[tag.name] = []
		# 		end
		# 		posts_by_tag[tag.name].append({
		# 			:id => post.id,
		# 			:snip => post.raw.truncate(
		# 				SiteSetting.post_snippet_max_length),
		# 			:category => topic.category.name,
		# 			:title => topic.title
		# 		})
		# 	end
		# end
		
		respond_to do |format|
			msg = { 
				:topics => result
				# :posts => posts
			}
			format.json { render :json => msg }
		end
	end

end
