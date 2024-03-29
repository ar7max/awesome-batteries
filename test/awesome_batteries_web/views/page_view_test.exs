defmodule AwesomeBatteriesWeb.PageViewTest do
  use AwesomeBatteriesWeb.ConnCase, async: true

  alias AwesomeBatteries
  alias AwesomeBatteries.{
    Importer,
    Parser,
    Repo
  }

  import Ecto.Query

  setup do
    AwesomeBatteries.import_data("test.md")
    :ok
  end

  test "group_repos_by_categories/1 should return repos grouped by categories" do
    repos = AwesomeBatteries.fetch_repos()

    grouped_by_categories = AwesomeBatteriesWeb.PageView.group_repos_by_categories(repos)

    assert grouped_by_categories |> Map.keys() == ["Actors"]

    assert grouped_by_categories["Actors"] |> Enum.map(fn r -> Map.take(r, [:category, :name, :owner]) end) == [
      %{category: "Actors", name: "dflow", owner: "dalmatinerdb"},
      %{category: "Actors", name: "exactor", owner: "sasa1977"}
    ]

  end

  test "repo_url/1 should return github repo url" do
    repo = Repo.one(from AwesomeBatteries.GithubRepo, limit: 1)

    %{owner: owner, name: name} = repo
    assert AwesomeBatteriesWeb.PageView.repo_url(repo) == "http://github.com/#{owner}/#{name}/"
  end
end
