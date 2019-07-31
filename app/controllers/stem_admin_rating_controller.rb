
class ::StemratingadminController < ::ApplicationController

	def index

		draw = params[:draw].to_i
		start = params[:start].to_i
		length = params[:length].to_i
		search = params[:search][:value]

		# correct any issues
		category_ids = StemRatingSystemCategory.pluck(:category_id)
		category_ids = Category.where.not(id: category_ids).pluck(:id)

		if category_ids.length != 0 then
			default_id = StemRatingSystem.where(
				:name => "Default Rating System").first().id
			category_ids.each do |category_id|
				StemRatingSystemCategory.create(
					:stem_rating_system_id => default_id,
					:category_id => category_id
				)
			end
		end

		systems = StemRatingSystemCategory.joins(:category)
							.joins(:stem_rating_system)
							.order("categories.name asc")
		totalCount = StemRatingSystemCategory.count()
		count = nil
		if (search and search != "")
			systems = systems.where("categories.name ILIKE ?", "%#{search}%")
			count = systems.where("categories.name ILIKE ?", "%#{search}%").count 
		end

		if (!count)
			count = totalCount
		end

		data = []
		i = 0
		for s in systems do
			data[i] = []
			data[i][0] = s.category.name
			data[i][1] = s.stem_rating_system.to_s
			data[i][2] = "<a href='#' onclick='stemEdit(#{s.category.id.to_s});'>Edit</a>"
			data[i][3] ="<a href='#' onclick='stemReset(#{s.category.id.to_s});'>Reset</a>"
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
		category_id = params[:category_id].to_i

		srs = nil
		default = StemRatingSystem.where(:name => "Default Rating System").first()

		if (category_id != 0)
			cat = StemRatingSystemCategory.where(:category_id => category_id).first()
			srs = cat.stem_rating_system

			if (srs.id == default.id)
				srs = StemRatingSystem.create()
				cat.stem_rating_system_id = srs.id
				cat.save()
			end
		else
			srs = default
		end
		
		srs.stem_criteria.destroy_all()

		criteria_names = params[:criteria_names]
		criteria_weights = params[:criteria_weights]

		ln = criteria_names.length
		ln.times do |i|
			name = criteria_names[i]
			weight = criteria_weights[i]
			if name and name != ""
				if !weight or weight == ""
					weight = 0
				end
				StemCriterium.create(
					:stem_rating_system_id => srs.id,
					:name => name,
					:weight => weight
				)
			end
		end

		srs = StemRatingSystem.includes(:stem_criteria).find(srs.id)

		respond_to do |format|
			msg = { 
				:system => srs,
				:criteria => srs.stem_criteria
			}
			format.json { render :json => msg }
		end
	end

	def get
		category_id = params[:category_id].to_i
		srs = nil
		category = nil
		if (category_id != 0)
			s = StemRatingSystemCategory.joins(:category)
							.joins(:stem_rating_system)
							.where(:category_id => category_id)
							.first()
			category = s.category
			srs = s.stem_rating_system
			if (srs.name == "Default Rating System")
				srs = StemRatingSystem.new
			end
		else
			srs = StemRatingSystem.where(:name => "Default Rating System").first
			category = Category.new
			category.id = 0
			category.name = "Default"
		end
		respond_to do |format|
			msg = {
				:system => srs,
				:criteria => srs.stem_criteria,
				:category => category
			}
			format.json { render :json => msg }
		end
	end

	def reset
		category_id = params[:category_id]
		s = StemRatingSystem.where(:name => "Default Rating System").first()
		c = StemRatingSystemCategory.where(:category_id => category_id).first()
		c.stem_rating_system_id = s.id
		c.save()
		respond_to do |format|
			msg = {
				:message => "reset"
			}
			format.json { render :json => msg }
		end
	end

end
