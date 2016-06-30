# Creates a local DataProvider

d=DataProvider.new({:name => "local",
                    :type => "EnCbrainLocalDataProvider",
                    :user_id => 1,
                    :group_id => 1,
                    :remote_dir => "/home/cbrain/data_provider",
                    :description => "Local data provider",
                    :online => true})
d.type = "EnCbrainLocalDataProvider"
d.save!
