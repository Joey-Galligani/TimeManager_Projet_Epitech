defmodule Api.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name_team, :string
      #add :id_manager, references(:managers, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    #create index(:teams, [:id_manager])
  end
end
