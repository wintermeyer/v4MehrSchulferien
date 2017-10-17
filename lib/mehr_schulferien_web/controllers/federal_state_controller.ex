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
    federal_states = for federal_state <- Locations.list_federal_states do
      cities_counter = Repo.one(from c in City, where: c.federal_state_id == ^federal_state.id, select: count("*"))
      schools_counter = Repo.one(from s in School, where: s.federal_state_id == ^federal_state.id, select: count("*"))
      {federal_state.name, federal_state.slug, cities_counter, schools_counter}
    end

    # query = from federal_states in FederalState,
    #         left_join: cities in City,
    #         on: cities.id == federal_states.id,
    #         group_by: federal_states.id,
    #         select: {federal_states.name, federal_states.slug, count(cities.id)}
    # federal_states = Repo.all(query)

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

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on)

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

    render(conn, "show_federal_state_next_12_months.html", year: year,
                                         country: country,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         includes_bewegliche_ferientage_of_other_schools: true,
                                         available_religions: available_religions
                                         )
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
