defmodule MehrSchulferienWeb.FederalStateController do
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
    federal_states = Locations.list_federal_states()
    render(conn, "index.html", federal_states: federal_states)
  end

  def new(conn, _params) do
    changeset = Locations.change_federal_state(%FederalState{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"federal_state" => federal_state_params}) do
    case Locations.create_federal_state(federal_state_params) do
      {:ok, federal_state} ->
        conn
        |> put_flash(:info, "Federal state created successfully.")
        |> redirect(to: federal_state_path(conn, :show, federal_state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    federal_state = Locations.get_federal_state!(id)
    country = Locations.get_country!(federal_state.country_id)

    federal_states = Locations.list_federal_states

    # TODO: get the cities with preload when fetching federal_state
    query = from cities in City,
            where: cities.federal_state_id == ^federal_state.id,
            order_by: [cities.name, cities.zip_code],
            select: {cities.zip_code, cities.name, cities.slug}
    cities = Repo.all(query)

    # TODO: get the schools with preload when fetching federal_state
    query = from schools in School,
            where: schools.federal_state_id == ^federal_state.id,
            order_by: schools.name,
            select: {schools.address_zip_code, schools.name, schools.slug, schools.address_city}
    schools = Repo.all(query)

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on)

    render(conn, "show_federal_state_next_12_months.html", year: year,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         cities: cities,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         schools: schools)
  end

  def edit(conn, %{"id" => id}) do
    federal_state = Locations.get_federal_state!(id)
    changeset = Locations.change_federal_state(federal_state)
    render(conn, "edit.html", federal_state: federal_state, changeset: changeset)
  end

  def update(conn, %{"id" => id, "federal_state" => federal_state_params}) do
    federal_state = Locations.get_federal_state!(id)

    case Locations.update_federal_state(federal_state, federal_state_params) do
      {:ok, federal_state} ->
        conn
        |> put_flash(:info, "Federal state updated successfully.")
        |> redirect(to: federal_state_path(conn, :show, federal_state))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", federal_state: federal_state, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    federal_state = Locations.get_federal_state!(id)
    {:ok, _federal_state} = Locations.delete_federal_state(federal_state)

    conn
    |> put_flash(:info, "Federal state deleted successfully.")
    |> redirect(to: federal_state_path(conn, :index))
  end
end
