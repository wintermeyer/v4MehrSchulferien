defmodule MehrSchulferienWeb.YearController do
  use MehrSchulferienWeb, :controller

  alias MehrSchulferien.Repo
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Timetables.Year
  import Ecto.Query


  def index(conn, _params) do
    years = Timetables.list_years()
    render(conn, "index.html", years: years)
  end

  def new(conn, _params) do
    changeset = Timetables.change_year(%Year{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"year" => year_params}) do
    case Timetables.create_year(year_params) do
      {:ok, year} ->
        conn
        |> put_flash(:info, "Year created successfully.")
        |> redirect(to: year_path(conn, :show, year))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "federal_state_id" => federal_state_id}) do
    year = Timetables.get_year!(id)
    federal_state = Locations.get_federal_state!(federal_state_id)
    country = Locations.get_country!(federal_state.country_id)

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
      case school_count do
        x when x > 0 ->
          {zip_code <> " " <> name <> " (" <> Integer.to_string(school_count) <> ")", slug}
        _ -> nil
      end
    end

    {:ok, starts_on} = Date.from_erl({year.value, 1, 1})
    {:ok, ends_on} = Date.from_erl({year.value, 12, 31})

    months = MehrSchulferien.Collect.calendar_ready_months([federal_state, country], starts_on, ends_on)

    render(conn, "show-timeperiod.html", year: year,
                                         federal_state: federal_state,
                                         cities: cities,
                                         months: months)
  end

  def show(conn, %{"id" => id}) do
    year = Timetables.get_year!(id)
    render(conn, "show.html", year: year)
  end

  def edit(conn, %{"id" => id}) do
    year = Timetables.get_year!(id)
    changeset = Timetables.change_year(year)
    render(conn, "edit.html", year: year, changeset: changeset)
  end

  def update(conn, %{"id" => id, "year" => year_params}) do
    year = Timetables.get_year!(id)

    case Timetables.update_year(year, year_params) do
      {:ok, year} ->
        conn
        |> put_flash(:info, "Year updated successfully.")
        |> redirect(to: year_path(conn, :show, year))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", year: year, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    year = Timetables.get_year!(id)
    {:ok, _year} = Timetables.delete_year(year)

    conn
    |> put_flash(:info, "Year deleted successfully.")
    |> redirect(to: year_path(conn, :index))
  end
end
