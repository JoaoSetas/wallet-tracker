defmodule WalletTrackerWeb.WalletJSON do
  alias WalletTracker.Trackers.Wallet

  @doc """
  Renders a list of wallets.
  """
  def index(%{wallets: wallets}) do
    %{data: for(wallet <- wallets, do: data(wallet))}
  end

  @doc """
  Renders a single wallet.
  """
  def show(%{wallet: wallet}) do
    %{data: data(wallet)}
  end

  @doc """
    Renders wallet status
  """
  def status(%{diference: diference, balance: balance, address: address}) do
    %{
      data: %{
        address: address,
        balance: balance,
        diference: diference
      }
    }
  end

  defp data(%Wallet{} = wallet) do
    %{
      address: wallet.address,
      balance: wallet.balance
    }
  end
end
