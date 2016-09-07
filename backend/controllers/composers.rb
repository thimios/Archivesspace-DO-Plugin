require_relative File.join(ASUtils.find_base_directory, 'common', 'mixed_content_parser')


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
         .description("Get detailed data for a specific digital object record")
         .params(["component_id", String, "Component id for the record"],
                 ["format", String, "Format of the data returned - json(default), html", :optional => true])
         .permissions([])
    .returns([200, "[(:digital_object)]"],
             [400, :error]) \
  do
    format = params.fetch(:format) { 'json' }

    unless ['json', 'html'].include?(format)
      json_response({:error => "Unrecognized format: #{format}. Must be 'json' or 'html'"}, 400)
    else
      record = Composers.detailed(params[:component_id])
      if record.empty?
        json_response({:error => "Object not found for component id: #{params[:component_id]}"}, 400)
      else
        if format == 'html'
          ERB.new(File.read('../plugins/composers/backend/views/detail.html.erb')).result(binding)
        else
          json_response(record)
        end
      end
    end
  end

end
