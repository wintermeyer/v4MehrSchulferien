defmodule MehrSchulferienWeb.Router do
  use MehrSchulferienWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MehrSchulferienWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # Locations
    #
    resources "/countries", CountryController
    resources "/federal_states", FederalStateController
    resources "/cities", CityController
    resources "/schools", SchoolController

    # Timetables
    #
    resources "/years", YearController
    resources "/months", MonthController
    resources "/days", DayController
    resources "/periods", PeriodController
    resources "/slots", SlotController
    resources "/bewegliche_ferientage", BeweglicherFerientagController

    # Users
    #
    resources "/religions", ReligionController

    # nested routes
    #
    resources "/federal_states", FederalStateController, only: [:show] do
      resources "/years", LocationYearController, only: [:show]
      resources "/cities", LocationCityController, only: [:index]
      resources "/schools", LocationSchoolController, only: [:index]
      resources "/religions", LocationReligionController, only: [:show]
    end

    resources "/schools", SchoolController, only: [:show] do
      resources "/years", LocationYearController, only: [:show]
      resources "/religions", LocationReligionController, only: [:show]
    end

    resources "/countries", CountryController, only: [:show] do
      resources "/cities", LocationCityController, only: [:index]
      resources "/schools", LocationSchoolController, only: [:index]
    end

    resources "/cities", CityController, only: [:show] do
      resources "/years", LocationYearController, only: [:show]
    end


  end

  # Other scopes may use custom stacks.
  # scope "/api", MehrSchulferienWeb do
  #   pipe_through :api
  # end
end
