class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/plugins/composers/summary')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_id", String])
    .permissions([])
    .returns([200, "[(:digital_object)]"],
             [400, :error]) \
  do
    resp = Composers.summary(params[:resource_id])
    if resp.empty?
      json_response({:error => "Resource not found for identifier: #{params[:resource_id]}"}, 400)
    else
      json_response(resp)
    end
  end


  Endpoint.get('/plugins/composers/detailed')
         .description("Get detailed Digital Object data for a specific Resource")
         .params(["component_id", String])
         .permissions([])
    .returns([200, "[(:digital_object)]"],
             [400, :error]) \
  do
    resp = Composers.detailed(params[:component_id])
    if resp.empty?
      json_response({:error => "Object not found for component id: #{params[:component_id]}"}, 400)
    else
      json_response(resp)
    end
  end

end
