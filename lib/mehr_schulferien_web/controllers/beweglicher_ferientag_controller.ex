defmodule MehrSchulferienWeb.BeweglicherFerientagController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Timetables.BeweglicherFerientag

  def index(conn, _params) do
    bewegliche_ferientage = Timetables.list_bewegliche_ferientage()
    render(conn, "index.html", bewegliche_ferientage: bewegliche_ferientage)
  end

  def new(conn, _params) do
    changeset = Timetables.change_beweglicher_ferientag(%BeweglicherFerientag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"beweglicher_ferientag" => beweglicher_ferientag_params}) do
    case Timetables.create_beweglicher_ferientag(beweglicher_ferientag_params) do
      {:ok, beweglicher_ferientag} ->
        conn
        |> put_flash(:info, "Beweglicher ferientag created successfully.")
        |> redirect(to: beweglicher_ferientag_path(conn, :show, beweglicher_ferientag))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    beweglicher_ferientag = Timetables.get_beweglicher_ferientag!(id)
    render(conn, "show.html", beweglicher_ferientag: beweglicher_ferientag)
  end

  def edit(conn, %{"id" => id}) do
    beweglicher_ferientag = Timetables.get_beweglicher_ferientag!(id)
    changeset = Timetables.change_beweglicher_ferientag(beweglicher_ferientag)
    render(conn, "edit.html", beweglicher_ferientag: beweglicher_ferientag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "beweglicher_ferientag" => beweglicher_ferientag_params}) do
    beweglicher_ferientag = Timetables.get_beweglicher_ferientag!(id)

    case Timetables.update_beweglicher_ferientag(beweglicher_ferientag, beweglicher_ferientag_params) do
      {:ok, beweglicher_ferientag} ->
        conn
        |> put_flash(:info, "Beweglicher ferientag updated successfully.")
        |> redirect(to: beweglicher_ferientag_path(conn, :show, beweglicher_ferientag))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", beweglicher_ferientag: beweglicher_ferientag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    beweglicher_ferientag = Timetables.get_beweglicher_ferientag!(id)
    {:ok, _beweglicher_ferientag} = Timetables.delete_beweglicher_ferientag(beweglicher_ferientag)

    conn
    |> put_flash(:info, "Beweglicher ferientag deleted successfully.")
    |> redirect(to: beweglicher_ferientag_path(conn, :index))
  end
end
