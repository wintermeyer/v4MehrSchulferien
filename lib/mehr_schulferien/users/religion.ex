defmodule MehrSchulferien.Users.Religion do
  use Ecto.Schema
  import Ecto.Changeset
  alias MehrSchulferien.Users.Religion
  alias MehrSchulferien.NameSlug


  @derive {Phoenix.Param, key: :slug}
  schema "religions" do
    field :name, :string
    field :slug, NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(%Religion{} = religion, attrs) do
    religion
    |> cast(attrs, [:name, :slug])
    |> NameSlug.set_slug
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end
end
