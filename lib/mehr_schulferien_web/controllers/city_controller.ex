defmodule MehrSchulferienWeb.CityController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Repo
  import Ecto.Query

  def index(conn, _params) do
    query = from cities in City,
            order_by: [cities.name, cities.zip_code],
            select: {cities.zip_code, cities.name, cities.slug}
    cities = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index.html", cities: cities, federal_states: federal_states)
  end

  def new(conn, _params) do
    changeset = Locations.change_city(%City{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"city" => city_params}) do
    case Locations.create_city(city_params) do
      {:ok, city} ->
        conn
        |> put_flash(:info, "City created successfully.")
        |> redirect(to: city_path(conn, :show, city))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    city = Locations.get_city!(id)
    render(conn, "show.html", city: city)
  end

  def edit(conn, %{"id" => id}) do
    city = Locations.get_city!(id)
    changeset = Locations.change_city(city)
    render(conn, "edit.html", city: city, changeset: changeset)
  end

  def update(conn, %{"id" => id, "city" => city_params}) do
    city = Locations.get_city!(id)

    case Locations.update_city(city, city_params) do
      {:ok, city} ->
        conn
        |> put_flash(:info, "City updated successfully.")
        |> redirect(to: city_path(conn, :show, city))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", city: city, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    city = Locations.get_city!(id)
    {:ok, _city} = Locations.delete_city(city)

    conn
    |> put_flash(:info, "City deleted successfully.")
    |> redirect(to: city_path(conn, :index))
  end
end
