defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Api.Users
  alias ApiWeb.Token

  # Swagger Documentation for Register Endpoint
  swagger_path :register do
    post "/api/register"
    description "Register a new user."
    parameter :user, :body, Schema.ref(:UserRegistration), "The user registration details", required: true
    response 201, "Created", Schema.ref(:UserResponse)
    response 422, "Unprocessable Entity", Schema.ref(:ErrorResponse)
  end

  def register(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_status(:created)
        |> json(%{message: "User registered successfully"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  # Swagger Documentation for Login Endpoint
  swagger_path :login do
    post "/api/login"
    description "Login a user."
    parameter :user, :body, Schema.ref(:UserLogin), "The user login details", required: true
    response 200, "OK", Schema.ref(:LoginResponse)
    response 401, "Unauthorized", Schema.ref(:ErrorResponse)
  end

  def login(conn, %{"user" => %{"email" => email, "non_hashed_password" => password}}) do
    case Users.authenticate_user(email, password) do
      {:ok, user} ->
        token = Token.generate_token(user)
        conn
        |> put_status(:ok)
        |> json(%{token: token})

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  # Swagger Schema Definitions
  def swagger_definitions do
    %{
      UserRegistration: swagger_schema do
        title "User Registration"
        description "Schema for registering a new user"
        properties do
          email :string, "Email address of the user", format: :email, required: true
          non_hashed_password :string, "Password for the user account", required: true
        end
        example %{
          user: %{
            email: "john.doe@example.com",
            non_hashed_password: "securepassword123"
          }
        }
      end,
      UserLogin: swagger_schema do
        title "User Login"
        description "Schema for logging in a user"
        properties do
          email :string, "Email address of the user", format: :email, required: true
          non_hashed_password :string, "Password for the user account", required: true
        end
        example %{
          user: %{
            email: "john.doe@example.com",
            non_hashed_password: "securepassword123"
          }
        }
      end,
      UserResponse: swagger_schema do
        title "User Response"
        description "Response for a successful user registration"
        properties do
          message :string, "Success message"
        end
        example %{
          message: "User registered successfully"
        }
      end,
      LoginResponse: swagger_schema do
        title "Login Response"
        description "Response for a successful user login"
        properties do
          token :string, "JWT token for the authenticated user"
        end
        example %{
          token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
      end,
      ErrorResponse: swagger_schema do
        title "Error Response"
        description "Response when an error occurs during user registration or login"
        properties do
          errors :object, "Errors describing why the registration or login failed"
        end
        example %{
          errors: %{email: ["has already been taken"], password: ["is too short"]}
        }
      end
    }
  end
end
