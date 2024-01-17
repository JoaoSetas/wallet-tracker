defmodule WalletTracker.DynamicSupervisor do
  @moduledoc """
  This module is responsible for starting and supervising the tracker processes.
  """
  use DynamicSupervisor

  alias WalletTracker.Trackers.Wallet

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)

    Task.start(fn ->
      start_children()
    end)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_children() do
    WalletTracker.Trackers.list_wallets()
    |> Enum.each(fn %Wallet{address: address} ->
      WalletTracker.TrackerProcess.track(address)
    end)
  end
end
