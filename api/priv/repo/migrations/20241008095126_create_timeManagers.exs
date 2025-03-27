defmodule Api.Repo.Migrations.CreateTimeManagers do
  use Ecto.Migration

  def change do
    create table(:timeManagers) do
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :type, :string
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:timeManagers, [:user_id])
  end
end
