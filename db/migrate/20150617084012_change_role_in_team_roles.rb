class ChangeRoleInTeamRoles < ActiveRecord::Migration
  def up
    change_column :team_roles, :role, :integer, default: 0
  end

  def down
    change_column :team_roles, :role, :string
  end
end
