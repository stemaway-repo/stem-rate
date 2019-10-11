
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
		  	<div class="stem-modal-description">Re-select the number of starsfor each attribute. Or unvote.</div>\
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
				// todo:
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

					// var id = "#post_" + post.post_number;
					// // rating button should alwaysbe first
					// var rate_id = id + " nav .actions button";
					// var rate = $(rate_id)[0];
					// rate.innerHTML = "";

					// var stars = document.createElement("div");
					// stars.className = "simple-rating star-rating";
					// stars.style.display = "inline";

					// for (var i=1; i<=5; i++){
					// 	var list_item = document.createElement("i");
					// 	if (i<=data.average){
					// 		list_item.className = "fa fa-star";
					// 	} else {
					// 		list_item.className = "fa fa-star-o";
					// 	}
					// 	if (data.already_rated)
					// 		list_item.style.color = "#f5ba00";
					// 	stars.append(list_item);
					// }
					
					// rate.append(data.average);
					// rate.append(stars);
					// rate.append("(" + data.count + ")");



					var id = "#post_" + post.post_number;
					// rating button should alwaysbe first
					var rate_id = id + " nav .actions button";
					var rate = $(rate_id)[0];
					rate.innerHTML = "";

					var star = document.createElement("i");
					star.className = "fa fa-star";
					star.style.display = "inline";
					if (data.already_rated)
						star.style.color = "#f5ba00";
					rate.append(star);

					var count = document.createElement("button");
					count.style.display = "inline";
					count.style.className = "widget-button btn-flat";
					count.append("(" + data.count + ")")
					rate.parentNode.prepend(count);

					count.onclick = function(){
						$.ajax(
							document.location.origin + "/stem/rating/average.json",
							{
								data: {
									post_id: post.post_number
								},
								success: function(data){
									// todo: display data
									console.log(data);
								}
							}
						)
					};
				}
			}
		);
		return "";
	})

	api.addPostMenuButton('stem-rate', attrs => {
	    return {
	      action: 'clickStemRate',
	      icon: 'far-smile',
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