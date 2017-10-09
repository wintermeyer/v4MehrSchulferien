defmodule MehrSchulferien.Repo.Migrations.AddReligionIdToPeriods do
  use Ecto.Migration

  def change do
    alter table(:periods) do
      add :religion_id, references(:religions, on_delete: :nothing)
    end

    create index(:periods, [:religion_id])
  end
end
