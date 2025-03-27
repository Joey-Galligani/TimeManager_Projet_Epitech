defmodule Api.Clocks.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clocks" do
    field :status, :boolean, default: true
    field :time, :naive_datetime
    belongs_to :user, Api.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status])
    |> validate_required([:time, :status])
  end

  defimpl Jason.Encoder do
    def encode(%Api.Clocks.Clock{status: status, time: time, user_id: user_id, id: id}, opts) do
      Jason.Encode.map(%{
        id: id,
        user_id: user_id,
        time: time,
        status: status
      }, opts)
    end
  end
end
