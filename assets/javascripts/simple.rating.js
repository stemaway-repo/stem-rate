
function setstars(obj, rating){

  var stars = $(obj).next().children();
  for (var i=0; i<5; i++){
    var starObj = $(obj).next().children()[i];
    if (i < rating){
      $(starObj).removeClass('fa-star-o');
      $(starObj).addClass('fa-star');
    } else {
      $(starObj).removeClass('fa-star');
      $(starObj).addClass('fa-star-o');
    }
  }

}

jQuery.fn.extend({

  rating: function(options){

    if(typeof(options)=='undefined') options={};

    var objs = this;
    if (objs.length){
      for (var i=0; i<objs.length; i++){

        var obj = objs[i];

        var html='<div class="simple-rating star-rating">';
        for(var j=0; j<5; j++)
            html+='<i class="fa fa-star-o" data-rating="'+(j+1)+'"></i>';
        html+='</div>';

        $(obj).attr('type', 'hidden').after(html);

        $(obj).next().children().on('click', function(e){
          // todo: rate
          var rating = $(this).data('rating');
          $($(this).parent().prev()).val(rating); // set rating in input field
          setstars($(this).parent().prev(), rating);
        });

        $(obj).next().children().on('mouseenter', function(e){
          var rating = $(this).data('rating');
          setstars($(this).parent().prev(), rating);
        });

        $(obj).next().children().on('mouseleave', function(e){
          var rating = $(this).data('rating');
          setstars($(this).parent().prev(), rating);
        });

        setstars(obj, $(obj).val());
      }
    }

  },

});