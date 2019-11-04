defmodule AwesomeBatteriesWeb.PageController do
  use AwesomeBatteriesWeb, :controller

  import AwesomeBatteries

  def index(conn, %{ "min_stars" => min_stars }) do
    repos = fetch_repos(min_stars)

    render(conn, "index.html", repos: repos)
  end

  def index(conn, _params) do
    repos = fetch_repos()

    render(conn, "index.html", repos: repos)
  end
end
