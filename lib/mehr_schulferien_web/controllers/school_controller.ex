defmodule MehrSchulferienWeb.SchoolController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.School
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Timetables.Year
  alias MehrSchulferien.Repo
  import Ecto.Query

  def index(conn, _params) do
    schools = Locations.list_schools()
    render(conn, "index.html", schools: schools)
  end

  def new(conn, _params) do
    changeset = Locations.change_school(%School{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"school" => school_params}) do
    case Locations.create_school(school_params) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "School created successfully.")
        |> redirect(to: school_path(conn, :show, school))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    school = Locations.get_school!(id)
    city = Locations.get_city!(school.city_id)
    federal_state = Locations.get_federal_state!(school.federal_state_id)
    country = Locations.get_country!(school.country_id)

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    nearby_schools = Locations.nearby_schools(school)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)
    months = MehrSchulferien.Collect.calendar_ready_months([school, city, federal_state, country], starts_on, ends_on)

    includes_bewegliche_ferientage_of_other_schools =
      case MehrSchulferien.Collect.includes_bewegliche_ferientage?([school]) do
        true -> false
        false ->
          if bewegliche_ferientage != nil and bewegliche_ferientage.value > 0 do
            true
          else
            false
          end
      end

    render(conn, "show_next_12_months.html", school: school,
                                          year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          nearby_schools: nearby_schools,
                                          includes_bewegliche_ferientage_of_other_schools: includes_bewegliche_ferientage_of_other_schools
                                          )
  end

  def edit(conn, %{"id" => id}) do
    school = Locations.get_school!(id)
    changeset = Locations.change_school(school)
    render(conn, "edit.html", school: school, changeset: changeset)
  end

  def update(conn, %{"id" => id, "school" => school_params}) do
    school = Locations.get_school!(id)

    case Locations.update_school(school, school_params) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "School updated successfully.")
        |> redirect(to: school_path(conn, :show, school))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", school: school, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    school = Locations.get_school!(id)
    {:ok, _school} = Locations.delete_school(school)

    conn
    |> put_flash(:info, "School deleted successfully.")
    |> redirect(to: school_path(conn, :index))
  end
end
