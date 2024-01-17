defmodule WalletTracker.TrackersTest do
  use WalletTracker.DataCase

  alias WalletTracker.Trackers

  describe "wallets" do
    alias WalletTracker.Trackers.Wallet

    import WalletTracker.TrackersFixtures

    @invalid_attrs %{address: nil, balance: nil}

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Trackers.list_wallets() == [wallet]
    end

    test "get_wallet/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert {:ok, ^wallet} = Trackers.get_wallet(wallet.address)
    end

    test "create_wallet/1 with valid data creates a wallet" do
      valid_attrs = %{address: "some address", balance: 120.5}

      assert {:ok, %Wallet{} = wallet} = Trackers.create_wallet(valid_attrs)
      assert wallet.address == "some address"
      assert wallet.balance == 120.5
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trackers.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      update_attrs = %{address: "some updated address", balance: 456.7}

      assert {:ok, %Wallet{} = wallet} = Trackers.update_wallet(wallet, update_attrs)
      assert wallet.address == "some updated address"
      assert wallet.balance == 456.7
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Trackers.update_wallet(wallet, @invalid_attrs)
      assert {:ok, ^wallet} = Trackers.get_wallet(wallet.address)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Trackers.delete_wallet(wallet)
      assert {:error, "Wallet not found"} = Trackers.get_wallet(wallet.address)
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Trackers.change_wallet(wallet)
    end
  end
end
