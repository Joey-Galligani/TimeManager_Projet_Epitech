defmodule Api.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        name_team: "some name_team"
      })
      |> Api.Teams.create_team()

    team
  end
end
