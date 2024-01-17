defmodule WalletTracker.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :address, :string
      add :balance, :float, default: 0.0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:wallets, [:address])
  end
end
