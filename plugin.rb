# name: STEM User Posts by Tag
# about: Adds an endpoint to return a JSON of user activity grouped by tag
# version: 0.0.4
# author: wally
# url: null

# todo: https://docs.discourse.org/#tag/Users%2Fpaths%2F~1user_actions.json%2Fget

enabled_site_setting :post_snippet_max_length

# gem 'ajax-datatables-rails'
# gem 'jquery-datatables'

register_asset "javascripts/jquery.dataTables.min.js"
register_asset "javascripts/simple.rating.js"
register_asset "stylesheets/jquery.dataTables.min.css"
register_asset "stylesheets/stem.modal.css"
register_asset "stylesheets/simple.rating.css"

# register_asset "javascripts/jquery.modal.min.js"
# register_asset "stylesheets/jquery.modal.min.css"

add_admin_route 'stem_rating.title', 'stem'
# add_admin_route 'stem_category.title', 'stemcat'

Discourse::Application.routes.append do
  get '/admin/plugins/stem' => 'admin/plugins#index', constraints: StaffConstraint.new
  get '/admin/plugins/stemcat' => 'admin/plugins#index', constraints: StaffConstraint.new
end


after_initialize do

	#SiteSetting.tagging_enabled = true
	#SiteSetting.min_trust_to_create_tag = 0
	#SiteSetting.discourse_math_enabled = true
	#SiteSetting.discourse_math_provider = "katex"
	#SiteSetting.username_change_period = 0
	#SiteSetting.default_trust_level = 1
	#SiteSetting.logo = nil
	#SiteSetting.logo_small = nil
	#SiteSetting.post_menu = "share|flag|edit|bookmark|delete|admin|reply"
	#SiteSetting.min_first_post_typing_time = 10
	#SiteSetting.title = "STEM Away"
	#SiteSetting.min_trust_to_create_tag = 0
	#SiteSetting.max_topics_in_first_day = 100
	#SiteSetting.max_topics_per_day = 100
	#SiteSetting.newuser_spam_host_threshold = 100
	#SiteSetting.newuser_max_attachments = 100
	#SiteSetting.newuser_max_images = 100
	#SiteSetting.newuser_max_links = 100
	#SiteSetting.newuser_max_mentions_per_post = 100
	#SiteSetting.newuser_max_replies_per_topic = 100
	#SiteSetting.max_consecutive_replies = 100
	#SiteSetting.rate_limit_create_topic = 5
	#SiteSetting.rate_limit_create_post = 5
	#SiteSetting.rate_limit_new_user_create_topic = 5
	#SiteSetting.rate_limit_new_user_create_post = 5
	#SiteSetting.content_security_policy = 0
	#SiteSetting.min_trust_to_send_messages = 0

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
		
		get "stem/users/:username/:tag" => "stemactivity#posts_by_tag"

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
		s = StemRatingSystem.where(:name => "Default Rating System").first()
		StemRatingSystemCategory.create(
			:stem_rating_system_id => s.id,
			:category_id => c.id
		)
	end

	DiscourseEvent.on(:post_created) do |post|
		StemPost.extract_tags(post)
	end

	DiscourseEvent.on(:post_edited) do |post|
		StemPost.extract_tags(post)
	end

end
