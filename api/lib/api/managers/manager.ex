defmodule Api.Managers.Manager do
  use Ecto.Schema
  import Ecto.Changeset

  schema "managers" do

    belongs_to :user, Api.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(manager, attrs) do
    manager
    |> cast(attrs, [])
    |> validate_required([])
  end

  defimpl Jason.Encoder do
    def encode(%Api.Managers.Manager{user_id: user_id, id: id}, opts) do
      Jason.Encode.map(%{
        id: id,
        user_id: user_id
      }, opts)
    end
  end
end
