defmodule MehrSchulferien.Repo.Migrations.CreateSlots do
  use Ecto.Migration

  def change do
    create table(:slots) do
      add :day_id, references(:days, on_delete: :nothing)
      add :period_id, references(:periods, on_delete: :nothing)

      timestamps()
    end

    create index(:slots, [:day_id])
    create index(:slots, [:period_id])
  end
end
