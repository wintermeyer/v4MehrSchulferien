defmodule MehrSchulferien.Timetables.Slot do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Timetables.Slot


  schema "slots" do
    belongs_to :day, MehrSchulferien.Timetables.Day
    belongs_to :period, MehrSchulferien.Timetables.Period

    timestamps()
  end

  @doc false
  def changeset(%Slot{} = slot, attrs) do
    slot
    |> cast(attrs, [:day_id, :period_id])
    |> validate_required([:day_id, :period_id])
    |> assoc_constraint(:day)
    |> assoc_constraint(:period)
  end
end
