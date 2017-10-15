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

    render(conn, "show_federal_state_year.html", year: year,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage)
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

    render(conn, "show_school_year.html", school: school,
                                          year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          nearby_schools: nearby_schools,
                                          includes_bewegliche_ferientage_of_other_schools: includes_bewegliche_ferientage_of_other_schools
                                          )
  end

end
