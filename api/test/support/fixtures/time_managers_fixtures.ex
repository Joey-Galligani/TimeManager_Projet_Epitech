defmodule Api.TimeManagersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.TimeManagers` context.
  """

  @doc """
  Generate a time_manager.
  """
  def time_manager_fixture(attrs \\ %{}) do
    {:ok, time_manager} =
      attrs
      |> Enum.into(%{
        type: "some type"
      })
      |> Api.TimeManagers.create_time_manager()

    time_manager
  end
end
