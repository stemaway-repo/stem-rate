
class ::StemactivityController < ::ApplicationController

	def create_tag
		tag_name = params[:tag]
		tag = Tag.where(name: tag_name).first_or_create

		respond_to do |format|
			msg = { 
				:tag => tag
			}
			format.json { render :json => msg }
		end
	end

	def posts_by_tag

		tag_name = params[:tag]
		tag = Tag.where(name: tag_name).first()
		
		user = fetch_user_from_params(include_inactive: true)

		result = {}

		topics = user.topics
		posts = user.posts

		# todo: efficient select :)

		for topic in topics do
			topic_id = topic.id
			if topic.tags.include? tag_name
				if result[topic_id] == nil

					post_ids = Post.where(topic_id: topic_id).pluck(:id)
					rating = StemPostRating.where(post_id: post_ids).average(:average_value)
					count = StemPostRating.where(post_id: post_ids).count()
					cat_name = topic.category.name

					result[topic_id] = {}

					topic = topic.slice(
						:id,
						:title,
						:last_posted_at,
						:created_at,
						:updated_at,
						:views,
						:posts_count,
						:user_id,
						:last_post_user_id,
						:reply_count,
						:deleted_at,
						:image_url,
						:like_count,
						:category_id,
						:visible,
						:score,
						:percent_rank,
						:slug,
						:excerpt,
						:fancy_title
					)

					topic['rating'] = rating
					topic['vote_count'] = count
					topic['category_name'] = cat_name

					result[topic_id]['topic'] = topic
					result[topic_id]['comments'] = []
					result[topic_id]['comments'].append(topic)
				end
			end
		end

		for post in posts do
			topic = post.topic
			if topic != nil
				
				tags = tags + topic.tags
			
				topic_id = topic.id

				tags = PostTag.includes(:tag).where(post_id: post.id)
				tags = tags.map {|post_tag| post_tag.tag}

				tags = tags.select {|tag| tag != nil}
				tag_names = tags.map {|tag| tag.name}

				if tag_names.include? tag_name
					if result[topic_id] == nil
						post_ids = Post.where(topic_id: topic_id).pluck(:id)
						rating = StemPostRating.where(post_id: post_ids).average(:average_value)
						count = StemPostRating.where(post_id: post_ids).count()
						cat_name = topic.category.name

						topic = topic.slice(
							:id,
							:title,
							:last_posted_at,
							:created_at,
							:updated_at,
							:views,
							:posts_count,
							:user_id,
							:last_post_user_id,
							:reply_count,
							:deleted_at,
							:image_url,
							:like_count,
							:category_id,
							:visible,
							:score,
							:percent_rank,
							:slug,
							:excerpt,
							:fancy_title
						)

						topic['rating'] = rating
						topic['vote_count'] = count
						topic['category_name'] = cat_name

						result[topic_id] = {}
						result[topic_id]['topic'] = topic
						result[topic_id]['comments'] = []
					end

					post_id = post.id
					data = {}
					post = post.slice(
						:id,
						:user_id,
						:topic_id,
						:post_number,
						:created_at,
						:updated_at,
						:reply_to_post_number,
						:reply_count,
						:deleted_at,
						:like_count,
						:score,
						:reads,
						:post_type,
						:last_version_at,
						:like_score,
						:word_count,
						:image_url
					)
					post['rating'] = StemPostRating.where(:post_id => post_id)
											.average(:average_value)
					post['vote_count'] = StemPostRating.where(:post_id => post_id)
								.count()
					data['post'] = post
					result[topic_id]['comments'].append(data)
				end
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
