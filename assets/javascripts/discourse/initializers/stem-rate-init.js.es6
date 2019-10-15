
import { withPluginApi } from 'discourse/lib/plugin-api'
import TopicRoute from 'discourse/routes/topic'

var modalId = "stem-modal-id";
$('body').append('<center>\
	<div id="'+ modalId +'" class="stem-modal">\
	  <div class="stem-modal-content">\
	  	<span id="stem-modal-close" class="stem-modal-close">&times;</span>\
	  	<div id="stem-vote">\
		  	<div class="stem-modal-title">Rate the post</div>\
		  	<div class="stem-modal-description">Select number of stars. You may award stars for one or more attributes.</div>\
	  	</div>\
	  	<div id="stem-revote" style="display: none;">\
		  	<div class="stem-modal-title">Re-rate the post</div>\
		  	<div class="stem-modal-description">Re-select the number of stars for each attribute. Or unvote.</div>\
		</div>\
	    <form id="stem-rate-form" action="">\
	    	<input type="hidden" name="post_id" value="" id="stem-rate-post-id"/>\
	    	<div id="stem-rate-fields" class="stem-modal-rating-container">\
	    	</div>\
	    	<input type="button" value="CANCEL" id="button-cancel" class="stem-button stem-button-gray">\
	    	<input type="submit" value="SUBMIT" class="stem-button stem-button-blue">\
	    	<input type="button" value="UNVOTE" id="button-retract" class="stem-button stem-button-red" style="display: block;">\
	    </form>\
	  </div>\
	</div>\
</center>');

var modal = $("#" + modalId)[0];
function stemCloseModal(){
	modal.style.display = "none";
}
$("#stem-modal-close").on('click', function(){
	stemCloseModal();
});

var form = $("#stem-rate-form");
form.on('submit', function(event){
	event.preventDefault();

	var data = $("#stem-rate-form").serialize();
	$.ajax(
		document.location.origin + "/stem/rating/rate.json",
		{
			data: data,
			success: function (data){
				stemCloseModal();
				location.reload();
			}
		}
	);
});

$("#button-cancel").on('click', function(){
	stemCloseModal();
});

$("#button-retract").on('click', function(){
	$.ajax(
		document.location.origin + "/stem/rating/retract.json",
		{
			data: {
				post_id: $("#stem-rate-post-id").val()
			},
			success: function(data){
				stemCloseModal();
				location.reload();
			}
		}
	);
});

function initializePlugin(api) {

	var alreadyDecorated = false;

	api.decorateWidget('post-contents:after-cooked', helper => {
		let post = helper.getModel();
		let result = [];
		$.ajax(
			document.location.origin + "/stem/rating/average.json",
			{
				data: {
					post_id: post.id
				},
				success: function(data){
					result = data;

					var thumb_id = "thumbs-up-" + post.id;
					var count_id = "count-" + post.id;

					$("#" + thumb_id).remove()
					$("#" + count_id).remove()

					var id = "#post_" + post.post_number;
					// rating button should alwaysbe first
					var rate_id = id + " nav .actions button";
					var rate = $(rate_id)[0];
					rate.innerHTML = "";

					var thumb = document.createElement("i");
					thumb.className = "fa fa-thumbs-up";
					thumb.style.display = "inline";
					if (data.already_rated)
						thumb.style.color = "#f5ba00";
					thumb.id = thumb_id;
					thumb.onclick = function(){
						var el = event.target.closest("article");
						var postId = $(el).attr("data-post-id");
						
						$.ajax(
							document.location.origin + "/stem/rating/get.json",
							{
								data: {
									post_id: postId
								},
								success: function(data){
									$("#stem-rate-post-id").val(postId);
									var rating = data.rating;
									var container = $("#stem-rate-fields")[0];
									container.innerHTML = "";
									for (var i in rating){
										var r = rating[i];

										var intermediate = document.createElement("div");
										intermediate.className = "stem-modal-intermediate-container";

										var label;
										label = document.createElement("div");
										label.innerHTML = r.name;
										label.className = "stem-modal-rating-left";
										intermediate.append(label);
										
										var hidden;
										hidden = document.createElement("input");
										hidden.type = "hidden";
										hidden.name = "criteria_ids[]";
										hidden.value = r.id;
										intermediate.append(hidden);
										
										var stars;
										stars = document.createElement("div");
										document.className = "stem-modal-rating-right";

										var input;
										input = document.createElement("input")
										input.type = "number";
										input.className = "rating";
										input.name = "criteria_values[]";
										input.value = r.value;
										stars.append(input);
										intermediate.append(stars);

										container.append(intermediate);
									}

									$('.rating').rating();

									if (data.already_rated){
										$("#stem-vote")[0].style.display = "none";
										$("#stem-revote")[0].style.display = "block";
										$("#button-retract")[0].style.display = "inline";
									} else {
										$("#stem-vote")[0].style.display = "block";
										$("#stem-revote")[0].style.display = "none";
										$("#button-retract")[0].style.display = "none";
									}

									modal.style.display = "block";
								}
							}
						);
					}
					rate.append(thumb);

					var count = document.createElement("button");
					count.style.display = "inline";
					count.style.className = "widget-button btn-flat";
					count.append("(" + data.count + ")");
					count.id = count_id;
					rate.parentNode.prepend(count);

					count.onclick = function(){
						var selector = "#rating-by-criteria-" + post.id;
						var results = $(selector);
						if (results[0]) {
							$(selector).remove();
						}
						else {
							$.ajax(
								document.location.origin + "/stem/rating/average.json",
								{
									data: {
										post_id: post.id
									},
									success: function(data){
										var ratings = data.rating_by_criteria;

										if (data.average > 0){

											var div = document.createElement("div");
											div.id = "rating-by-criteria-" + post.id;

											var title = document.createElement("div");
											title.innerHTML = "Reasons for upvote";
											title.style = "font-size: 20px; font-weight: bold; padding: 10px;";
											div.append(title);

											for (var key in ratings){
												var value = ratings[key];
												var rating_div = document.createElement("div");
												rating_div.style = "font-size: 16px; padding: 5px;";
												rating_div.append(value + " ");
												var i = document.createElement("i");
												i.className = "fa fa-star";
												rating_div.append(i);
												rating_div.append(" " + key);
												div.append(rating_div);
											}

											var id = "#post_" + post.post_number;
											var nav_id = id + " .post-menu-area";
											var nav = $(nav_id)[0];
											nav.append(div);
										}
									}
								}
							)
						}
					};
				}
			}
		);
		return "";
	})

	api.addPostMenuButton('stem-rate', attrs => {
	    return {
	      action: 'clickStemRate',
	      icon: 'far-thumbs-up',
	      title: 'stem_rating.rate_title',
	      position: 'first',
	    }
	})

	api.attachWidgetAction('post-menu', 'clickStemRate', function() {
		var el = event.target.closest("article");
		var postId = $(el).attr("data-post-id");
		
		$.ajax(
			document.location.origin + "/stem/rating/get.json",
			{
				data: {
					post_id: postId
				},
				success: function(data){
					$("#stem-rate-post-id").val(postId);
					var rating = data.rating;
					var container = $("#stem-rate-fields")[0];
					container.innerHTML = "";
					for (var i in rating){
						var r = rating[i];

						var intermediate = document.createElement("div");
						intermediate.className = "stem-modal-intermediate-container";

						var label;
						label = document.createElement("div");
						label.innerHTML = r.name;
						label.className = "stem-modal-rating-left";
						intermediate.append(label);
						
						var hidden;
						hidden = document.createElement("input");
						hidden.type = "hidden";
						hidden.name = "criteria_ids[]";
						hidden.value = r.id;
						intermediate.append(hidden);
						
						var stars;
						stars = document.createElement("div");
						document.className = "stem-modal-rating-right";

						var input;
						input = document.createElement("input")
						input.type = "number";
						input.className = "rating";
						input.name = "criteria_values[]";
						input.value = r.value;
						stars.append(input);
						intermediate.append(stars);

						container.append(intermediate);
					}

					$('.rating').rating();

					if (data.already_rated){
						$("#stem-vote")[0].style.display = "none";
						$("#stem-revote")[0].style.display = "block";
						$("#button-retract")[0].style.display = "inline";
					} else {
						$("#stem-vote")[0].style.display = "block";
						$("#stem-revote")[0].style.display = "none";
						$("#button-retract")[0].style.display = "none";
					}

					modal.style.display = "block";
				}
			}
		);
	})

}


export default {
  name: 'stem-rate-button',
  initialize: function() {
    withPluginApi('0.8.6', api => initializePlugin(api))
  }
}
