defmodule ApiWeb.TimeManagerController do
  use ApiWeb, :controller
  use PhoenixSwagger, except: [delete: 2]

  alias Api.TimeManagers

  # List Working Times
  swagger_path :index do
    get "/api/timeManager/{userID}"
    description "Retrieve a list of working times for a specific user filtered by start and end times."
    parameter :userID, :path, :string, "The ID of the user to retrieve working times for", required: true
    parameter :start_time, :query, :string, "The start time for filtering working times", required: true, format: :date_time
    parameter :end_time, :query, :string, "The end time for filtering working times", required: true, format: :date_time
    response 200, "Success", Schema.array(:TimeManager)
  end

  def index(conn, %{"userID" => userID}) do
    working_times = TimeManagers.get_all_timeManagers(userID)
    json(conn, working_times)
  end

  # Show Working Time
  swagger_path :show do
    get "/api/timeManager/{userID}/{id}"
    description "Get details of a specific working time entry by user ID and working time ID."
    parameter :userID, :path, :string, "The ID of the user", required: true
    parameter :id, :path, :string, "The ID of the working time entry", required: true
    response 200, "Success", Schema.ref(:TimeManager)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show(conn, %{"userID" => userID, "id" => id}) do
    working_time = TimeManagers.get_timeManager!(userID, id)
    json(conn, working_time)
  end

  # Create Working Time
  swagger_path :create do
    post "/api/timeManager/{userID}"
    description "Create a new working time entry for a specific user."
    parameter :userID, :path, :string, "The ID of the user", required: true
    parameter :timeManager, :body, Schema.ref(:TimeManagerRequest), "The working time details to create", required: true
    response 201, "Created", Schema.ref(:TimeManager)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def create(conn, %{"userID" => userID, "timeManager" => working_time_params}) do
    case TimeManagers.create_timeManager(working_time_params, userID) do
      {:ok, timeManager} ->
        conn
        |> put_status(:created)
        |> json(%{timeManager: timeManager})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  # Update Working Time
  swagger_path :update do
    put "/api/timeManager/{id}"
    description "Update an existing working time entry."
    parameter :id, :path, :string, "The ID of the working time entry to update", required: true
    parameter :timeManager, :body, Schema.ref(:TimeManagerRequest), "The working time details to update", required: true
    response 200, "Success", Schema.ref(:TimeManager)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def update(conn, %{"id" => id, "timeManager" => working_time_params}) do
    case TimeManagers.update_timeManager(id, working_time_params) do
      {:ok, timeManager} ->
        conn
        |> json(%{timeManager: timeManager})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  # Delete Working Time
  swagger_path :delete_timeManager do
    PhoenixSwagger.Path.delete "/api/timeManager/{id}"
    description "Delete a specific working time entry by its ID."
    parameter :id, :path, :string, "The ID of the working time entry to delete", required: true
    response 204, "No Content"
    response 400, "Bad Request", Schema.ref(:Error)
  end

  def delete(conn, %{"id" => id}) do
    case TimeManagers.delete_timeManager(id) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> send_resp(conn, :bad_request, "Unable to delete working time")
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      TimeManager: swagger_schema do
        title "Working Time"
        description "A working time entry for a user"
        properties do
          id :integer, "Working Time ID"
          user_id :string, "The ID of the user associated with this working time"
          start_time :string, "The start time of the working period", format: :date_time
          end_time :string, "The end time of the working period", format: :date_time
        end
        example %{
          id: 1,
          user_id: "12",
          start_time: "2023-10-08T09:00:00Z",
          end_time: "2023-10-08T17:00:00Z"
        }
      end,
      TimeManagerRequest: swagger_schema do
        title "Working Time Request"
        description "Parameters required to create or update a working time entry"
        properties do
          start_time :string, "The start time of the working period", required: true, format: :date_time
          end_time :string, "The end time of the working period", required: true, format: :date_time
        end
        example %{
          start_time: "2023-10-08T09:00:00Z",
          end_time: "2023-10-08T17:00:00Z"
        }
      end,
      Error: swagger_schema do
        title "Error"
        description "An error response"
        properties do
          error :string, "Error message describing what went wrong"
        end
        example %{
          error: "Working time not found"
        }
      end
    }
  end
end
