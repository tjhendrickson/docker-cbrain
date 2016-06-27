d=DataProvider.new({:name => "local2",
                    :type => "EnCbrainLocalDataProvider",
                    :user_id => 1,
                    :group_id => 1,
                    :remote_dir => "/home/cbrain/data_provider",
                    :description => "Local data provider"})
d.type = "EnCbrainLocalDataProvider"
d.save!
