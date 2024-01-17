defmodule WalletTracker.Tracker do
  @moduledoc """
  This module is responsible for tracking the balance of a wallet.
  """
  use GenServer

  def start_link(address) do
    GenServer.start_link(__MODULE__, address)
  end

  def init(address) do
    schedule_work()
    {:ok, {address, 0}}
  end

  def handle_call(:balance, _, {_address, balance} = state) do
    {:reply, balance, state}
  end

  def handle_info(:balance, {address, _balance}) do
    balance = get_balance(address)
    schedule_work()
    {:noreply, {address, balance}}
  end

  def track(address) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        WalletTracker.DynamicSupervisor,
        {WalletTracker.Tracker, address}
      )

    pid
  end

  def balance(pid) do
    GenServer.call(pid, :balance)
  end

  def get_balance(address) do
    %HTTPoison.Response{
      status_code: 200,
      body: body
    } =
      HTTPoison.get!("https://beaconcha.in/api/v1/execution/address/#{address}")

    %{
      "data" => %{
        "ether" => balance
      }
    } = Jason.decode!(body)

    String.to_float(balance)
  end

  defp schedule_work do
    Process.send_after(self(), :balance, :timer.seconds(1))
  end
end
