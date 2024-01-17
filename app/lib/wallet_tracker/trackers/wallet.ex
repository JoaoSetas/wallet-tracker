defmodule WalletTracker.Trackers.Wallet do
  @moduledoc """
  This module is responsible for the Wallet schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :address, :string
    field :balance, :float, default: 0.0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:address, :balance])
    |> validate_required([:address])
    |> unique_constraint(:address)
  end
end
