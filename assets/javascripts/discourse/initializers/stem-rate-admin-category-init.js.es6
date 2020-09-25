import { withPluginApi } from 'discourse/lib/plugin-api'

export default {
  name: 'stem-rate-admin-category-init',
  initialize: function(container) {
    withPluginApi('0.8.6', api => {
    	$(document).ready(function () {
        function stemError(jqXHR, textStatus, errorThrown){
          // todo: error reporting modal?
          console.log("datatable request error");
          console.log(jqXHR, textStatus, errorThrown);
        }

        function stemOnChange(e){
          var select = e.target;
          $.ajax(
            "stemcat/update.json",
            {
              data: {
                category_id: select.id,
                stem_rating_system_id:
                  select.options[select.selectedIndex].value
              },
              success: function(data){
                console.log(data);
              },
              error: stemError
            }
          );
        }

        const datatable = $('#category-datatable').DataTable({
          "processing": true,
          "serverSide": true,
          "ajax": {
            url: "stemcat/list.json",
            type: "get",
            error: stemError
          }
        });
    	});
    })
  }
}
