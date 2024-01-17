defmodule WalletTracker.Repo do
  use Ecto.Repo,
    otp_app: :wallet_tracker,
    adapter: Ecto.Adapters.Postgres
end
