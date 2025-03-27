# Api

To start your Phoenix server:

  * Run `mix archive.install hex dotenv` to install the dotenv package (comment `Dotenv.load()` in file `config.exs` if it bugs out and uncomment it after the installation)
  * Run `mix setup` to install and setup dependencies
  * Run `mix deps.get` to install dependencies
  * Change the database configuration in `config/dev.exs`
  * Run `mix ecto.setup` to create, migrate and seed the database
  * Use command `source .env` to load environment variables (create a .env file if it doesn't exist)
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

For CORS Errors see endpoint.ex file at line 18

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
