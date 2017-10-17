defmodule MehrSchulferienWeb.LocationReligionController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Users
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Locations.School
  alias MehrSchulferien.Timetables.Year
  import Ecto.Query

  # /federal_states/:federal_state_id/religions/:id
  #
  def show(conn, %{"id" => id, "federal_state_id" => federal_state_id}) do
    religion = Users.get_religion!(id)
    keine_religion = Users.get_religion!("keine")
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

    federal_states = Locations.list_federal_states

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on, [religion, keine_religion])

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

    render(conn, "show_federal_state_religion.html", year: year,
                                         country: country,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         includes_bewegliche_ferientage_of_other_schools: true,
                                         religion: religion,
                                         available_religions: available_religions)
  end

  # /schools/:school_id/religions/:id
  #
  def show(conn, %{"id" => id, "school_id" => school_id}) do
    religion = Users.get_religion!(id)
    keine_religion = Users.get_religion!("keine")
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    school = Locations.get_school!(school_id)
    city = Locations.get_city!(school.city_id)
    federal_state = Locations.get_federal_state!(school.federal_state_id)
    country = Locations.get_country!(school.country_id)

    nearby_schools = Locations.nearby_schools(school)

    query = from bewegliche_ferientage in Timetables.BeweglicherFerientag,
            where: bewegliche_ferientage.federal_state_id == ^federal_state.id and
            bewegliche_ferientage.year_id == ^year.id
    bewegliche_ferientage = Repo.one(query)

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on, [religion, keine_religion])

    query = from religion in MehrSchulferien.Users.Religion,
            where: religion.name in ["Jüdisch", "Islamisch"]
    available_religions = Repo.all(query)

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

    render(conn, "show_school_religion.html", school: school,
                                          year: year,
                                          city: city,
                                          federal_state: federal_state,
                                          country: country,
                                          months: months,
                                          bewegliche_ferientage: bewegliche_ferientage,
                                          nearby_schools: nearby_schools,
                                          religion: religion,
                                          available_religions: available_religions,
                                          includes_bewegliche_ferientage_of_other_schools: includes_bewegliche_ferientage_of_other_schools
                                          )
  end


end
