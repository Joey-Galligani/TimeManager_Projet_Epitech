defmodule ApiWeb.TeamController do
  use ApiWeb, :controller
  use PhoenixSwagger, except: [delete: 2]

  alias Api.Teams

  # List Teams
  swagger_path :index do
    get "/api/teams"
    description "Get all team."
    response 200, "Success", Schema.array(:Team)
  end

  def index(conn, _params) do
    teams = Teams.get_all_teams()
    json(conn, teams)
  end

   # Show Team
   swagger_path :show do
    get "/api/teams/{teamID}"
    description "Get details of a specific team by team ID."
    parameter :teamID, :path, :string, "The ID of the team to retrieve", required: true
    response 200, "Success", Schema.ref(:Team)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show(conn, %{"teamID" => teamID}) do
    team = Teams.get_team!(teamID)
    json(conn, team)
  end

  # Create Team
  swagger_path :create do
    post "/api/teams/{managerID}"
    description "Create a new team."
    parameter :managerID, :path, :string, "The ID of the user", required: true
    parameter :team, :body, Schema.ref(:TeamRequest), "The team details to create", required: true
    response 201, "Created", Schema.ref(:Team)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def create(conn, %{"managerID" => managerID, "team" => team_params}) do
    case Teams.create_team(team_params, managerID) do
      {:ok, team} ->
        conn
        |> put_status(:created)
        |> json(%{team: team})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

   # Update Team
   swagger_path :update do
    put "/api/teams/{teamID}"
    description "Update an existing team's details."
    parameter :teamID, :path, :string, "The ID of the team to update", required: true
    parameter :team, :body, Schema.ref(:TeamRequest), "The team details to update", required: true
    response 200, "Success", Schema.ref(:Team)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def update(conn, %{"teamID" => teamID, "team" => team_params}) do
    case Teams.update_team(teamID, team_params) do
      {:ok, team} ->
        conn
        |> json(%{team: team})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
      end
  end

  # Delete Team
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/teams/{teamID}"
    description "Delete a team by team ID."
    parameter :teamID, :path, :string, "The ID of the team to delete", required: true
    response 204, "No Content"
    response 400, "Bad Request", Schema.ref(:Error)
  end

  def delete(conn, %{"teamID" => teamID}) do
    case Teams.delete_team(teamID) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> send_resp(conn, :bad_request, "Unable to delete working time")
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      Team: swagger_schema do
        title "Team"
        description "A team in the system"
        properties do
          id :integer, "Team ID"
          name_team :string, "The team's name"
          manager_id :string, "The ID of the user associated with this team"
          inserted_at :string, "When the team was created", format: :date_time
          updated_at :string, "When the team was last updated", format: :date_time
        end
        example %{
          id: 1,
          name_team: "Ressources Humaines",
          manager_id: "23",
          inserted_at: "2023-10-08T14:30:00Z",
          updated_at: "2023-10-08T18:00:00Z"
        }
      end,
      TeamRequest: swagger_schema do
        title "Team Request"
        description "Parameters required to create or update a team"
        properties do
          name_team :string, "The team's name", required: true
        end
        example %{
          team: %{
            name_team: "Ressources Humaines"
          }
        }
      end,
      Error: swagger_schema do
        title "Error"
        description "An error response"
        properties do
          error :string, "Error message describing what went wrong"
        end
        example %{
          error: "Team not found"
        }
      end
    }
  end
end
