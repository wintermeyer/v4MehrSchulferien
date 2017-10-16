# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MehrSchulferien.Repo.insert!(%MehrSchulferien.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MehrSchulferien.Locations
alias MehrSchulferien.Timetables
alias MehrSchulferien.Users
import Ecto.Query

# Locations
#
{:ok, deutschland} = Locations.create_country(%{name: "Deutschland"})

# Create the federal states of Germany
#
{:ok, badenwuerttemberg} = Locations.create_federal_state(%{name: "Baden-Württemberg", code: "BW", country_id: deutschland.id})
{:ok, _bayern} = Locations.create_federal_state(%{name: "Bayern", code: "BY", country_id: deutschland.id})
{:ok, _berlin} = Locations.create_federal_state(%{name: "Berlin", code: "BE", country_id: deutschland.id})
{:ok, brandenburg} = Locations.create_federal_state(%{name: "Brandenburg", code: "BB", country_id: deutschland.id})
{:ok, bremen} = Locations.create_federal_state(%{name: "Bremen", code: "HB", country_id: deutschland.id})
{:ok, _hamburg} = Locations.create_federal_state(%{name: "Hamburg", code: "HH", country_id: deutschland.id})
{:ok, hessen} = Locations.create_federal_state(%{name: "Hessen", code: "HE", country_id: deutschland.id})
{:ok, mecklenburgvorpommern} = Locations.create_federal_state(%{name: "Mecklenburg-Vorpommern", code: "MV", country_id: deutschland.id})
{:ok, _niedersachsen} = Locations.create_federal_state(%{name: "Niedersachsen", code: "NI", country_id: deutschland.id})
{:ok, nordrheinwestfalen} = Locations.create_federal_state(%{name: "Nordrhein-Westfalen", code: "NW", country_id: deutschland.id})
{:ok, rheinlandpfalz} = Locations.create_federal_state(%{name: "Rheinland-Pfalz", code: "RP", country_id: deutschland.id})
{:ok, saarland} = Locations.create_federal_state(%{name: "Saarland", code: "SL", country_id: deutschland.id})
{:ok, sachsen} = Locations.create_federal_state(%{name: "Sachsen", code: "SN", country_id: deutschland.id})
{:ok, sachsenanhalt} = Locations.create_federal_state(%{name: "Sachsen-Anhalt", code: "ST", country_id: deutschland.id})
{:ok, schleswigholstein} = Locations.create_federal_state(%{name: "Schleswig-Holstein", code: "SH", country_id: deutschland.id})
{:ok, thueringen} = Locations.create_federal_state(%{name: "Thüringen", code: "TH", country_id: deutschland.id})

# Import cities
#
File.stream!("priv/repo/city-seeds.json") |>
Stream.map( &(String.replace(&1, "\n", "")) ) |>
Stream.with_index |>
Enum.each( fn({contents, line_num}) ->
  city = Poison.decode!(contents)
  federal_state = Locations.get_federal_state!(city["federal_state_slug"])
  country = Locations.get_country!(city["country_slug"])
  Locations.create_city(%{name: city["name"], slug: city["slug"], zip_code: city["zip_code"], country_id: country.id, federal_state_id: federal_state.id})
end)

# Import schools
#
File.stream!("priv/repo/school-seeds.json") |>
Stream.map( &(String.replace(&1, "\n", "")) ) |>
Stream.with_index |>
Enum.each( fn({contents, line_num}) ->
  school = Poison.decode!(contents)
  city = Locations.get_city!(school["city_slug"])
  federal_state = Locations.get_federal_state!(school["federal_state_slug"])
  country = Locations.get_country!(school["country_slug"])
  Locations.create_school(%{name: school["name"], slug: school["slug"],
                            address_zip_code: school["address_zip_code"],
                            address_line1: school["address_line1"],
                            address_line2: school["address_line2"],
                            address_street: school["address_street"],
                            address_zip_code: school["address_zip_code"],
                            address_city: school["address_city"],
                            email_address: school["email_address"],
                            homepage_url: school["homepage_url"],
                            phone_number: school["phone_number"],
                            fax_number: school["fax_number"],
                            city_id: city.id,
                            country_id: country.id,
                            federal_state_id: federal_state.id})
end)

# Religionen
#
{:ok, keine_religion} = Users.create_religion(%{name: "Keine"})
for religion <- ["Katholisch", "Evangelisch", "Jüdisch", "Islamisch"] do
  Users.create_religion(%{name: religion})
end

# Years 2016-2025
#
Enum.each (2016..2025), fn year_number ->
  case Timetables.create_year(%{value: year_number}) do
    {:ok, year} ->
      {:ok, first_day} = Date.from_erl({year_number, 1, 1})
      Enum.each (0..366), fn counter ->
        day = Date.add(first_day, counter)
        case day.year do
          ^year_number ->
            case day.day do
              1 -> {:ok, month} = Timetables.create_month(%{value: day.month, year_id: year.id})
              _ -> query = from m in Timetables.Month, where: m.value == ^day.month, where: m.year_id == ^year.id
                   month = MehrSchulferien.Repo.one(query)
            end

            Timetables.create_day(%{value: day})
          _ -> nil
        end
      _ -> nil
    end
  end
end

# Periods
#
File.stream!("priv/repo/period-seeds.json") |>
Stream.map( &(String.replace(&1, "\n", "")) ) |>
Stream.with_index |>
Enum.each( fn({contents, line_num}) ->
  period = Poison.decode!(contents)
  case {period["school_slug"], period["city_slug"], period["federal_state_slug"], period["country_slug"]} do
    {nil, nil, nil, slug} ->
          country = Locations.get_country!(slug)
          Timetables.create_period(%{
            starts_on: period["starts_on"],
            ends_on: period["ends_on"],
            country_id: country.id,
            category: period["category"],
            source: period["source"],
            name: period["name"],
            religion_id: keine_religion.id
          })
    {nil, nil, slug, nil} ->
          federal_state = Locations.get_federal_state!(slug)
          Timetables.create_period(%{
            starts_on: period["starts_on"],
            ends_on: period["ends_on"],
            federal_state_id: federal_state.id,
            category: period["category"],
            source: period["source"],
            name: period["name"],
            religion_id: keine_religion.id
          })
    {nil, slug, nil, nil} ->
          city = Locations.get_city!(slug)
          Timetables.create_period(%{
            starts_on: period["starts_on"],
            ends_on: period["ends_on"],
            city_id: city.id,
            category: period["category"],
            source: period["source"],
            name: period["name"],
            religion_id: keine_religion.id
          })
    {slug, nil, nil, nil} ->
          school = Locations.get_school!(slug)
          Timetables.create_period(%{
            starts_on: period["starts_on"],
            ends_on: period["ends_on"],
            school_id: school.id,
            category: period["category"],
            source: period["source"],
            name: period["name"],
            religion_id: keine_religion.id
          })
    {_, _, _, _} -> nil
  end
end)

# Anzahl der beweglichen Ferientage
#
years = [
        {2016, [{badenwuerttemberg, 3}, {brandenburg, 3}, {bremen, 1}, {hessen, 3}, {mecklenburgvorpommern, 3},
        {nordrheinwestfalen, 3}, {rheinlandpfalz, 4}, {saarland, 2}, {sachsen, 2}, {sachsenanhalt, 1},
        {schleswigholstein, 3}]},
        {2017,[{badenwuerttemberg, 4}, {brandenburg, 3}, {hessen, 3}, {mecklenburgvorpommern, 3},
        {nordrheinwestfalen, 4}, {rheinlandpfalz, 6}, {saarland, 2}, {schleswigholstein, 2},
        {thueringen, 2}]},
        {2018, [{badenwuerttemberg, 5}, {brandenburg, 2}, {hessen, 4}, {mecklenburgvorpommern, 3},
        {nordrheinwestfalen, 4}, {rheinlandpfalz, 6}, {saarland, 3}, {sachsen, 1}, {sachsenanhalt, 1},
        {schleswigholstein, 1}, {thueringen, 2}]},
        {2019, [{badenwuerttemberg, 5}, {brandenburg, 2}, {hessen, 4}, {mecklenburgvorpommern, 3},
        {nordrheinwestfalen, 4}, {rheinlandpfalz, 6}, {saarland, 1}, {sachsen, 1}, {sachsenanhalt, 1},
        {schleswigholstein, 2}, {thueringen, 2}]},
        ]
for {year_slug, bewegliche_ferientage} <- years do
  year = Timetables.get_year!(year_slug)
  for {federal_state, value} <- bewegliche_ferientage do
    Timetables.create_beweglicher_ferientag(%{federal_state_id: federal_state.id, year_id: year.id, value: value})
  end
end

# Bewegliche Ferientage
#
school = Locations.get_school!("56068-grundschule-schenkendorf-koblenz")

for {name, date} <- [{"Reformationstag", ~D[2017-10-30]}, {"Fastnacht", ~D[2018-02-09]},
{"Fastnacht", ~D[2018-02-12]}, {"Fastnacht", ~D[2018-02-13]},
{"Himmelfahrt", ~D[2018-05-11]}, {"Fronleichnam", ~D[2018-06-01]}] do
  Timetables.create_period(%{category: "Beweglicher Ferientag",
  school_id: school.id, starts_on: date, ends_on: date, name: name, religion_id: keine_religion.id})
end

# Jüdische Feiertage
#
juedisch = MehrSchulferien.Users.get_religion!("juedisch")
islamisch = MehrSchulferien.Users.get_religion!("islamisch")

religious_holidays =
[
{~D[2016-04-23], ~D[2016-04-23], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2016-04-24], ~D[2016-04-24], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2016-04-29], ~D[2016-04-29], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2016-04-30], ~D[2016-04-30], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2017-04-11], ~D[2017-04-11], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2017-04-12], ~D[2017-04-12], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2017-04-17], ~D[2017-04-17], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2017-04-18], ~D[2017-04-18], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2018-03-31], ~D[2018-03-31], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2018-04-01], ~D[2018-04-01], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2018-04-06], ~D[2018-04-06], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2018-04-07], ~D[2018-04-07], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2019-04-20], ~D[2019-04-20], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2019-04-21], ~D[2019-04-21], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2019-04-26], ~D[2019-04-26], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2019-04-27], ~D[2019-04-27], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2020-04-09], ~D[2020-04-09], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2020-04-10], ~D[2020-04-10], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2020-04-15], ~D[2020-04-15], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2020-04-16], ~D[2020-04-16], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2021-03-28], ~D[2021-03-28], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2021-03-29], ~D[2021-03-29], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2021-04-03], ~D[2021-04-03], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2021-04-04], ~D[2021-04-04], "Pessach (Fest des ungesäuerten Brotes)", juedisch.id},
{~D[2016-06-12], ~D[2016-06-12], "Schawuot (Wochenfest)", juedisch.id},
{~D[2016-06-13], ~D[2016-06-13], "Schawuot (Wochenfest)", juedisch.id},
{~D[2017-05-31], ~D[2017-05-31], "Schawuot (Wochenfest)", juedisch.id},
{~D[2017-06-01], ~D[2017-06-01], "Schawuot (Wochenfest)", juedisch.id},
{~D[2018-05-20], ~D[2018-05-20], "Schawuot (Wochenfest)", juedisch.id},
{~D[2018-05-21], ~D[2018-05-21], "Schawuot (Wochenfest)", juedisch.id},
{~D[2019-06-09], ~D[2019-06-09], "Schawuot (Wochenfest)", juedisch.id},
{~D[2019-06-10], ~D[2019-06-10], "Schawuot (Wochenfest)", juedisch.id},
{~D[2020-05-29], ~D[2020-05-29], "Schawuot (Wochenfest)", juedisch.id},
{~D[2020-05-30], ~D[2020-05-30], "Schawuot (Wochenfest)", juedisch.id},
{~D[2021-05-17], ~D[2021-05-17], "Schawuot (Wochenfest)", juedisch.id},
{~D[2021-05-18], ~D[2021-05-18], "Schawuot (Wochenfest)", juedisch.id},
{~D[2016-10-03], ~D[2016-10-03], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2016-10-04], ~D[2016-10-04], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2017-09-21], ~D[2017-09-21], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2017-09-22], ~D[2017-09-22], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2018-09-10], ~D[2018-09-10], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2018-09-11], ~D[2018-09-11], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2019-09-30], ~D[2019-09-30], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2019-10-01], ~D[2019-10-01], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2020-09-19], ~D[2020-09-19], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2020-09-20], ~D[2020-09-20], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2021-09-07], ~D[2021-09-07], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2021-09-08], ~D[2021-09-08], "Rosch Haschana (Neujahrsfest)", juedisch.id},
{~D[2016-10-12], ~D[2016-10-12], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2017-09-30], ~D[2017-09-30], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2018-09-19], ~D[2018-09-19], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2019-10-09], ~D[2019-10-09], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2020-09-28], ~D[2020-09-28], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2021-09-16], ~D[2021-09-16], "Jom Kippur (Versöhnungsfest)", juedisch.id},
{~D[2016-10-17], ~D[2016-10-17], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2016-10-18], ~D[2016-10-18], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2017-10-05], ~D[2017-10-05], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2017-10-06], ~D[2017-10-06], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2018-09-24], ~D[2018-09-24], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2018-09-25], ~D[2018-09-25], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2019-10-14], ~D[2019-10-14], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2019-10-15], ~D[2019-10-15], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2020-10-03], ~D[2020-10-03], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2020-10-04], ~D[2020-10-04], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2021-09-21], ~D[2021-09-21], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2021-09-22], ~D[2021-09-22], "Sukkot (Laubhüttenfest)", juedisch.id},
{~D[2016-10-24], ~D[2016-10-24], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2017-10-12], ~D[2017-10-12], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2018-10-01], ~D[2018-10-01], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2019-10-21], ~D[2019-10-21], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2020-10-10], ~D[2020-10-10], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2021-09-28], ~D[2021-09-28], "Schemini Azeret (Schlussfest)", juedisch.id},
{~D[2016-10-25], ~D[2016-10-25], "Simchat Thora (Gesetzesfreude)", juedisch.id},
{~D[2017-10-13], ~D[2017-10-13], "Simchat Thora (Gesetzesfreude)", juedisch.id},
{~D[2018-10-02], ~D[2018-10-02], "Simchat Thora (Gesetzesfreude)", juedisch.id},
{~D[2019-10-22], ~D[2019-10-22], "Simchat Thora (Gesetzesfreude)", juedisch.id},
{~D[2020-10-11], ~D[2020-10-11], "Simchat Thora (Gesetzesfreude)", juedisch.id},
{~D[2021-09-29], ~D[2021-09-29], "Simchat Thora (Gesetzesfreude)", juedisch.id},

{~D[2016-07-05], ~D[2016-07-05], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2017-06-25], ~D[2017-06-25], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2018-06-15], ~D[2018-06-15], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2019-06-05], ~D[2019-06-05], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2020-05-24], ~D[2020-05-24], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2021-05-13], ~D[2021-05-13], "Ramadanfest (Fastenbrechenfest)", islamisch.id},
{~D[2016-09-12], ~D[2016-09-12], "Opferfest", islamisch.id},
{~D[2017-09-01], ~D[2017-09-01], "Opferfest", islamisch.id},
{~D[2018-08-21], ~D[2018-08-21], "Opferfest", islamisch.id},
{~D[2019-08-11], ~D[2019-08-11], "Opferfest", islamisch.id},
{~D[2020-07-31], ~D[2020-07-31], "Opferfest", islamisch.id},
{~D[2021-07-20], ~D[2021-07-20], "Opferfest", islamisch.id}
]

federal_states = MehrSchulferien.Locations.list_federal_states

for holiday <- religious_holidays do
  {starts_on, ends_on, name, religion_id} = holiday
  for federal_state <- federal_states do
    MehrSchulferien.Timetables.create_period(%{
      category: "Religiöser Feiertag",
      federal_state_id: federal_state.id,
      name: name,
      starts_on: starts_on,
      ends_on: ends_on,
      religion_id: religion_id,
      source: "http://www.berlin.de/sen/bjf/service/kalender/ferien/artikel.420979.php"
    })
  end
end
