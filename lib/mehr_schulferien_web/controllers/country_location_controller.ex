defmodule MehrSchulferienWeb.CountryLocationController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  import Ecto.Query

  # /countries/:country_id/cities
  #
  def index(conn, %{"country_id" => country_id}) do
    query = from cities in City,
            order_by: [cities.name, cities.zip_code],
            select: {cities.zip_code, cities.name, cities.slug}
    cities = Repo.all(query)

    federal_states = Locations.list_federal_states

    render(conn, "index_country_cities.html", cities: cities, federal_states: federal_states)
  end


end
