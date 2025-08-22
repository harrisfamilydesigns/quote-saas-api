class BaseSerializer
  include Alba::Resource
  include Rails.application.routes.url_helpers
  transform_keys :lower_camel
end
