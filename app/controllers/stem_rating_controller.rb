
class ::StemratingController < ::ApplicationController

	def average
		post_id = params[:post_id]
		average = StemPostRating.where(:post_id => post_id)
			.average(:average_value)
		count = StemPostRating.where(:post_id => post_id).count()
		if count == 0
			average = 0
		end

		rating_by_criteria = {}
		if (average != 0)
			rating = StemPostRating.where(:post_id => post_id).first
			category_id = Post.find(rating.post_id).topic.category.id
			rating_system_id = StemRatingSystemCategory.where(
				category_id: category_id).first.stem_rating_system_id
			criteria = StemCriterium.where(
				stem_rating_system_id: rating_system_id).all
			criteria.each do |criterium|
				criteria_average = StemPostCriteriaRating.where(
					stem_user_post_rating_id: rating.id, stem_criteria_id: criterium.id
				).average(:value)
				criteria_average = criteria_average.round(2)
			end
		end

		already_rated = false
		if current_user
			rated = StemPostRating.where(:post_id => post_id, :user_id => current_user.id).first()
			already_rated = rated ? true : false
		end


		average = average.round(2)
		respond_to do |format|
			msg = { 
				:post_id => post_id,
				:average => average,
				:count => count,
				:rating_by_criteria => rating_by_criteria,
				:already_rated => already_rated
			}
			format.json { render :json => msg }
		end
	end

	def get
		user = current_user
		post_id = params[:post_id]
		already_rated = false

		post = Post.find(post_id)
		category_id = post.topic.category.id

		srs = StemRatingSystemCategory.where(
			:category_id => category_id).first()
		if !srs
			d = StemRatingSystem.where(
				:name => "Default Rating System").first()
			srs = StemRatingSystemCategory.create(
				:category_id => category_id, 
				:stem_rating_system_id => d.id)
		end
		srs = srs.stem_rating_system
		criteria = srs.stem_criteria

		rating = StemPostRating.includes(:stem_post_criteria_rating)
					.where(:user_id => user.id, :post_id => post_id)
					.first()

		data = {}
		for criterium in criteria
			data[criterium.id] = {
				:name => criterium.name, 
				:id => criterium.id,
				:value => 0
			}
		end

		if rating
			ratings = StemPostCriteriaRating.where(:stem_user_post_rating_id => rating.id)
			for r in ratings
				if (data[r.stem_criteria_id])
					data[r.stem_criteria_id][:value] = r.value
					already_rated = true
				else
					r.destroy()
				end
			end
		end

		respond_to do |format|
			msg = { 
				:rating => data,
				:already_rated => already_rated
			}
			format.json { render :json => msg }
		end
	end

	def rate
		user = current_user
		post_id = params[:post_id]

		rating = StemPostRating.where(:user_id => user.id, :post_id => post_id).first()
		if !rating
			rating = StemPostRating.create(
				:user_id => user.id,
				:post_id => post_id,
				:average_value => 0
			)
		end

		StemPostCriteriaRating.where(:stem_user_post_rating_id => rating.id).destroy_all()

		criteria_ids = params[:criteria_ids]
		criteria_values = params[:criteria_values]

		ln = criteria_ids.length
		total_value = 0
		total_weight = 0
		ln.times do |i|
			criteria_id = criteria_ids[i]
			criteria_value = criteria_values[i].to_i

			criteria = StemCriterium.find(criteria_id)
			weight = criteria.weight

			StemPostCriteriaRating.create(
				:stem_user_post_rating_id => rating.id,
				:stem_criteria_id => criteria_id,
				:value => criteria_value
			)

			total_value = total_value + criteria_value * weight
			total_weight = total_weight + weight
		end

		if total_weight == 0
			total_weight = 1
		end
		average_value = total_value / total_weight
		rating.average_value = average_value
		rating.save()

		rating = StemPostRating.includes(:stem_post_criteria_rating).find(rating.id)

		respond_to do |format|
			msg = { 
				:rating => rating,
				:criteria => rating.stem_post_criteria_rating
			}
			format.json { render :json => msg }
		end
	end

	def retract
		user = current_user
		post_id = params[:post_id]

		rating = StemPostRating.where(
			:user_id => user.id, :post_id => post_id).first()
		if rating
			# todo: subtract average and decrement count
			StemPostCriteriaRating.where(
				:stem_user_post_rating_id => rating.id).destroy_all()
			rating.destroy()
		end

		respond_to do |format|
			msg = { 
				:status => "retracted"
			}
			format.json { render :json => msg }
		end
	end

end
