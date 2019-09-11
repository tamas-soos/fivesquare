defmodule FivesquareWeb.UserController do
  use FivesquareWeb, :controller

  alias Fivesquare.Accounts
  alias Fivesquare.Accounts.User

  alias FivesquareWeb.SessionView
  alias FivesquareWeb.Guardian

  action_fallback FivesquareWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    # FIXME create -> <- sign_up ???
    case Accounts.signup_user(user_params) do
      {:ok, %User{} = user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:created)
        |> render(SessionView, "show.json", jwt: jwt, user: user)

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        # FIXME display changeset error messages
        |> render(SessionView, "error.json")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end