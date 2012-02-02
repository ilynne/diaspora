# NOTE: this migration will remove a lot of unused rows.  It is highly suggested
# that you run `OPTIMIZE TABLE share_visibilities` after this
# migration is complete.
#
# caution: you may want to take your pod offline during the OPTIMIZE command.

class RemovePublicShareVisibilities < ActiveRecord::Migration
  class ShareVisibility < ActiveRecord::Base; end

  def self.up
    %w{Post Photo}.each do |type|

      index = 0
      visibilitiy_size = ShareVisibility.count

      while index < visibilitiy_size + 100 do
        sql = <<-SQL
          DELETE sv
            FROM share_visibilities AS sv
              INNER JOIN posts
              ON sv.shareable_id = posts.id
              WHERE sv.shareable_type = "#{type}"
                AND #{type.tableize}.public IS TRUE
                AND #{type.tableize}.id < #{index};
        SQL

        ActiveRecord::Base.connection.execute(sql)

        index += 100
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end