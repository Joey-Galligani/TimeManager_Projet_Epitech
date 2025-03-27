defmodule Api.TimeManagersTest do
  use Api.DataCase

  alias Api.TimeManagers

  describe "time_managers" do
    alias Api.TimeManagers.TimeManager

    import Api.TimeManagersFixtures

    @invalid_attrs %{type: nil}

    test "list_time_managers/0 returns all time_managers" do
      time_manager = time_manager_fixture()
      assert TimeManagers.list_time_managers() == [time_manager]
    end

    test "get_time_manager!/1 returns the time_manager with given id" do
      time_manager = time_manager_fixture()
      assert TimeManagers.get_time_manager!(time_manager.id) == time_manager
    end

    test "create_time_manager/1 with valid data creates a time_manager" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %TimeManager{} = time_manager} = TimeManagers.create_time_manager(valid_attrs)
      assert time_manager.type == "some type"
    end

    test "create_time_manager/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TimeManagers.create_time_manager(@invalid_attrs)
    end

    test "update_time_manager/2 with valid data updates the time_manager" do
      time_manager = time_manager_fixture()
      update_attrs = %{type: "some updated type"}

      assert {:ok, %TimeManager{} = time_manager} = TimeManagers.update_time_manager(time_manager, update_attrs)
      assert time_manager.type == "some updated type"
    end

    test "update_time_manager/2 with invalid data returns error changeset" do
      time_manager = time_manager_fixture()
      assert {:error, %Ecto.Changeset{}} = TimeManagers.update_time_manager(time_manager, @invalid_attrs)
      assert time_manager == TimeManagers.get_time_manager!(time_manager.id)
    end

    test "delete_time_manager/1 deletes the time_manager" do
      time_manager = time_manager_fixture()
      assert {:ok, %TimeManager{}} = TimeManagers.delete_time_manager(time_manager)
      assert_raise Ecto.NoResultsError, fn -> TimeManagers.get_time_manager!(time_manager.id) end
    end

    test "change_time_manager/1 returns a time_manager changeset" do
      time_manager = time_manager_fixture()
      assert %Ecto.Changeset{} = TimeManagers.change_time_manager(time_manager)
    end
  end
end
