defmodule MehrSchulferien.Repo.Migrations.CreateReligions do
  use Ecto.Migration

  def change do
    create table(:religions) do
      add :name, :string
      add :slug, :string

      timestamps()
    end

    create unique_index(:religions, [:slug])
  end
end
