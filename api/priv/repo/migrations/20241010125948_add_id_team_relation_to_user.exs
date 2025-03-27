defmodule Api.Repo.Migrations.AddIdTeamRelationToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :team_id, references(:teams, on_delete: :delete_all), null: true
    end

    create index(:users, [:team_id])
  end
end
