
class ::StemcategoryController < ::ApplicationController

	def index

		categories = Category.all
		
		draw = params[:draw].to_i
		start = params[:start].to_i
		length = params[:length].to_i
		search = params[:search][:value]

		categories = StemRatingSystemCategory.includes(
						:category, :stem_rating_system)
					.offset(start).limit(length)
		totalCount = StemRatingSystemCategory.count
		count = nil
		if(search and search != "")
			discourse_categories = Category.where("name ILIKE ?", "%#{search}%").pluck("id")
			categories = categories.where("category_id IN (?)", discourse_categories)
			count = StemRatingSystemCategory.where("category_id IN (?)", discourse_categories).count
		end

		if (!count)
			count = totalCount
		end

		def select(systems, category)
			selected = category.stem_rating_system
			ret = "<select onchange='stemOnChange(event)' id=#{category.id}>"
			for s in systems
				ret = ret + "<option value='#{s.id}' #{s.id==selected.id ? 'selected' : ''}>#{s.name}</option>"
			end
			ret = ret + "</select>"
			return ret
		end

		systems = StemRatingSystem.all

		data = []
		i = 0
		for c in categories do
			data[i] = []
			data[i][0] = c.category.name
			data[i][1] = select(systems, c)
			i = i + 1
		end

		respond_to do |format|
			msg = { 
				:draw => draw,
				:recordsTotal => totalCount,
				:recordsFiltered => count,
				:data => data
			}
			format.json { render :json => msg }
		end
	end

	def update
		category_id = params[:category_id]
		stem_rating_system_id = params[:stem_rating_system_id]

		srsc = StemRatingSystemCategory.where(
					:category_id => category_id,
					# :stem_rating_system_id => stem_rating_system_id
				)
				.first()
		srsc.stem_rating_system_id = stem_rating_system_id
		srsc.save()

		respond_to do |format|
			msg = { 
				:stem_category => srsc
			}
			format.json { render :json => msg }
		end
	end

end
