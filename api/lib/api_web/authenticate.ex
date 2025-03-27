defmodule ApiWeb.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  alias ApiWeb.Token

  def init(default), do: default

  def call(conn, _default) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Token.verify_token(token) do
      assign(conn, :user_id, claims["user_id"])
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end
end
