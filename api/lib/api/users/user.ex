defmodule Api.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :name, :string
    field :lastname, :string
    field :phone, :integer
    field :url_picture, :string
    field :non_hashed_password, :string, virtual: true
    field :password, :string
    field :is_admin, :boolean, default: false
    belongs_to :team, Api.Teams.Team, foreign_key: :team_id
    has_many :timeManagers, Api.TimeManagers.TimeManager
    has_many :clocks, Api.Clocks.Clock

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :name, :lastname, :phone, :url_picture, :non_hashed_password, :is_admin, :team_id])
    |> validate_required([:email, :non_hashed_password])
    |> validate_format(:email, ~r/^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:email)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    if changeset.valid? && get_field(changeset, :non_hashed_password) do
      change(changeset, password: Bcrypt.hash_pwd_salt(get_field(changeset, :non_hashed_password)))
    else
      changeset
    end
  end

  defimpl Jason.Encoder do
    def encode(%Api.Users.User{password: password, team_id: team_id, username: username, email: email, name: name, lastname: lastname, phone: phone, url_picture: url_picture, is_admin: is_admin, id: id}, opts) do
      Jason.Encode.map(%{
        id: id,
        username: username,
        email: email,
        name: name,
        lastname: lastname,
        phone: phone,
        url_picture: url_picture,
        is_admin: is_admin,
        password: password,
        team_id: team_id
      }, opts)
    end
  end
end
