defmodule WalletTrackerWeb.WalletControllerTest do
  use WalletTrackerWeb.ConnCase

  import WalletTracker.TrackersFixtures

  @address "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

  @invalid_address "asd"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all wallets", %{conn: conn} do
      conn = get(conn, ~p"/api/wallets")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "track wallet" do
    test "renders wallet when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/track", address: @address)
      assert %{"address" => @address} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/status/#{@address}")

      assert %{
               "address" => @address,
               "balance" => _balance
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/wallets", wallet: @invalid_address)
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete wallet" do
    setup [:create_wallet]

    test "deletes chosen wallet", %{conn: conn, wallet: wallet} do
      conn = delete(conn, ~p"/api/delete/#{wallet.address}")
      assert response(conn, 204)
    end
  end

  defp create_wallet(_) do
    wallet = wallet_fixture()
    %{wallet: wallet}
  end
end
