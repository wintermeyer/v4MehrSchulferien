defmodule MehrSchulferienWeb.CityController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.FederalState
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Locations.School
  alias MehrSchulferien.Timetables.Year
  import Ecto.Query

  def index(conn, _params) do
    cities = Locations.list_cities
    render(conn, "index.html", cities: cities)
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
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    federal_state = Locations.get_federal_state!(city.federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

    federal_states = Locations.list_federal_states

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    query = from schools in Locations.School,
            where: schools.city_id == ^city.id,
            order_by: schools.name
    schools = Repo.all(query)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)

    months = MehrSchulferien.Collect.calendar_ready_months([city, federal_state, country], starts_on, ends_on)

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

    render(conn, "show_city_next_12_months.html", year: year,
                                         city: city,
                                         country: country,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         includes_bewegliche_ferientage_of_other_schools: true,
                                         schools: schools,
                                         available_religions: available_religions
                                         )
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
