defmodule MehrSchulferienWeb.LocationYearController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Timetables.Year
  import Ecto.Query


  def show(conn, %{"id" => id, "federal_state_id" => federal_state_id}) do
    year = Timetables.get_year!(id)
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

    # TODO: get the cities with preload when fetching federal_state
    query = from cities in City,
            where: cities.federal_state_id == ^federal_state.id,
            left_join: schools in Locations.School,
            on: schools.city_id == cities.id,
            group_by: cities.id,
            order_by: [cities.name, cities.zip_code],
            select: {cities.name, cities.zip_code, cities.slug, count(schools.id)}
    raw_cities = Repo.all(query)

    cities = for city <- raw_cities do
      {name, zip_code, slug, school_count} = city
      {zip_code, name, slug, school_count}

      # {name, zip_code, slug, school_count} = city
      # case school_count do
      #   x when x > 0 ->
      #     {zip_code <> " " <> name <> " (" <> Integer.to_string(school_count) <> ")", slug}
      #   _ -> nil
      # end
    end

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
                                         bewegliche_ferientage: bewegliche_ferientage)
  end

end
