ActiveAdmin.register ProjectTeam do
  menu parent: 'Projects'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :project_id, :user_id

  index do
    selectable_column
    column :id
    column :org do |project_team|
      project_team.project.org.name
    end
    column :project
    column :team_size do |project_team|
      project_team.project.team.count  
    end
    actions
  end
  
end
