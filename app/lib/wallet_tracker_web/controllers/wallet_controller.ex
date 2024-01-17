defmodule WalletTrackerWeb.WalletController do
  use WalletTrackerWeb, :controller

  alias WalletTracker.Trackers
  alias WalletTracker.Trackers.Wallet
  alias WalletTracker.TrackerProcess

  action_fallback WalletTrackerWeb.FallbackController

  def index(conn, _params) do
    wallets = Trackers.list_wallets()
    render(conn, :index, wallets: wallets)
  end

  def track(conn, %{"address" => address}) do
    with {:ok, balance} <- TrackerProcess.get_balance(address),
         {:ok, %Wallet{} = wallet} <-
           Trackers.create_wallet(%{address: address, balance: balance}) do
      TrackerProcess.track(address)

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/status/#{address}")
      |> render(:show, wallet: wallet)
    end
  end

  def status(conn, %{"address" => address}) do
    with {:ok, balance} <- TrackerProcess.balance(address),
         {:ok, diference} <- TrackerProcess.diference(address) do
      render(conn, :status, address: address, balance: balance, diference: diference)
    end
  end

  def delete(conn, %{"address" => address}) do
    with {:ok, %Wallet{} = wallet} <- Trackers.get_wallet(address),
         {:ok, %Wallet{}} <- Trackers.delete_wallet(wallet) do
      TrackerProcess.remove_tracker(address)
      send_resp(conn, :no_content, "")
    end
  end
end
