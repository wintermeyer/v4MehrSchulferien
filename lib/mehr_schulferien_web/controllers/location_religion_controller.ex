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

  # /federal_states/:federal_state_id/years/:id
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

    render(conn, "show_federal_state_religion.html", year: year,
                                         country: country,
                                         federal_state: federal_state,
                                         federal_states: federal_states,
                                         months: months,
                                         bewegliche_ferientage: bewegliche_ferientage,
                                         includes_bewegliche_ferientage_of_other_schools: true,
                                         religion: religion)
  end

end
