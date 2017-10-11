defmodule MehrSchulferien.Repo.Migrations.CreateBeweglicheFerientage do
  use Ecto.Migration

  def change do
    create table(:bewegliche_ferientage) do
      add :value, :integer
      add :federal_state_id, references(:federal_states, on_delete: :nothing)
      add :year_id, references(:years, on_delete: :nothing)

      timestamps()
    end

    create index(:bewegliche_ferientage, [:federal_state_id])
    create index(:bewegliche_ferientage, [:year_id])
    create unique_index(:bewegliche_ferientage, [:federal_state_id, :year_id], name: :state_id_year_id)
  end
end
