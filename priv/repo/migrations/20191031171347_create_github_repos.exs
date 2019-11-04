defmodule AwesomeBatteries.Repo.Migrations.CreateGithubRepos do
  use Ecto.Migration

  def change do
    create table(:github_repos) do
      add :owner, :text
      add :name, :text
      add :stargazers_count, :integer
      add :updated_at, :naive_datetime
      add :description, :text

      add :category_id, references(:categories)
    end

    create unique_index :github_repos, [:name, :owner]
  end
end
