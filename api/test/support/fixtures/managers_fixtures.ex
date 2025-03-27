defmodule Api.ManagersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Managers` context.
  """

  @doc """
  Generate a manager.
  """
  def manager_fixture(attrs \\ %{}) do
    {:ok, manager} =
      attrs
      |> Enum.into(%{

      })
      |> Api.Managers.create_manager()

    manager
  end
end
