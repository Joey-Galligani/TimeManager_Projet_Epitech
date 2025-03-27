defmodule ApiWeb.ManagerController do
  use ApiWeb, :controller
  use PhoenixSwagger, except: [delete: 2]

  alias Api.Managers

  # List Managers
  swagger_path :index do
    get "/api/managers"
    description "Get all manager."
    response 200, "Success", Schema.array(:Manager)
  end

  def index(conn, _params) do
    managers = Managers.get_all_managers()
    json(conn, managers)
  end

  # Show Manager
  swagger_path :show do
    get "/api/managers/{managerID}"
    description "Get details of a specific manager by manager ID."
    parameter :managerID, :path, :string, "The ID of the manager to retrieve", required: true
    response 200, "Success", Schema.ref(:Manager)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show(conn, %{"managerID" => managerID}) do
    manager = Managers.get_manager!(managerID)
    json(conn, manager)
  end

  # Create Manager
  swagger_path :create do
    post "/api/managers/{userID}"
    description "Create a new manager."
    parameter :userID, :path, :string, "The manager details to create", required: true
    response 201, "Created", Schema.ref(:Manager)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def create(conn, %{"userID" => userID}) do
    case Managers.create_manager(userID) do
      {:ok, manager} ->
        conn
        |> put_status(:created)
        |> json(%{manager: manager})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  # Delete Manager
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/managers/{managerID}"
    description "Delete a manager by manager ID."
    parameter :managerID, :path, :string, "The ID of the manager to delete", required: true
    response 204, "No Content"
    response 400, "Bad Request", Schema.ref(:Error)
  end

  def delete(conn, %{"managerID" => managerID}) do
    case Managers.delete_manager(managerID) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> send_resp(conn, :bad_request, "Unable to delete manager")
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      Manager: swagger_schema do
        title "Manager"
        description "A manager in the system"
        properties do
          id :integer, "Manager ID"
          user_id :string, "The ID of the user associated with this manager"
          inserted_at :string, "When the user was created", format: :date_time
          updated_at :string, "When the user was last updated", format: :date_time
        end
        example %{
          id: 1,
          user_id: "23",
          inserted_at: "2023-10-08T14:30:00Z",
          updated_at: "2023-10-08T18:00:00Z"
        }
      end,
      Error: swagger_schema do
        title "Error"
        description "An error response"
        properties do
          error :string, "Error message describing what went wrong"
        end
        example %{
          error: "Manager not found"
        }
      end
    }
  end
end
