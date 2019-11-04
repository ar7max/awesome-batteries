defmodule AwesomeBatteries.Repo do
  use Ecto.Repo,
    otp_app: :awesome_batteries,
    adapter: Ecto.Adapters.Postgres
end
