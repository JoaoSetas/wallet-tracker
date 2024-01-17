defmodule WalletTracker.TrackerProcess do
  @moduledoc """
  This module is responsible for tracking the balance of a wallet.
  """
  use GenServer

  alias WalletTracker.Trackers

  def start_link({address, registered_name}) do
    GenServer.start_link(__MODULE__, address, name: registered_name)
  end

  @spec track(String.t()) :: atom()
  @doc """
  Starts a new tracker for the given `address`.

  `address` is a string representing the wallet address.

  ## Examples

      iex> WalletTracker.Tracker.track("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
      #PID<0.632.0>
  """
  def track(address) do
    registered_name = String.to_atom(address)

    {:ok, _pid} =
      DynamicSupervisor.start_child(
        WalletTracker.DynamicSupervisor,
        {__MODULE__, {address, registered_name}}
      )

    registered_name
  end

  @spec balance(String.t()) :: {:ok, float()} | {:error, String.t()}
  @doc """
  Returns the balance of the given wallet.

  ## Examples

      iex> WalletTracker.Tracker.balance("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
      {:ok, 1.2345}

      iex> WalletTracker.Tracker.balance("0x1234567890123456789012345678901234567890")
      {:error, "Wallet not found"}
  """
  def balance(address) do
    atom_address = String.to_atom(address)

    case Process.whereis(atom_address) do
      nil ->
        {:error, :not_found}

      pid ->
        {:ok, GenServer.call(pid, :balance)}
    end
  end

  @spec diference(String.t()) :: {:ok, float()} | {:error, String.t()}
  @doc """
  Returns the diference between the current balance and the last balance.

  ## Examples

      iex> WalletTracker.Tracker.diference("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
      {:ok, 0.1234}

      iex> WalletTracker.Tracker.diference("0x1234567890123456789012345678901234567890")
      {:error, "Wallet not found"}
  """
  def diference(address) do
    atom_address = String.to_atom(address)

    case Process.whereis(atom_address) do
      nil ->
        {:error, :not_found}

      pid ->
        {:ok, GenServer.call(pid, :diference)}
    end
  end

  @spec remove_tracker(String.t()) :: :ok | {:error, :not_found}
  @doc """
  Removes the tracker for the given `address`.

  ## Examples

      iex> WalletTracker.Tracker.remove_tracker("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
      :ok

      iex> WalletTracker.Tracker.remove_tracker("0x1234567890123456789012345678901234567890")
      {:error, :not_found}
  """
  def remove_tracker(address) do
    atom_address = String.to_atom(address)

    case Process.whereis(atom_address) do
      nil ->
        {:error, :not_found}

      pid ->
        DynamicSupervisor.terminate_child(WalletTracker.DynamicSupervisor, pid)
    end
  end

  @spec get_balance(String.t()) :: {:ok, float()} | {:error, String.t()}
  @doc """
  Returns the balance of the given wallet.

  ## Examples

      iex> WalletTracker.Tracker.get_balance("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
      {:ok, 1.2345}
  """
  def get_balance(address) do
    case HTTPoison.get!("https://beaconcha.in/api/v1/execution/address/#{address}") do
      %HTTPoison.Response{
        status_code: 200,
        body: body
      } ->
        %{
          "data" => %{
            "ether" => balance
          }
        } = Jason.decode!(body)

        {:ok, String.to_float(balance)}

      %HTTPoison.Response{
        status_code: 400,
        body: body
      } ->
        %{"status" => status} = Jason.decode!(body)
        {:error, status}
    end
  end

  @impl true
  def init(address) do
    schedule_work()
    {:ok, balance} = get_balance(address)
    {:ok, {address, balance, 0, balance}}
  end

  @impl true
  def handle_call(:balance, _, {_address, balance, _diference, _starting_balance} = state) do
    {:reply, balance, state}
  end

  @impl true
  def handle_call(:diference, _, {_address, _balance, diference, _starting_balance} = state) do
    {:reply, diference, state}
  end

  @impl true
  def handle_info(:balance, {address, balance, _diference, starting_balance}) do
    {:ok, new_balance} = get_balance(address)
    diference = new_balance - starting_balance

    if new_balance != balance do
      {:ok, wallet} = Trackers.get_wallet(address)
      Trackers.update_wallet(wallet, %{"balance" => new_balance})
      # dbg("Balance for #{address} is #{new_balance} (#{diference})")
    end

    schedule_work()
    {:noreply, {address, new_balance, diference, starting_balance}}
  end

  defp schedule_work do
    Process.send_after(self(), :balance, :timer.seconds(1))
  end
end
