#encoding: utf-8

module Ib
  module Db
    module Hw
      # #IButton Database Hardware-Reader model
      # ##Migration 0003_create_table_hw_readers.rb
      #     def up
      #       create_table(:hw_readers) do
      #         primary_key :id
      #         foreign_key :node_id,     :hw_nodes,  :on_delete => :cascade, :on_update => :cascade
      #         column      :order,       Fixnum,     :size => 4,   :default => 1
      #         column      :name,        String,     :size => 20
      #         column      :created_at,  DateTime
      #         column      :updated_at,  DateTime
      #       end
      #     end
      #     def down
      #       drop_table(:hw_readers)
      #     end
      # ##Loaded plugins
      #   `plugin :timestamps` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html Sequel plugin timestamps})<br />
      #   `plugin :validation_helpers` more info ({http://sequel.rubyforge.org/rdoc-plugins/classes/Sequel/Plugins/ValidationHelpers.html Sequel plugins validation_helpers})
      # ##Associations
      #   *many_to_one* -> node         {Ib::Db::Hw::Node}<br />
      #   *one_to_many* -> permissions  {Ib::Db::Persons::Permission}
      # ##Validations
      #   TODO document validations
      # @example Connected to node?
      #   r = Reader.first
      #   r.node.sid         #=> Integer connected node's sid
      # @example Permissions
      #   r = Reader.first
      #   r.permissions      #> Array of {Ib::Db::Persons::Permission} objects
      class Reader < Sequel::Model
        set_dataset :hw_readers
        plugin :timestamps
        plugin :validation_helpers

        many_to_one :node
        one_to_many :permissions, :class => "Ib::Db::Persons::Permission", :key => :request_reader_id

        class << self
          # @todo document this method
          def new_record_defaults
            [
              {:css => "hidden",:name  => "node_id",:label => I18n.t('hw_reader.node_id'),:value => "nil"},
              {:css => "normal",:name  => "name",:label => I18n.t('hw_reader.name'),:value => "Reader 1"},
              {:css => "integer",:name  => "order",:label => I18n.t('hw_reader.order'),:value => "1"}
            ]
          end
          # Orphaned readers (does not belong to any node)
          # @return [Array]
          def orphans
            retval = []
            all.each{|r| retval << r if r.node_id.nil?}
            retval
          end
          # @todo document this method
          def auto_search(e)
            readers = []
            all do |r|
              readers << {:id => r.id,:name => r.name,:label => "#{r.name} #{r.node.nil? ? ' | Orphan' : ''}"}
            end
            {:identifier => "id",:items => readers}
          end
        end

        # @todo
        def validate
          validates_presence :name
          validates_max_length 20, :name, :allow_nil => true
        end
        # @todo
        # @return [Log::Error]
        def before_destroy
          delete_message
          super
        end
        # @return [Array of Hashes] one Hash for each column
        # @example Each hash contains:
        #   {
        #     :css   => "integer",        # style attribute for span|input tag
        #     :name  => "id",             # name attribute for span|input tag
        #     :label => I18n.t('mdl.id'), # localized title
        #     :value => id                # columns value
        #   }
        def table_data
          [
            {:css => "integer",:name => "id",:label => I18n.t('mdl.id'),:value => id},
            {:css => "normal",:name  => "name",:label => I18n.t('hw_reader.name'),:value => name},
            {:css => (node.nil? ? "ce bo":"normal"),:name => "node_id",:label => I18n.t('hw_reader.node_id'),:value => (node.name rescue 'orphan')},
            {:css => "integer",:name  => "order",:label => I18n.t('hw_reader.order'),:value => order},
            {:css => "datetime",:name  => "created_at",:label => I18n.t('mdl.created_at'),:value => created_at},
            {:css => "datetime",:name  => "updated_at",:label => I18n.t('mdl.updated_at'),:value => updated_at}
          ]
        end
        protected
        # Insert a translated warning message in {Ib::Db::Log::Error} table
        # @return [Log::Error]
        def delete_message
          Log::Error.create(:from => "Hw::Reader id=#{id}",
                            :error => I18n.t('crud.log.delete'))
        end
      end
    end
  end
end

