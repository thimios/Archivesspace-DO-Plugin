require_relative File.join(ASUtils.find_base_directory, 'plugins/composers', 'mixed_content_parser')


class ArchivesSpaceService < Sinatra::Base

  # Endpoint to return data to archiveit for display in their interfaces
  Endpoint.get('/plugins/composers/archiveit')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_id", String],
      ["format", String, "Format of the data returned - json(default), html", :optional => true])
    .permissions([])
    .returns([200, "[(:digital_object)]"],
      [400, :error]) \
    do

    summary = Composers.summary(params[:resource_id])
    detail = Composers.detailed(summary[0][:component_id])


    resp = {
      :title => detail[:resource_title], 
      :extent => summary.size.to_s + " Digital Objects", 
      :display_url =>  File.join(AppConfig[:backend_proxy_url], "plugins/composers/summary?resource_id=#{params[:resource_id]}&format=html") 
    }
    if resp.empty?
      json_response({:error => "Resource not found for identifier: #{params[:resource_id]}"}, 400)
    else
        json_response(resp)
    end
  end

  # Endpoint to return data about a resource in archivesspace
  Endpoint.get('/plugins/composers/summary')
    .description("Get summarized Digital Object data for a specific Resource")
    .params(["resource_id", String])
    .permissions([])
    .returns([200, "[(:digital_object)]"],
      [400, :error]) \
    do
     
    resp = Composers.summary(params[:resource_id])
    record = Composers.detailed(resp[0][:component_id])
    parents = Composers.get_parents(resp)

    if resp.empty?
      json_response({:error => "Resource not found for identifier: #{params[:resource_id]}"}, 400)
    else
      json_response(
        :version => "0", 
        :resource_identifier => record[:resource_identifier], 
        :resource_title => record[:resource_title], 
        :ead_location => record[:ead_location],
        :scopecontent => record[:resource_scopecontent][0],
        :bioghist => record[:resource_bioghist][0],
        :parents => parents,
        :digital_objects => resp)
    end
  end

  # Endpoint to return data about a an archival object in archivesspace
  Endpoint.get('/plugins/composers/detailed')
    .description("Get detailed data for a specific digital object record")
    .params(["component_id", String, "Component id for the record"])
    .permissions([])
    .returns([200, "[(:digital_object)]"],
       [400, :error]) \
    do

    record = Composers.detailed(params[:component_id])

    if record.empty?
      json_response({:error => "Object not found for component id: #{params[:component_id]}"}, 400)
    else

      json_response(
        :ao => record,
        :parent => Composers.get_parent(record),
        :col_url => AppConfig[:backend_proxy_url] + "/plugins/composers/summary?resource_id=" + record[:resource_identifier])
    end
  end

end
