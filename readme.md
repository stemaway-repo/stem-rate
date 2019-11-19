# app

##	models
###		stem_criteria
criteria name and weight definition for a rating system
###		stem_post
as Discourse does not link tags to posts, but to topics and, it is a requirement within our platform, this model shadows the Discourse post model and allows us to link tags to it (we cannot interfere with Discourse models from a plugin); a method that extracts hashtag tags from text is implemented here
###		stem_post_criteria_rating
the actual rating value for a given criteria for a given post is stored within this model
###		stem_post_rating
post rating container object; connects stem_post_criteria_rating objects with a stem_post (and a Discourse post through transitivity)
###		stem_post_rating_system
name definition and container object for a rating system; connects stem criteria to this system
###		stem_post_tag
this model links a Discourse post to a Discourse tag object (so that posts can have tags as well as topics)
###		stem_rating_system
rating system  name definition and container object
###		stem_rating_system_category
each rating system is connected to one category through this model
			
##	controllers
###		stem_activity_controller
implements methods related to CV integration
####				create_tag
allows the creation of a tag
####				posts_by_tag
returns a list of topics and posts for a given tag 
###		stem_admin_rating_controller
implements methods related to rating posts
####				average
returns the average value by criteria for a given post
####				get
returns the rating details (values by criteria) for a given user-post combination
####				rate
allows a user to rate a post by giving values for each criteria (and generating a like in the process)
####				retract
removes a user's rating for a given post (and the connected like)
###		stem_category_controller
**[deprecated]** implements methods related to managing category rating systems
###		stem_rating_controller
implements methods related to managing rating systems 
####				index
returns a list of rating system and their definitions
####				get
get the details of a given rating system (criteria and weights)
####				update
allows the update of a rating system (changing criteria and/or weights)
####				reset
resets the rating system for one category to 'Default Rating System'
# assets
	
##	javascripts
###		discourse
####			initializers
#####				stem-rate-init.js.es6
handles rating plugin initialization (post buttons, rating modal interface)
#####			templates/admin
######				plugins-stem.hbs
handles rating system admin view and functionality
######				plugins-stemcat.hbs
[deprecated] allowed changing the category one rating system applies to
#####			stem-rating-route-map.js.es6
defines plugin admin routes
######		jquery.*.js
jQuery and jQuery datatables, required for rating system admin interface
######		simple.rating.js
script that handles star rating display animations
	
##	stylesheets
###		stem.modal.css
required for inner rating modal display
###		simple.rating.css
simple rating stylesheet, required for star rating interface
###		jquery.modal.min.css
jQuery modal stylesheets, required for voting modal
###		jquery.dataTables.min.css
jQuery datatable stylesheets, required for rating system admin interface
###		fontawesome.*.css
Font Awesome stylesheets, required for thumbs up and stars icons
	
##	webfonts
webfonts required for Font Awesome (thumbs up, stars icons)
		
# config
##	locales
###		client.en.yml
clientside display string definitions
###		server.en.yml
serverside (admin) display string definitions
##	settings.yml
default plugin setting names and values
		
# db
##	migrate
###		create_post_tags
migration to create post_tags table for post_tag model
###		create_stem_rating_system
migration to create all tables related to rating systems (stem_rating_systems, stem_rating_system_category, stem_criteria, stem_post_ratings, stem_post_criteria_rating)
###		create_default_stem_rating_system
seeder for criteria and weights for 'Default Rating System' and correlation to all existing categories at this time
			
# plugin.rb
plugin entrypoint (first script run), does the following:
- enable plugin site settings in admin interface
- register assets (javascript, stylesheets and fonts)
- add plugin relevant routes and restrictions to Discourse api
- set Discourse admin settings to appropriate values (commented out)
 - load plugin model files
 - load plugin controller files
 - add controller methods to their respective paths (with restrictions)
- add category and post creation hooks with plugin relevant preprocessing
		
# readme.md
this readme file