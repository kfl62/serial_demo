#encoding: utf-8
=begin
#IButton Database Persons-Groups_Owners join table create statement#
=end

class CreateTablePrsGroupsOwners < Sequel::Migration

  def up
    create_table('prs_groups_owners') do
      foreign_key   :group_id,       :prs_groups
      foreign_key   :owner_id,       :prs_owners
    end
  end

  def down
    drop_table(:prs_groups_owners)
  end

end