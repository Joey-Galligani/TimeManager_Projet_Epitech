defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiWeb do
    pipe_through :api

    # User routes
    get "/users", UserController, :index  # Get all users
    get "/users/by_email", UserController, :show_email # Get the user using the email address
    get "/users/:userID", UserController, :show  # Get by userID
    post "/users", UserController, :create  # Create a new user
    post "/send_reset_key", UserController, :send_reset_key # Send an email with a reset key to a user
    put "/users/:userID", UserController, :update  # Update user by userID
    delete "/users/:userID", UserController, :delete  # Delete user by userID

    # TimeManager routes
    get "/timeManager/:userID", TimeManagerController, :index  # Get all for a user
    get "/timeManager/:userID/:id", TimeManagerController, :show  # Get a specific working time by ID
    post "/timeManager/:userID", TimeManagerController, :create  # Create working time for user
    put "/timeManager/:id", TimeManagerController, :update  # Update working time by ID
    delete "/timeManager/:id", TimeManagerController, :delete  # Delete working time by ID

    # Clock routes
    get "/clocks/:userID", ClockController, :show  # Get all clocks for user
    get "/clocks/:userID/last", ClockController, :show_last # Get last clock for user
    get "/clocks/:userID/last_by_limit", ClockController, :show_last_by_limit # Get last clock for user by limit
    get "/clocks/:userID/last_by_day", ClockController, :show_last_by_day # Get last clock for user by day
    post "/clocks/:userID", ClockController, :create  # Clock in for user

    # Manager routes
    get "/managers", ManagerController, :index # Get all managers
    get "/managers/:managerID", ManagerController, :show # Get by ID
    post "/managers/:userID", ManagerController, :create # Make a user manager
    delete "/managers/:managerID", ManagerController, :delete # Delete a manager

    # Team routes
    get "/teams", TeamController, :index # Get all teams
    get "/teams/:teamID", TeamController, :show # Get by ID
    post "/teams/:managerID", TeamController, :create # Create a team for a team manager
    put "/teams/:teamID", TeamController, :update # Update team by ID
    delete "/teams/:teamID", TeamController, :delete # Delete team by ID

    # Auth routes
    post "/register", AuthController, :register
    post "/login", AuthController, :login

  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "My API"
      },
    }
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :api, swagger_file: "swagger.json"
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: ApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
