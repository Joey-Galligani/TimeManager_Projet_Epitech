defmodule Api.Teams do

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.Teams.Team

  def get_all_teams do
    Repo.all(Team)
  end

  def get_team!(id), do: Repo.get!(Team, id)

  def create_team(attrs \\ %{}, managerID) do
    managerID = String.to_integer(managerID)
    team = %Team{manager_id: managerID, name_team: Map.fetch(attrs, "name_team")}
    team
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def update_team(teamID, attrs) do
    team = get_team!(teamID)
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  def delete_team(teamID) do
    team = get_team!(teamID)
    Repo.delete(team)
  end
end
