defmodule AwesomeBatteriesWeb.PageView do
  use AwesomeBatteriesWeb, :view

  def group_repos_by_categories([]), do: %{}

  def group_repos_by_categories(repos) do
    IO.puts( inspect repos )
    repos
    |> Stream.map(fn r -> Map.take(r, [:name, :owner, :category, :updated_at, :stargazers_count, :description]) end)
    |> Stream.map(fn r ->
      Map.update!(r, :category, fn c -> c.name end)
    end)
    |> Enum.group_by(fn r -> r[:category] end)
  end

  def repo_url(%{ owner: owner, name: name }) do
    "http://github.com/#{owner}/#{name}/"
  end
end
