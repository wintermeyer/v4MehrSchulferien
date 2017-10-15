defmodule MehrSchulferienWeb.LocationSchoolController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.School
  import Ecto.Query

  # /countries/:country_id/schools
  #
  def index(conn, %{"country_id" => country_id}) do
    country = Locations.get_country!(country_id)

    query = from schools in School,
            where: schools.country_id == ^country.id,
            order_by: [schools.name, schools.address_zip_code],
            select: {schools.address_zip_code, schools.name, schools.slug}
    schools = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index_country_schools.html", schools: schools,
                                               federal_states: federal_states,
                                               country: country)
  end


  # /federal_states/:federal_state_id/schools
  #
  def index(conn, %{"federal_state_id" => federal_state_id}) do
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)
  
    query = from schools in School,
            where: schools.federal_state_id == ^federal_state.id,
            order_by: [schools.name, schools.address_zip_code],
            select: {schools.address_zip_code, schools.name, schools.slug}
    schools = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index_federal_state_schools.html", schools: schools,
                                              federal_states: federal_states,
                                              federal_state: federal_state,
                                              country: country)
  end

end
