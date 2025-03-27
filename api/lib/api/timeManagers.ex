defmodule Api.TimeManagers do

  import Ecto.Query, warn: false
  alias Api.Repo
  alias Api.TimeManagers.TimeManager

  def get_all_timeManagers(userID) do
    from(w in TimeManager, where: w.user_id == ^userID, order_by: [asc: w.start_time])
    |> Repo.all()
  end

  def get_timeManager!(userID, id) do
    from(w in TimeManager, where: w.user_id == ^userID and w.id == ^id)
    |> Repo.one!()
  end

  def create_timeManager(attrs \\ %{}, userID) do
    userID = String.to_integer(userID)
    timeManager = %TimeManager{user_id: userID, end_time: Map.fetch(attrs, "end_time"), start_time: Map.fetch(attrs, "start_time")}
    timeManager
    |> TimeManager.changeset(attrs)
    |> Repo.insert()
  end

  def update_timeManager(id, attrs) do
    timeManager = Repo.get!(TimeManager, id)
    timeManager
    |> TimeManager.changeset(attrs)
    |> Repo.update()
  end

  def delete_timeManager(id) do
    timeManager = Repo.get!(TimeManager, id)
    Repo.delete(timeManager)
  end

end
