defmodule MehrSchulferienWeb.ReligionController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Users
  alias MehrSchulferien.Users.Religion

  def index(conn, _params) do
    religions = Users.list_religions()
    render(conn, "index.html", religions: religions)
  end

  def new(conn, _params) do
    changeset = Users.change_religion(%Religion{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"religion" => religion_params}) do
    case Users.create_religion(religion_params) do
      {:ok, religion} ->
        conn
        |> put_flash(:info, "Religion created successfully.")
        |> redirect(to: religion_path(conn, :show, religion))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    religion = Users.get_religion!(id)
    render(conn, "show.html", religion: religion)
  end

  def edit(conn, %{"id" => id}) do
    religion = Users.get_religion!(id)
    changeset = Users.change_religion(religion)
    render(conn, "edit.html", religion: religion, changeset: changeset)
  end

  def update(conn, %{"id" => id, "religion" => religion_params}) do
    religion = Users.get_religion!(id)

    case Users.update_religion(religion, religion_params) do
      {:ok, religion} ->
        conn
        |> put_flash(:info, "Religion updated successfully.")
        |> redirect(to: religion_path(conn, :show, religion))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", religion: religion, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    religion = Users.get_religion!(id)
    {:ok, _religion} = Users.delete_religion(religion)

    conn
    |> put_flash(:info, "Religion deleted successfully.")
    |> redirect(to: religion_path(conn, :index))
  end
end
