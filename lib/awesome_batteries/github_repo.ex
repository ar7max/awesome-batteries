defmodule AwesomeBatteries.GithubRepo do
  use Ecto.Schema
  import Ecto.Changeset

  alias AwesomeBatteries.Repo
  alias AwesomeBatteries.Category

  @cast_attrs [:owner, :name, :stargazers_count, :description, :updated_at, :category_id]
  @required @cast_attrs

  schema "github_repos" do
    field :name, :string
    field :owner, :string
    field :description, :string
    field :stargazers_count, :integer
    field :updated_at, :naive_datetime

    belongs_to :category, Category
  end

  def new(attrs), do: changeset(%AwesomeBatteries.GithubRepo{}, attrs)

  @doc false
  def changeset(github_repos, attrs) do
    github_repos
    |> cast(attrs, @cast_attrs)
    |> validate_required(@required)
  end
end
