defmodule Api.Users do

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Users.User

  def get_all_users() do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) do
    from(u in User, where: u.email == ^email)
    |> Repo.one()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(userID, attrs) do
    user = get_user!(userID)
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(userID) do
    user = get_user!(userID)
    Repo.delete(user)
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      nil ->
        {:error, :not_found}

      user ->
        if Bcrypt.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
