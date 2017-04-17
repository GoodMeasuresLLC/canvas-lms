environment_configuration(defined?(config) && config) do |config|
  config.cache_classes = true
  config.action_controller.perform_caching = true
  config.action_view.cache_template_loading = true
  config.eager_load = true
end
