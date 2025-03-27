defmodule Api.ClocksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Clocks` context.
  """

  @doc """
  Generate a clock.
  """
  def clock_fixture(attrs \\ %{}) do
    {:ok, clock} =
      attrs
      |> Enum.into(%{
        status: true,
        time: ~N[2024-10-07 09:52:00]
      })
      |> Api.Clocks.create_clock()

    clock
  end
end
