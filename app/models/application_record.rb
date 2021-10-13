class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    ignore_key         = false
    get_replacements   = false
    is_captured        = false
    is_public          = true
    is_deprecated      = true
  end


  ### Captured functionality #####
  def captured
    if self.is_captured
      return self
    else
      self.is_captured = true
    end
  end

  def public
    if self.is_public
      return false
    end
  end
  ### Warnings #####
  ### Deprecated ###
  def deprecated
    self.is_deprecated ? false : true
  end
end
