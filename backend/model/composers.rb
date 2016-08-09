class Composers

  BASE_DETAIL_URI = '/plugins/composers/detailed?component_id='


  #  resource:
  #  -  identifier
  #  -  title
  #  -  bioghist note
  #  -  scopecontent note
  #  archival object:
  #  -  component identifier
  #  -  title
  #  -  date expression
  #  -  phystech
  #  -  extent/phystech
  #  -  scopecontent note
  #  -  accessrestrict note
  #  -  userestrict note
  #  -  rights statements
  #  -  names of linked agents

  def self.detailed(component_id)
    ds = dataset(true).filter(:component_id => component_id)
    out = {}
    puts "SSSSSSSSSS #{ds.sql}"
    ds.each do |obj|
      if out.empty?
        out = {
          :identifier => ASUtils.json_parse(obj[:res_identifier]).compact.join('.'),
          :resource_title => obj[:res_title],
          :bioghist => [extract_note(obj[:res_notes], 'bioghist')],
          :resource_scopecontent => [extract_note(obj[:res_notes], 'scopecontent')],

          :component_id => obj[:component_id],
          :title => obj[:ao_title],
          :date => [[obj[:date_begin], obj[:date_end]]],
          :phystech => [extract_note(obj[:ao_notes], 'phystech')],
          :extent=> [obj[:extent_phys]],
          :item_scopecontent => [extract_note(obj[:ao_notes], 'scopecontent')],
          :accessrestrict => [extract_note(obj[:ao_notes], 'accessrestrict')],
          :userestrict => [extract_note(obj[:ao_notes], 'userestrict')],
          :rights_statements => [obj[:rights_type]],
          :agents => ['really? ... oh god']
        }
      else
        out[:bioghist] << extract_note(obj[:res_notes], 'bioghist')
        out[:resource_scopecontent] << extract_note(obj[:res_notes], 'scopecontent')
        out[:date] << [obj[:date_begin], obj[:date_end]]
        out[:phystech] << extract_note(obj[:ao_notes], 'phystech')
        out[:extent] << obj[:extent_phys]
        out[:item_scopecontent] << extract_note(obj[:ao_notes], 'scopecontent')
        out[:accessrestrict] << extract_note(obj[:ao_notes], 'accessrestrict')
        out[:userestrict] << extract_note(obj[:ao_notes], 'userestrict')
        out[:rights_statements] << obj[:rights_type]
        out[:agents] << 'really? ... oh god'
      end
    end

    crunch(out[:bioghist])
    crunch(out[:resource_scopecontent])
    crunch(out[:phystech])
    crunch(out[:extent])
    crunch(out[:item_scopecontent])
    crunch(out[:accessrestrict])
    crunch(out[:userestrict])
    crunch(out[:rights_statements])
    crunch(out[:agents])

    out[:date] = find_date_range(out[:date])
    out
  end


  def self.summary(resource_id)
    # come on ruby what's the nice way to set up that id array?
    ds = dataset.filter(:identifier => ASUtils.to_json(resource_id.split('.', 4).concat(Array.new(4)).take(4)))

    out = {}
    ds.each do |obj|
      if out[obj[:ao_id]]
        out[obj[:ao_id]][:date] << [obj[:date_begin], obj[:date_end]]
        out[obj[:ao_id]][:phystech] << extract_note(obj[:ao_notes], 'phystech')
        out[obj[:ao_id]][:extent] << obj[:extent_phys]
      else
        out[obj[:ao_id]] = {
          :component_id => obj[:component_id],
          :title => obj[:ao_title],
          :date => [[obj[:date_begin], obj[:date_end]]],
          :phystech => [extract_note(obj[:ao_notes], 'phystech')],
          :extent=> [obj[:extent_phys]],
          :detail_url => detail_url(obj[:component_id]),
        }
      end
    end

    out.values.map do |v|
      crunch(v[:phystech])
      crunch(v[:extent])
      v[:date] = find_date_range(v[:date])
      v
    end
  end


  private

  def self.find_date_range(dates)
    earliest = '9999'
    latest = '0000'
    dates.flatten.compact.each do |date|
      puts "DDD #{date}"
      earliest = date if date < earliest
      latest = date if date > latest
    end
    earliest = latest = '?' if earliest == '9999'
    earliest + ' -- ' + latest
  end


  def self.crunch(a)
    a.compact!
    a.uniq!
    a.delete_if { |v| v.empty? }
  end


  def self.detail_url(id)
    AppConfig[:backend_url] + BASE_DETAIL_URI + (id || '')
  end


  def self.extract_note(notes, type)
    parsed = ASUtils.json_parse(notes || '{}')
    return '' unless parsed['type'] == type
    parsed['subnotes'].select { |sn| sn['publish'] }.collect { |sn| sn['content'] }.join(' ')
  end


  def self.dataset(detailed = false)
    DB.open do |db|
      ds = db[:digital_object]

      if AppConfig[:composers_repositories] != :all
        ds = ds.filter(:repo_id => AppConfig[:composers_repositories])
      end

      ds = ds.join(:instance_do_link_rlshp, :digital_object_id => :id)
        .join(:instance, :id => :instance_id)
        .join(:archival_object, :id => :archival_object_id)
        .join(:resource, :id => :root_record_id)
        .left_join(:date, :archival_object_id => :archival_object__id)
        .left_join(:note___ao_note, :archival_object_id => :archival_object__id)
        .left_join(:extent, :digital_object_id => :digital_object__id)
        .select(Sequel.as(:digital_object__digital_object_id, :do_identifier),
                Sequel.as(:archival_object__id, :ao_id),
                Sequel.as(:archival_object__component_id, :component_id),
                Sequel.as(:archival_object__title, :ao_title),
                Sequel.as(:digital_object__title, :do_title),
                Sequel.as(:date__begin, :date_begin),
                Sequel.as(:date__end, :date_end),
                Sequel.as(:ao_note__notes, :ao_notes),
                Sequel.as(:extent__physical_details, :extent_phys))

      if detailed
        ds = ds.left_join(:note___res_note, :resource_id => :resource__id)
          .left_join(:rights_statement, :archival_object_id => :archival_object__id)
          .left_join(:enumeration_value___rights_statement_rights_type, :id => :rights_statement__rights_type_id)
          .filter(:rights_statement__active => 1)
          .left_join(:linked_agents_rlshp, :archival_object_id => :archival_object__id)
          .left_join(:agent_person, :id => :linked_agents_rlshp__agent_person_id)
          .left_join(:agent_software, :id => :linked_agents_rlshp__agent_software_id)
          .left_join(:agent_family, :id => :linked_agents_rlshp__agent_family_id)
          .left_join(:agent_corporate_entity, :id => :linked_agents_rlshp__agent_corporate_entity_id)
          .select_append(Sequel.as(:resource__identifier, :res_identifier),
                         Sequel.as(:resource__title, :res_title),
                         Sequel.as(:res_note__notes, :res_notes),
                         Sequel.as(:rights_statement_rights_type__value, :rights_type))
      end

      ds
    end
  end

end

