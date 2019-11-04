defmodule AwesomeBatteries.AwesomeBatteriesTest do
  use AwesomeBatteries.DataCase

  alias AwesomeBatteries.Markdown.Parser
  alias AwesomeBatteries.Category

  import AwesomeBatteries

  setup do
    import_data("test.md")
    :ok
  end

  test "fetch_categories/0 should return all categories" do
    categories = fetch_categories()
    [
      %Category{
        description: "Libraries and tools for working with actors and such.",
        name: "Actors"
      }
    ] = categories
  end

  test "fetch_repos/1 called without parameters should return all repos" do
    repos = fetch_repos()

    required_repos = [
      %{name: "dflow", owner: "dalmatinerdb"},
      %{name: "exactor", owner: "sasa1977"}
    ]

    assert repos |> Enum.map(fn r -> r |> Map.take([:name, :owner]) end) == required_repos
  end

  test "fetch_repos/1 should return only repos with stargazers_count more or equal than parameter it was called with" do
    min_stars = 1_000_000_000

    category_id = (Repo.one from c in Category, limit: 1).id

    %{name: "1", owner: "2", description: "3", category_id: category_id, stargazers_count: min_stars, updated_at: DateTime.utc_now()}
    |> AwesomeBatteries.GithubRepo.new()
    |> AwesomeBatteries.Repo.insert()

    repo = fetch_repos(min_stars) |> hd()

    assert repo.stargazers_count == min_stars
    assert repo.name == "1"
    assert repo.owner == "2"
    assert repo.description == "3"
  end

end
