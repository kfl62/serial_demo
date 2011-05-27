#encoding: utf-8

module Ib
  module Db
    # Just for namespace and docs
    module Persons
      autoload :Admin,      'db/persons/admin'
      autoload :Group,      'db/persons/group'
      autoload :Owner,      'db/persons/owner'
      autoload :Permission, 'db/persons/permission'
    end
  end
end