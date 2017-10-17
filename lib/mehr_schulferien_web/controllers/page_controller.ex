defmodule MehrSchulferienWeb.PageController do
  use MehrSchulferienWeb, :controller

  def index(conn, _params) do
    federal_states = MehrSchulferien.Locations.list_federal_states

    render(conn, "index.html", federal_states: federal_states)
  end
end
