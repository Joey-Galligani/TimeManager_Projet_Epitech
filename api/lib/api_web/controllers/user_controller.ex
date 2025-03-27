defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use PhoenixSwagger, except: [delete: 2]

  alias Api.Users
  alias Api.UserEmail

  # List Users
  swagger_path :index do
    get "/api/users"
    description "Get all user."
    response 200, "Success", Schema.array(:User)
  end

  def index(conn, _params) do
    users = Users.get_all_users()
    json(conn, users)
  end

  # Show User
  swagger_path :show do
    get "/api/users/{userID}"
    description "Get details of a specific user by user ID."
    parameter :userID, :path, :string, "The ID of the user to retrieve", required: true
    response 200, "Success", Schema.ref(:User)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show(conn, %{"userID" => userID}) do
    user = Users.get_user!(userID)
    json(conn, user)
  end

  # Get by user email
  swagger_path :show_email do
    get "/api/users/by_email?email={email}"
    description "Get details of a specific user by email."
    parameter :email, :path, :string, "The email of the user to retrieve", required: true
    response 200, "Success", Schema.ref(:User)
    response 404, "Not Found", Schema.ref(:Error)
  end

  def show_email(conn, %{"email" => email}) do
    user = Users.get_user_by_email(email)
    json(conn, user)
  end

  # Create User
  swagger_path :create do
    post "/api/users"
    description "Create a new user."
    parameter :user, :body, Schema.ref(:UserRequest), "The user details to create", required: true
    response 201, "Created", Schema.ref(:User)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{user: user})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)})
    end
  end

  # Send an email with a reset key to a user
  def send_reset_key(conn, %{"email" => recipient_email, "key" => key}) do
    # Build the email using the UserEmail module
    email_struct = UserEmail.reset_key_email(recipient_email, key)
    IO.inspect(email_struct, label: "Email Struct")

    # Send the email using the Mailer module
    case Api.Mailer.deliver(email_struct) do
      {:ok, _result} ->
        json(conn, %{message: "Reset key sent to #{recipient_email}"})

      {:error, reason} ->
        IO.inspect(reason, label: "Mailer Error")
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to send email", reason: inspect(reason)})
    end
  end


  # Update User
  swagger_path :update do
    put "/api/users/{userID}"
    description "Update an existing user's details."
    parameter :userID, :path, :string, "The ID of the user to update", required: true
    parameter :user, :body, Schema.ref(:UserRequest), "The user details to update", required: true
    response 200, "Success", Schema.ref(:User)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def update(conn, %{"userID" => userID, "user" => user_params}) do
    case Users.update_user(userID, user_params) do
      {:ok, user} -> json(conn, user)
      {:error, changeset} -> json(conn, changeset)
    end
  end

  # Delete User
  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/users/{userID}"
    description "Delete a user by user ID."
    parameter :userID, :path, :string, "The ID of the user to delete", required: true
    response 204, "No Content"
    response 400, "Bad Request", Schema.ref(:Error)
  end

  def delete(conn, %{"userID" => userID}) do
    case Users.delete_user(userID) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> send_resp(conn, :bad_request, "Unable to delete user")
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      User: swagger_schema do
        title "User"
        description "A user in the system"
        properties do
          id :integer, "User ID"
          username :string, "The user's username"
          email :string, "The user's email address"
          inserted_at :string, "When the user was created", format: :date_time
          updated_at :string, "When the user was last updated", format: :date_time
        end
        example %{
          id: 1,
          username: "john_doe",
          email: "john.doe@example.com",
          inserted_at: "2023-10-08T14:30:00Z",
          updated_at: "2023-10-08T18:00:00Z"
        }
      end,
      UserRequest: swagger_schema do
        title "User Request"
        description "Parameters required to create or update a user"
        properties do
          username :string, "The user's username", required: true
          email :string, "The user's email address", required: true
          password :string, "The user's password", required: true
        end
        example %{
          user: %{
            email: "john.doe@example.com",
            username: "john_doe"
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
          error: "User not found"
        }
      end
    }
  end
end
