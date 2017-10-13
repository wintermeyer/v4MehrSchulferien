defmodule MehrSchulferien.Collect do
  alias MehrSchulferien.Timetables
  alias MehrSchulferien.Locations
  alias MehrSchulferien.Repo
  alias MehrSchulferien.Timetables.Day
  alias MehrSchulferien.Timetables.Slot
  alias MehrSchulferien.Timetables.Period
  alias MehrSchulferien.Locations.Country
  alias MehrSchulferien.Locations.FederalState
  alias MehrSchulferien.Locations.City
  alias MehrSchulferien.Locations.School
  import Ecto.Query, warn: false

  def calendar_ready_months(locations \\ [], starts_on \\ nil, ends_on \\ nil, religions \\ [MehrSchulferien.Users.get_religion!("keine")]) do
    {starts_on, ends_on} = current_year_if_nil(starts_on, ends_on)
    {starts_on, ends_on} = make_sure_its_a_full_month(starts_on, ends_on)

    days = render_ready_days(locations, starts_on, ends_on)
           |> chunk_days_to_months
           |> prepare_list_of_months_to_be_displayed
           |> convert_to_maps
           |> inject_summary_list_by_category("Schulferien", :school_vacation_periods)
           |> inject_summary_list_by_category("Gesetzlicher Feiertag", :bank_holiday_periods)
           |> inject_summary_list_by_category("Beweglicher Ferientag", :beweglicher_ferientag_periods)
  end

  def chunk_days_to_months(days) do
    days |> Enum.chunk_by(fn %{value: %{year: year, month: month}} -> {year, month} end)
  end

  def prepare_list_of_months_to_be_displayed(months) do
    for month <- months do
      prepare_days_of_a_month_to_be_displayed(month)
    end
  end

  def prepare_days_of_a_month_to_be_displayed(days) do
    # Fill days with empty elements for the calendar blanks in
    # the first and last line of it.
    #
    head_fill = case List.first(days)[:weekday] do
      1 -> nil
      2 -> [{}]
      3 -> [{},{}]
      4 -> [{},{},{}]
      5 -> [{},{},{},{}]
      6 -> [{},{},{},{},{}]
      7 -> [{},{},{},{},{},{}]
    end

    tail_fill = case List.last(days)[:weekday] do
      7 -> nil
      6 -> [{}]
      5 -> [{},{}]
      4 -> [{},{},{}]
      3 -> [{},{},{},{}]
      2 -> [{},{},{},{},{}]
      1 -> [{},{},{},{},{},{}]
    end

    days = case {head_fill, tail_fill} do
      {nil, nil} -> days
      {nil, _} -> Enum.concat(days, tail_fill)
      {_, nil} -> Enum.concat(head_fill, days)
      {_, _} -> Enum.concat(Enum.concat(head_fill, days), tail_fill)
    end

    Enum.chunk_every(days, 7)
  end

  def convert_to_maps(months) do
    for month <- months do
      %{month: month}
    end
  end

  def render_ready_days(locations \\ [], starts_on \\ nil, ends_on \\ nil, religions \\ [MehrSchulferien.Users.get_religion!("keine")]) do
    list_days(locations, starts_on, ends_on)
    |> Enum.group_by(fn {date, _, _, _, _, _} -> date end, fn {_, period, country, federal_state, city, school} -> {period, country, federal_state, city, school} end)
    |> Enum.map(fn {date, periods} -> date
      |> Map.put(:periods, Enum.reject(periods, fn(x) -> x == {nil, nil, nil, nil, nil} end)) end)
    |> Enum.sort_by(fn x -> Date.to_string(x[:value]) end)
    |> inject_css_class
  end

  def list_days(locations \\ [], starts_on \\ nil, ends_on \\ nil, religions \\ [MehrSchulferien.Users.get_religion!("keine")]) do
    {starts_on, ends_on} = current_year_if_nil(starts_on, ends_on)

    country_ids = for %MehrSchulferien.Locations.Country{id: id} <- locations, do: id
    federal_state_ids = for %MehrSchulferien.Locations.FederalState{id: id} <- locations, do: id
    city_ids = for %MehrSchulferien.Locations.City{id: id} <- locations, do: id
    school_ids = for %MehrSchulferien.Locations.School{id: id} <- locations, do: id
    religion_ids = for %MehrSchulferien.Users.Religion{id: id} <- religions, do: id

    query = from(
                days in Day,
                left_join: slots in Slot,
                on: days.id == slots.day_id,
                left_join: periods in Period,
                on: slots.period_id == periods.id and
                    (periods.country_id in ^country_ids or
                     periods.federal_state_id in ^federal_state_ids or
                     periods.city_id in ^city_ids or
                     periods.school_id in ^school_ids) and
                     periods.religion_id in ^religion_ids,
                left_join: country in Country,
                on:  periods.country_id == country.id,
                left_join: federal_state in FederalState,
                on:  periods.federal_state_id == federal_state.id,
                left_join: city in City,
                on:  periods.city_id == city.id,
                left_join: school in School,
                on:  periods.school_id == school.id,
                where: days.value >= ^starts_on and
                      days.value <= ^ends_on,
                order_by: days.value,
                select: {map(days, [:value, :value, :weekday]),
                        map(periods, [:id, :name, :slug, :category, :starts_on, :ends_on]),
                        map(country, [:id, :name, :slug]),
                        map(federal_state, [:id, :name, :slug]),
                        map(city, [:id, :name, :slug]),
                        map(school, [:id, :name, :slug])
                      }
                )
    Repo.all(query) |> Enum.uniq
  end

  defp current_year_if_nil(starts_on, ends_on) do
    case {starts_on, ends_on} do
      {nil, _} ->
        {:ok, starts_on} = Date.from_erl({Date.utc_today.year, 1, 1})
        {:ok, ends_on} = Date.from_erl({Date.utc_today.year, 12, 31})
        {starts_on, ends_on}
      {_, nil} ->
        {:ok, ends_on} = Date.from_erl({Date.utc_today.year, 12, 31})
        {starts_on, ends_on}
      {_, _} ->
        {starts_on, ends_on}
    end
  end

  defp inject_css_class(days) do
    for day <- days do
      categories = for {period_data, country, federal_state, city, school} <- day.periods do
        period_data.category
      end |> List.flatten

      css_class = case {
             Enum.member?(categories, "Wochenende"),
             Enum.member?(categories, "Schulferien"),
             Enum.member?(categories, "Gesetzlicher Feiertag"),
             Enum.member?(categories, "Beweglicher Ferientag"),
             Enum.member?(categories, "Religiöser Feiertag")
           } do
        # I just use the default TwitterBootstrap class names. No judgement.
        #
        {_, _, _, _, true} -> "danger"
        {_, _, _, true, _} -> "warning"
        {_, _, true, _, _} -> "info"
        {_, true, _, _, _} -> "success"
        {true, _, _, _, _} -> "active"
        {_, _, _, _, _} -> ""
      end

      Map.put_new(day, :css_class, css_class)
    end
  end

  defp make_sure_its_a_full_month(starts_on, ends_on) do
    {:ok, starts_on} = Date.from_erl({starts_on.year, starts_on.month, 1})
    {:ok, ends_on} = case {ends_on.month, Date.leap_year?(ends_on)} do
      {1, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {2, false} -> Date.from_erl({ends_on.year, ends_on.month, 28})
      {2, true} -> Date.from_erl({ends_on.year, ends_on.month, 29})
      {3, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {4, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {5, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {6, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {7, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {8, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {9, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {10, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
      {11, _} -> Date.from_erl({ends_on.year, ends_on.month, 30})
      {12, _} -> Date.from_erl({ends_on.year, ends_on.month, 31})
    end
    {starts_on, ends_on}
  end

  # collect all vacations, bank_holidays or what ever and inject them
  #
  def inject_summary_list_by_category(months, category_name, key_name) do
    for month <- months do
      periods =
        for week <- month[:month] do
          for day <- week do
            unless day == {} do
              for {%{category: ^category_name, ends_on: ends_on, id: id,
                     name: name, slug: slug,
                     starts_on: starts_on},_,_,_,_} <- day[:periods] do
                length = Date.diff(ends_on, starts_on) + 1
                %{category: category_name, ends_on: ends_on, id: id,
                  name: name, slug: slug, starts_on: starts_on, length: length}
              end
            end
          end
        end |> List.flatten |> Enum.uniq |> Enum.filter(& !is_nil(&1))

      Map.put_new(month, key_name, periods)
    end
  end

end
