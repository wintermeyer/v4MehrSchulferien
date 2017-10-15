defmodule MehrSchulferienWeb.LocationCityController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  import Ecto.Query

  # /countries/:country_id/cities
  #
  def index(conn, %{"country_id" => country_id}) do
    country = Locations.get_country!(country_id)

    query = from cities in City,
            where: cities.country_id == ^country.id,
            order_by: [cities.name, cities.zip_code],
            select: {cities.zip_code, cities.name, cities.slug}
    cities = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index_country_cities.html", cities: cities,
                                              federal_states: federal_states,
                                              country: country)
  end


  # /federal_states/:federal_state_id/cities
  #
  def index(conn, %{"federal_state_id" => federal_state_id}) do
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

    query = from cities in City,
            where: cities.federal_state_id == ^federal_state.id,
            order_by: [cities.name, cities.zip_code],
            select: {cities.zip_code, cities.name, cities.slug}
    cities = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index_federal_state_cities.html", cities: cities,
                                              federal_states: federal_states,
                                              federal_state: federal_state,
                                              country: country)
  end

end
