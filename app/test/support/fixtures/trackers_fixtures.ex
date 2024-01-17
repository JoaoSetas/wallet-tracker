defmodule WalletTracker.TrackersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WalletTracker.Trackers` context.
  """

  @doc """
  Generate a unique wallet address.
  """
  def unique_wallet_address, do: "some address#{System.unique_integer([:positive])}"

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        address: unique_wallet_address(),
        balance: 120.5
      })
      |> WalletTracker.Trackers.create_wallet()

    wallet
  end
end
