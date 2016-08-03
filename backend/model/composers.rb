class Composers

  def self.detailed(resource_id)
    dataset.collect {|obj| obj[:id]}
  end


  def self.digital_objects(component_id)
    dataset.collect {|obj| obj[:id]}
  end


  def self.summary(resource_id)
    dataset.collect {|obj| obj[:id]}
  end


  private

  def self.dataset
    DB.open do |db|
      ds = db[:digital_object]

      if AppConfig[:composers_repositories] != :all
        ds.filter(:repo_id => AppConfig[:composers_repositories])
      end

      ds
    end
  end

end