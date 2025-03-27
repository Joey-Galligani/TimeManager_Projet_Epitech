defmodule Api.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name_team, :string
    belongs_to :manager, Api.Managers.Manager

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name_team])
    |> validate_required([:name_team])
  end

  defimpl Jason.Encoder do
    def encode(%Api.Teams.Team{manager_id: manager_id, name_team: name_team, id: id}, opts) do
      Jason.Encode.map(%{
        id: id,
        manager_id: manager_id,
        name_team: name_team
      }, opts)
    end
  end
end
