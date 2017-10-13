defmodule MehrSchulferienWeb.LocationYearController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Locations.School
  alias MehrSchulferien.Timetables.Year
  import Ecto.Query

  # /federal_states/:federal_state_id/years/:id
  #
  def show(conn, %{"id" => id, "federal_state_id" => federal_state_id}) do
    year = Timetables.get_year!(id)
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

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

    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on)

    render(conn, "show_federal_state_year.html", year: year,
                                         federal_state: federal_state,
                                         cities: cities,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         schools: schools)
  end

  # /schools/:school_id/years/:id
  #
  def show(conn, %{"id" => id, "school_id" => school_id}) do
    year = Timetables.get_year!(id)
    school = Locations.get_school!(school_id)
    city = Locations.get_city!(school.city_id)
    federal_state = Locations.get_federal_state!(school.federal_state_id)
    country = Locations.get_country!(school.country_id)

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    nearby_schools = Locations.nearby_schools(school)

    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})
    months = MehrSchulferien.Collect.calendar_ready_months([school, city, federal_state, country], starts_on, ends_on)

    render(conn, "show_school_year.html", school: school,
                                          year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          nearby_schools: nearby_schools)
  end

end
