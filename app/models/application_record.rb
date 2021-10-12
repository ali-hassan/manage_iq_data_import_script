class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    ignore_key = false
    get_replacements = false
    is_captured = false
    is_public = true
    is_deprecated = true

  end
end
