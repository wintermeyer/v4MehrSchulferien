defmodule MehrSchulferien.Locations.FederalState do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Locations.FederalState
  alias MehrSchulferien.NameSlug


  @derive {Phoenix.Param, key: :slug}
  schema "federal_states" do
    field :code, :string
    field :name, :string
    field :slug, NameSlug.Type
    belongs_to :country, MehrSchulferien.Locations.Country

    timestamps()
  end

  @doc false
  def changeset(%FederalState{} = federal_state, attrs) do
    federal_state
    |> cast(attrs, [:name, :code, :slug])
    |> set_slug
    |> validate_required([:name, :code, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:code)
  end

  defp set_slug(changeset) do
    name = get_field(changeset, :name)
    slug = get_field(changeset, :slug)

    case {name, slug} do
      {_, nil} -> changeset
                  |> NameSlug.maybe_generate_slug
                  |> NameSlug.unique_constraint
      {_, _} -> changeset
    end
  end
end
