defmodule Api.TimeManagers.TimeManager do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeManagers" do
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    field :type, :string
    field :description, :string
    belongs_to :user, Api.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(timeManager, attrs) do
    timeManager
    |> cast(attrs, [:start_time, :end_time, :type, :description])
    |> validate_required([:start_time, :end_time, :type, :description])
  end

  defimpl Jason.Encoder do
    def encode(%Api.TimeManagers.TimeManager{start_time: start_time, end_time: end_time, user_id: user_id, type: type, description: description, id: id}, opts) do
      Jason.Encode.map(%{
        id: id,
        user_id: user_id,
        end_time: end_time,
        start_time: start_time,
        type: type,
        description: description
      }, opts)
    end
  end
end
