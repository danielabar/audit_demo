# https://github.com/paper-trail-gem/paper_trail#6a-custom-version-classes
class ApplicationVersion < ActiveRecord
  include PaperTrail::VersionConcern
  self.abstract_class = true
end
