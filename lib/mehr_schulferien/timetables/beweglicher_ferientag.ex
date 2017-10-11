defmodule MehrSchulferien.Timetables.BeweglicherFerientag do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Timetables.BeweglicherFerientag


  schema "bewegliche_ferientage" do
    field :value, :integer
    belongs_to :federal_state, MehrSchulferien.Locations.FederalState
    belongs_to :year, MehrSchulferien.Timetables.Year

    timestamps()
  end

  @doc false
  def changeset(%BeweglicherFerientag{} = beweglicher_ferientag, attrs) do
    beweglicher_ferientag
    |> cast(attrs, [:value, :federal_state_id, :year_id])
    |> validate_required([:value, :federal_state_id, :year_id])
    |> assoc_constraint(:year)
    |> assoc_constraint(:federal_state)
    |> unique_constraint(:federal_state_id, name: :state_id_year_id)
  end
end
