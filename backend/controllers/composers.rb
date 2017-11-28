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
    

    digital_objects = Composers.summary(params[:resource_id])
    
    if digital_objects.empty?
      json_response({:error => "Resource not found for identifier: #{params[:resource_id]}"}, 400)
    else
      resource = Composers.get_resource(digital_objects[0][:component_id])
      json_response(
        :version => "0.0.1", 
        :resource_identifier => resource[:resource_identifier], 
        :resource_title => resource[:resource_title], 
        :ead_location => resource[:ead_location],
        :scopecontent => resource[:resource_scopecontent][0],
        :bioghist => resource[:resource_bioghist][0],
        :digital_objects => digital_objects)
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

    archival_object = Composers.detailed(params[:component_id] )
    parent = Composers.get_parent(archival_object)
    json_response(:archival_object => archival_object, :parent_object => parent)
  end

end
