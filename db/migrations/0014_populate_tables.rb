#encoding: utf-8
=begin
#IButton Populate tables with initial values#
=end

class PopulateTables < Sequel::Migration

  def up
    DB[:hw_nodes].insert(nil,1,Time.now(),"Test node_1",3,3,Time.now(),Time.now())
    DB[:hw_nodes].insert(nil,2,Time.now(),"Test node_2",3,3,Time.now(),Time.now())
    DB[:hw_readers].insert(nil,1,1,"Test reader_1",Time.now(),Time.now())
    DB[:hw_readers].insert(nil,2,1,"Test reader_2",Time.now(),Time.now())
    DB[:hw_tasks].insert(nil,1,"Open door",Time.now(),Time.now())
    DB[:hw_devices].insert(nil,1,1,1,"Test device_1",Time.now(),Time.now())
    DB[:hw_devices].insert(nil,2,1,1,"Test device_2",Time.now(),Time.now())
    DB[:hw_keys].insert(nil,"123456789ABC",Time.now(),Time.now())
    DB[:hw_keys].insert(nil,"2900001424C1",Time.now(),Time.now())
    DB[:prs_owners].insert(nil,1,"Unknown","Owner",Time.now(),Time.now())
    DB[:prs_owners].insert(nil,2,"Attila","Albert",Time.now(),Time.now())
    DB[:prs_admins].insert(nil,1,"test","test@example.org","mFh7AiLhrk","8f810609c5215b6315d42e7fabecce877442d722",Time.now(),Time.now())
    DB[:prs_admins].insert(nil,2,"csattila","Albert.Attila@evoline.ro",nil,nil,Time.now(),Time.now())
    DB[:prs_groups].insert(nil,"Employees",Time.now(),Time.now())
    DB[:prs_groups_owners].insert(1,1)
    DB[:prs_groups_owners].insert(1,2)
    DB[:prs_permissions].insert(nil,1,1,1,1,1,Time.now(),Time.now())
  end
  def down
    DB[:prs_permissions].delete
    DB[:prs_groups_owners].delete
    DB[:prs_groups].delete
    DB[:prs_admins].delete
    DB[:prs_owners].delete
    DB[:hw_keys].delete
    DB[:hw_devices].delete
    DB[:hw_tasks].delete
    DB[:hw_readers].delete
    DB[:hw_nodes].delete
  end
end