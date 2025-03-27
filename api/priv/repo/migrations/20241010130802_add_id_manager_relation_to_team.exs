defmodule Api.Repo.Migrations.AddIdManagerRelationToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :manager_id, references(:managers, on_delete: :delete_all)
    end

    create index(:teams, [:manager_id])
  end
end
