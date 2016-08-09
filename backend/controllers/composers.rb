class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/plugins/composers/summary')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_id", String])
    .permissions([])
    .returns([200, "[(:digital_object)]"]) \
  do
    json_response(Composers.summary(params[:resource_id]))
  end


  Endpoint.get('/plugins/composers/detailed')
         .description("Get detailed Digital Object data for a specific Resource")
         .params(["component_id", String])
         .permissions([])
         .returns([200, "[(:digital_object)]"]) \
  do
    json_response(Composers.detailed(params[:component_id]))
  end

end
