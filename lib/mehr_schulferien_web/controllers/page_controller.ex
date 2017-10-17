defmodule MehrSchulferienWeb.PageController do
  use MehrSchulferienWeb, :controller
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Timetables

  def index(conn, _params) do
    year = Timetables.get_year!(DateTime.utc_now |> Map.fetch!(:year))
    federal_states = MehrSchulferien.Locations.list_federal_states
    schools = Locations.list_schools
    country = Locations.get_country!("deutschland")

    {:ok, starts_on} = Date.from_erl({year.value, DateTime.utc_now |> Map.fetch!(:month), 1})
    ends_on = Date.add(starts_on, 360)
    months = MehrSchulferien.Collect.calendar_ready_months( List.flatten([schools, federal_states, country]), starts_on, ends_on)

    # render(conn, "show_next_12_months.html", school: school,
    #                                       year: year,
    #                                       country: country,
    #                                       city: city,
    #                                       federal_state: federal_state,
    #                                       months: months,
    #                                       bewegliche_ferientage: bewegliche_ferientage,
    #                                       nearby_schools: nearby_schools,
    #                                       includes_bewegliche_ferientage_of_other_schools: includes_bewegliche_ferientage_of_other_schools,
    #                                       available_religions: available_religions
    #                                       )



    render(conn, "index.html",
           federal_states: federal_states,
           year: year,
           months: months
          )
  end
end
