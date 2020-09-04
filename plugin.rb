# name: STEM User Posts by Tag
# about: Adds an endpoint to return a JSON of user activity grouped by tag
# version: 0.0.4
# author: wally
# url: null

enabled_site_setting :post_snippet_max_length

register_asset "javascripts/jquery.dataTables.min.js"
register_asset "stylesheets/jquery.dataTables.min.css"
register_asset "stylesheets/stem-rate.scss"

add_admin_route 'stem_rating.title', 'stem'

Discourse::Application.routes.append do
  get '/admin/plugins/stem' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/stemcat' => 'admin/plugins#index', constraints: StaffConstraint.new
end


after_initialize do
	require_dependency 'application_controller'

	[
		# models
		'../app/models/stem_post.rb',
		'../app/models/stem_post_tag.rb',
		'../app/models/stem_criteria.rb',
		'../app/models/stem_rating_system.rb',
		'../app/models/stem_post_rating.rb',
		'../app/models/stem_post_criteria_rating.rb',
		'../app/models/stem_rating_system_category.rb',

		# controllers
		'../app/controllers/stem_rating_controller.rb',
    '../app/controllers/stem_admin_rating_controller.rb',
    '../app/controllers/stem_activity_controller.rb',
    '../app/controllers/stem_category_controller.rb',

	].each { |path| load File.expand_path(path, __FILE__) }

	Discourse::Application.routes.append do

		get "stem/users/:username/:tag" => "stemactivity#posts_by_tag", constraints: AdminConstraint.new(require_master: true)
		get "stem/tag/create/:tag" => "stemactivity#create_tag", constraints: AdminConstraint.new(require_master: true)

		get "stem/rating/get" => "stemrating#get"
		get "stem/rating/rate" => "stemrating#rate"
		get "stem/rating/retract" => "stemrating#retract"
		get "stem/rating/average" => "stemrating#average"

		get "admin/plugins/stem/list" => "stemratingadmin#index", constraints: StaffConstraint.new
		get "admin/plugins/stem/get" => "stemratingadmin#get", constraints: StaffConstraint.new
		get "admin/plugins/stem/update" => "stemratingadmin#update", constraints: StaffConstraint.new
		get "admin/plugins/stem/reset" => "stemratingadmin#reset", constraints: StaffConstraint.new

		get "admin/plugins/stemcat/list" => "stemcategory#index", constraints: StaffConstraint.new
		get "admin/plugins/stemcat/update" => 'stemcategory#update', constraints: StaffConstraint.new
	end

	DiscourseEvent.on(:category_created) do |c|
		StemRatingSystemCategory.create(
      stem_rating_system: StemRatingSystem.find_by(name: "Default Rating System"),
      category: c
		)
	end

	DiscourseEvent.on(:post_created) { |post| StemPost.extract_tags(post) }
	DiscourseEvent.on(:post_edited)  { |post| StemPost.extract_tags(post) }
end
