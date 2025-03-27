defmodule Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password, :string
      add :name, :string
      add :lastname, :string
      add :phone, :integer
      add :url_picture, :string
      add :is_admin, :boolean, default: false
      #add :team_id, references(:teams, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    #create index(:users, [:team_id])
  end
end
