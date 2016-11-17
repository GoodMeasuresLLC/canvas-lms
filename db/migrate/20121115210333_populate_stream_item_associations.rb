class PopulateStreamItemAssociations < ActiveRecord::Migration[4.2]
  tag :postdeploy
  disable_ddl_transaction!

  def self.up
    # the drop migration now exists, so this can no longer run async
    DataFixup::PopulateStreamItemAssociations.run
  end

  def self.down
  end
end
