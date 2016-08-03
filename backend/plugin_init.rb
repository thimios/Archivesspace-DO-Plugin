if !AppConfig.has_key?(:composers_repositories)
  # default to all repositories
  AppConfig[:composers_repositories] = :all
end