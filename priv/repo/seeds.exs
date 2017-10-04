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
alias MehrSchulferien.Locations.FederalState
alias MehrSchulferien.Locations.City
alias MehrSchulferien.Repo
import Ecto.Query

# Locations
#
{:ok, deutschland} = Locations.create_country(%{name: "Deutschland"})

# Create the federal states of Germany
#
{:ok, _badenwuerttemberg} = Locations.create_federal_state(%{name: "Baden-Württemberg", code: "BW", country_id: deutschland.id})
{:ok, _bayern} = Locations.create_federal_state(%{name: "Bayern", code: "BY", country_id: deutschland.id})
{:ok, _berlin} = Locations.create_federal_state(%{name: "Berlin", code: "BE", country_id: deutschland.id})
{:ok, _brandenburg} = Locations.create_federal_state(%{name: "Brandenburg", code: "BB", country_id: deutschland.id})
{:ok, _bremen} = Locations.create_federal_state(%{name: "Bremen", code: "HB", country_id: deutschland.id})
{:ok, _hamburg} = Locations.create_federal_state(%{name: "Hamburg", code: "HH", country_id: deutschland.id})
{:ok, _hessen} = Locations.create_federal_state(%{name: "Hessen", code: "HE", country_id: deutschland.id})
{:ok, _mecklenburgvorpommern} = Locations.create_federal_state(%{name: "Mecklenburg-Vorpommern", code: "MV", country_id: deutschland.id})
{:ok, _niedersachsen} = Locations.create_federal_state(%{name: "Niedersachsen", code: "NI", country_id: deutschland.id})
{:ok, _nordrheinwestfalen} = Locations.create_federal_state(%{name: "Nordrhein-Westfalen", code: "NW", country_id: deutschland.id})
{:ok, _rheinlandpfalz} = Locations.create_federal_state(%{name: "Rheinland-Pfalz", code: "RP", country_id: deutschland.id})
{:ok, _saarland} = Locations.create_federal_state(%{name: "Saarland", code: "SL", country_id: deutschland.id})
{:ok, _sachsen} = Locations.create_federal_state(%{name: "Sachsen", code: "SN", country_id: deutschland.id})
{:ok, _sachsenanhalt} = Locations.create_federal_state(%{name: "Sachsen-Anhalt", code: "ST", country_id: deutschland.id})
{:ok, _schleswigholstein} = Locations.create_federal_state(%{name: "Schleswig-Holstein", code: "SH", country_id: deutschland.id})
{:ok, _thueringen} = Locations.create_federal_state(%{name: "Thüringen", code: "TH", country_id: deutschland.id})

# Example cities
#
query = from f in FederalState, where: f.name == "Brandenburg"
federal_state = Repo.one!(query)
{:ok, _} = Locations.create_city(%{name: "Alt Golm", slug: "15526-alt-golm", zip_code: "15526", federal_state_id: federal_state.id, country_id: 1})
{:ok, _} = Locations.create_city(%{name: "Alt Krüssow", slug: "16921-alt-kruessow", zip_code: "16921", federal_state_id: federal_state.id, country_id: 1})
{:ok, _} = Locations.create_city(%{name: "Alt Ruppin", slug: "16827-alt-ruppin", zip_code: "16827", federal_state_id: federal_state.id, country_id: 1})
{:ok, _} = Locations.create_city(%{name: "Annahütte-Siedlung", slug: "01994-annahuette-siedlung", zip_code: "01994", federal_state_id: federal_state.id, country_id: 1})
{:ok, _} = Locations.create_city(%{name: "Bantikow", slug: "16868-bantikow", zip_code: "16868", federal_state_id: federal_state.id, country_id: 1})
