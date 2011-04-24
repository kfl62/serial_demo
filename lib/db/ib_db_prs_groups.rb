#encoding: utf-8

module Ib
  module Db
    module Persons
      # #IButton Database Persons-Group model
      # ##Migration 0008_create_table_persons_groups.rb
      #     def up
      #       create_table('prs_groups') do
      #         primary_key :id
      #         column      :name,          String,     :size => 20
      #         column      :created_at,    DateTime
      #         column      :updated_at,    DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:prs_groups)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestams})
      # ##Associations
      #   *many_to_many* -> owners {Ib::Db::Persons::Owner} *Attention!* *:join_table => :prs_groups_owners*
      # @example Group members
      #   g = Group.first
      #   g.owners        #=> Array of {Ib:Db::Persons::Owner} objects
      class Group < Sequel::Model
        set_dataset :prs_groups
        plugin :timestamps

        many_to_many :owners,      :join_table => :prs_groups_owners
        one_to_many  :permissions
      end
    end
  end
end
