defmodule Api.Clocks do

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Clocks.Clock

  def get_last_clock_for_user(userID) do
    from(c in Clock, where: c.user_id == ^userID, order_by: [desc: c.time], limit: 1)
    |> Repo.one()
  end

  def get_last_clock_for_user_by_limit(userID, limit \\ 1) do
    from(c in Clock, where: c.user_id == ^userID, order_by: [desc: c.time], limit: ^limit)
    |> Repo.all()
  end

  def get_last_clock_for_user_by_day(userID, last_day) do
    from(c in Clock, where: c.user_id == ^userID and c.time >= ^last_day, order_by: [desc: c.time])
    |> Repo.all()
  end

  def get_clocks_for_user(userID) do
    from(c in Clock, where: c.user_id == ^userID, order_by: [desc: c.time])
    |> Repo.all()
  end

  def clock_in(userID) do
    userID = String.to_integer(userID)
    c = get_last_clock_for_user(userID)
    clock = %Clock{user_id: userID, time: DateTime.utc_now(), status: true}
    clock
    |> Clock.changeset(%{time: clock.time, user_id: clock.user_id, status: (if c, do: (if c.status, do: false, else: true), else: true)})
    |> Repo.insert()
  end

end
