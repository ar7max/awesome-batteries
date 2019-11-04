defmodule AwesomeBatteries.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      AwesomeBatteries.Repo,
      # Start the endpoint when the application starts
      AwesomeBatteriesWeb.Endpoint,
      # Starts a worker by calling: AwesomeBatteries.Worker.start_link(arg)
      # {AwesomeBatteries.Worker, arg},
      :poolboy.child_spec(:importer_worker, poolboy_config()),
      AwesomeBatteries.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeBatteries.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeBatteriesWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def poolboy_config do
    [
      {:name, {:local, :importer_worker}},
      {:worker_module, AwesomeBatteries.GitHub.Importer.Worker},
      {:size, 5},
      {:max_overflow, 2}
    ]
  end
end
