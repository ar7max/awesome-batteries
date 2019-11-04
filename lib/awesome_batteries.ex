defmodule AwesomeBatteries do
  @moduledoc """
  AwesomeBatteries keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias AwesomeBatteries.Repo
  alias AwesomeBatteries.Markdown.Parser
  alias AwesomeBatteries.GitHub.Importer

  import Ecto.Query

  @spec fetch_categories :: any
  def fetch_categories, do:
    Repo.all(AwesomeBatteries.Category)

  def fetch_repos(min_stars \\ nil) do

    case min_stars do
      nil ->  from repo in AwesomeBatteries.GithubRepo, preload: :category
      value -> from repo in AwesomeBatteries.GithubRepo, where: repo.stargazers_count >= ^value, preload: :category
    end
    |> Repo.all

  end

  def sync_data do
    today = Date.utc_today()
    path = "#{today.day}_#{today.month}_#{today.year}_README.md"

    HTTPotion.get(
      "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md"
    )
    |> case do
        %{ body: body } -> File.write!(path,body)
    end

    import_data(path)
  end

  def import_data(path) do
    repos = Parser.file(path)
      |> Importer.fetch_repos()
      |> Enum.filter(fn
        %{ status: :ok } -> true
        _ -> false
      end)
      |> Enum.map(fn %{ data: data, repo: repo } ->
        Map.merge(data, repo)
      end)
      |> Enum.group_by(fn %{ "category" => category } -> category end)

    # Updating categories
    repos
      |> Map.keys()
      |> Enum.map(fn {name, description} -> %{ name: name, description: description } end)
      |> update_categories()

    categories = fetch_categories()
      |> Enum.reduce(%{}, fn %{ id: id, description: description, name: name }, acc ->
        Map.put(acc, {name, description}, id)
      end) #END Enum.reduce

      map_repos_to_categories_and_save_repos(categories, repos)
  end

  defp update_categories(categories), do:
    Repo.insert_all(AwesomeBatteries.Category, categories, on_conflict: :nothing)

  defp map_repos_to_categories(categories, repos) do
    repos
      |> Map.keys()
      |> Enum.map(fn category ->
        category_id = categories[category]
        repos
          |> Map.get(category)
          |> Enum.map(fn repo ->
            repo
              |> Map.delete(:category)
              |> Map.put("category_id", category_id)
          end)
      end)
    |> List.flatten()
  end

  defp map_repos_to_categories_and_save_repos(categories, repos) do
    # Mapping category ids to repos and persisitng
    map_repos_to_categories(categories, repos)
    |> Enum.each(fn repo ->
        repo
        |> AwesomeBatteries.GithubRepo.new()
        |> Repo.insert(on_conflict: :replace_all, conflict_target: [:name, :owner])
        |> case do
          {:ok, result} -> result
        end
    end) #END Enum.map
  end

end
