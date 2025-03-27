defmodule Api.Managers do

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Managers.Manager

  def get_all_managers do
    Repo.all(Manager)
  end

  def get_manager!(id), do: Repo.get!(Manager, id)

  def create_manager(userID) do
    userID = String.to_integer(userID)
    manager = %Manager{user_id: userID}
    manager
    |> Manager.changeset(%{user_id: userID})
    |> Repo.insert()
  end

  def delete_manager(managerID) do
    manager = get_manager!(managerID)
    Repo.delete(manager)
  end
end
