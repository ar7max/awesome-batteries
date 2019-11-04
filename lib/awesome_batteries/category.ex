defmodule AwesomeBatteries.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwesomeBatteries.Repo

  schema "categories" do
    field :description, :string
    field :name, :string
  end

  def insert_all_from_repos(repos, opts \\ []) do

    categories = for %{ "category" => { name, description } } <- repos do
      %{name: name, description: description}
    end

    opts = opts ++ [on_conflict: :nothing, conflict_target: :name]

    Repo.insert_all(AwesomeBatteries.Category, categories, opts)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
