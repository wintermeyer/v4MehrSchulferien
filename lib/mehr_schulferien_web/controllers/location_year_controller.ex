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

    federal_states = Locations.list_federal_states

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on)

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

    render(conn, "show_federal_state_year.html", year: year,
                                         country: country,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         includes_bewegliche_ferientage_of_other_schools: true,
                                         available_religions: available_religions)
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

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

    render(conn, "show_school_year.html", school: school,
                                          year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          country: country,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          nearby_schools: nearby_schools,
                                          available_religions: available_religions,
                                          includes_bewegliche_ferientage_of_other_schools: includes_bewegliche_ferientage_of_other_schools
                                          )
  end

  # /cities/:city_id/years/:id
  #
  def show(conn, %{"id" => id, "city_id" => city_id}) do
    year = Timetables.get_year!(id)
    city = Locations.get_city!(city_id)
    federal_state = Locations.get_federal_state!(city.federal_state_id)
    federal_states = Locations.list_federal_states
    country = Locations.get_country!(city.country_id)

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    query = from schools in Locations.School,
            where: schools.city_id == ^city.id,
            order_by: schools.name
    schools = Repo.all(query)

    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})
    months = MehrSchulferien.Collect.calendar_ready_months([city, federal_state, country], starts_on, ends_on)

    render(conn, "show_city_year.html", year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          federal_states: federal_states,
                                          country: country,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          includes_bewegliche_ferientage_of_other_schools: true,
                                          schools: schools
                                          )
  end
end
