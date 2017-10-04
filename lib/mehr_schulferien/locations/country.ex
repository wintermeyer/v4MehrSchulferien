defmodule MehrSchulferien.Locations.Country do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Locations.Country
  alias MehrSchulferien.NameSlug

  @derive {Phoenix.Param, key: :slug}
  schema "countries" do
    field :name, :string
    field :slug, NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(%Country{} = country, attrs) do
    country
    |> cast(attrs, [:name, :slug])
    |> set_slug
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
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
