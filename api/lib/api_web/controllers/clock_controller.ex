defmodule ApiWeb.ClockController do
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Api.Clocks

  # Get all clock for a user
  swagger_path :show do
    get "/api/clocks/{userID}"
    description "Get clock information for a specific user."
    parameter :userID, :path, :string, "The ID of the user whose clock you want to retrieve", required: true
    response 200, "Success", Schema.ref(:Clock)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show(conn, %{"userID" => userID}) do
    case Clocks.get_clocks_for_user(userID) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clock records found"})
      clock ->
        conn
        |> put_status(:ok)
        |> json(%{clock: clock})
    end
  end

  # Get the chosen clock for a user
  swagger_path :show_last_by_limit do
    get "/api/clocks/{userID}/last_by_limit"
    description "Get the last clock information for a specific user."
    parameter :userID, :path, :string, "The ID of the user whose last clock you want to retrieve", required: true
    parameter :limit, :query, :integer, "The number of last clock records to retrieve", required: false
    response 200, "Success", Schema.ref(:Clock)
    response 404, "Not Found", Schema.ref(:Error)
  end

  # parameter :limit, :query, :integer, "The number of last clock records to retrieve", required: false
  def show_last_by_limit(conn, %{"userID" => userID, "limit" => limit}) do
    limit = String.to_integer(limit)
    case Clocks.get_last_clock_for_user_by_limit(userID, limit) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clock records found"})
      clocks ->
        conn
        |> put_status(:ok)
        |> json(%{clocks: clocks})
    end
  end

    # Get the chosen clock for a user
    swagger_path :show_last_by_day do
      get "/api/clocks/{userID}/last_by_day"
      description "Get the last clock information for a specific user."
      parameter :userID, :path, :string, "The ID of the user whose last clock you want to retrieve", required: true
      parameter :last_day, :query, :integer, "The last day you want to retreive clocks from", required: false
      response 200, "Success", Schema.ref(:Clock)
      response 404, "Not Found", Schema.ref(:Error)
    end

    # parameter :limit, :query, :string, "The last day you want to retreive clocks from", required: false
    def show_last_by_day(conn, %{"userID" => userID, "last_day" => last_day}) do
      last_day = String.to_integer(last_day)
      case Clocks.get_last_clock_for_user_by_day(userID, NaiveDateTime.add(DateTime.utc_now(), -last_day, :day)) do
        [] ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "No clock records found"})
        clocks ->
          conn
          |> put_status(:ok)
          |> json(%{clocks: clocks})
      end
    end

  # Get the last clock for a user
  swagger_path :show_last do
    get "/api/clocks/{userID}/last"
    description "Get the last clock information for a specific user."
    parameter :userID, :path, :string, "The ID of the user whose last clock you want to retrieve", required: true
    response 200, "Success", Schema.ref(:Clock)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show_last(conn, %{"userID" => userID}) do
    case Clocks.get_last_clock_for_user(userID) do
      [] ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No clock records found"})
      clocks ->
        conn
        |> put_status(:ok)
        |> json(%{clocks: clocks})
    end
  end

  # Create Manager
  swagger_path :create do
    post "/api/clocks/{userID}"
    description "Clock in for a specific user."
    parameter :userID, :path, :string, "The ID of the user to clock in", required: true
    response 201, "Created", Schema.ref(:Clock)
    response 400, "Bad Request", Schema.ref(:Error)
  end

  def create(conn, %{"userID" => userID}) do
    case Clocks.clock_in(userID) do
      {:ok, clock} ->
        conn
        |> put_status(:created)
        |> json(%{message: "Clock in successful", clock: clock})
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      Clock: swagger_schema do
        title "Clock"
        description "A clock record for a user"
        properties do
          id :integer, "Clock ID"
          user_id :string, "The ID of the user associated with this clock"
          clock_in_time :string, "The timestamp when the user clocked in", format: :date_time
          clock_out_time :string, "The timestamp when the user clocked out", format: :date_time
        end
        example %{
          id: 1,
          user_id: "12",
          clock_in_time: "2023-10-08T14:30:00Z",
          clock_out_time: "2023-10-08T18:00:00Z"
        }
      end,
      Error: swagger_schema do
        title "Error"
        description "An error response"
        properties do
          error :string, "Error message describing what went wrong"
        end
        example %{
          error: "No clock records found"
        }
      end
    }
  end
end
