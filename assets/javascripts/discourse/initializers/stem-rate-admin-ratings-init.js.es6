import { withPluginApi } from 'discourse/lib/plugin-api'

export default {
  name: 'stem-rate-admin-ratings-init',
  initialize: function(container) {
    withPluginApi('0.8.6', api => {
      $(document).ready(() => {
        var datatable

        function stemError(jqXHR, textStatus, errorThrown){
          // todo: error reporting modal?
          console.log("datatable request error");
          console.log(jqXHR, textStatus, errorThrown);
        }

        function stemDisplayTable(e){
          $("#edit-container")[0].style = "display:none;";
          $("#datatable-container")[0].style = "display:true;";
          datatable.ajax.reload();
        }

        function stemDisplayEdit(e){
          $("#datatable-container")[0].style = "display:none;";
          $("#edit-container")[0].style = "display:true;";
        }

        function addCriterium(name, weight){
          var container = $("#criteria-container");
          var div = document.createElement("div");
          var input = document.createElement("input");
          input.type = "text";
          input.placeholder = "Attribute name"
          input.value = name;
          input.name = "criteria_names[]";
          div.append(input);
          var input2 = document.createElement("input");
          input2.type = "number";
          input2.placeholder = "Attribute weight";
          input2.value = weight;
          input2.name = "criteria_weights[]";
          div.append(input2);
          var a = document.createElement("a");
          a.href = "#";
          a.innerHTML = "Remove";
          a.onclick = function(event){
            this.closest('div').remove();
          }
          div.append(a);
          container.append(div);
        }

        function stemEdit(id){
          $.ajax(
            "stem/get.json",
            {
              data: {
                category_id: id
              },
              success: function(data){

                var category = data.category;
                $("#category-name")[0].innerHTML = category.name;
                $("#category-id")[0].value = category.id;

                $("#criteria-container")[0].innerHTML = "";
                var criteria = data.criteria;
                for (var index in criteria){
                  var c = criteria[index];
                  addCriterium(c.name, c.weight);
                }

                stemDisplayEdit();
              },
              error: stemError
            }
          );
        }

        function stemUpdate(e){
          e.preventDefault();
          const data = $("#update").serialize();
          $.ajax(
            "stem/update.json",
            {
              data: data,
              success: function(data){
                stemDisplayTable();
              },
              error: stemError
            }
          );
        }

        function stemReset(id){
          $.ajax(
            "stem/reset.json",
            {
              data: {
                category_id: id
              },
              success:function(data) {
                stemDisplayTable();
              },
              error: stemError
            }
          );
        }

        setTimeout(function() {
          datatable = $('#ratings-datatable').DataTable({
            "processing": true,
            "serverSide": true,
            "ajax": {
              url: "stem/list.json",
              type: "get",
              error: stemError
            }
          });

          $("#add-criterium").on('click', function(e){
            addCriterium("", "");
          });

          $('#ratings-datatable').on('click', '.stem-edit', function(e) {
            stemEdit(parseInt(e.currentTarget.dataset.id))
          })

          $('#ratings-datatable').on('click', '.stem-reset', function(e) {
            stemReset(parseInt(e.currentTarget.dataset.id))
          })
          $("#update").on('submit', stemUpdate);
          $("#cancel-button").on('click', stemDisplayTable);
          $("#reset-button").on('click', function(e){
            var category_id = $("#category-id").val();
            stemReset(category_id);
          });
          $("#stem-edit-default-button").on('click', function(e){
            stemEdit(0);
          });
        }, 1000)
      })
    })
  }
}
