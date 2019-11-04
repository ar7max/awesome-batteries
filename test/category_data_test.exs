defmodule AwesomeBatteries.CategoryDataTest do
  use AwesomeBatteries.DataCase

  alias AwesomeBatteries.Category
  alias AwesomeBatteries.Markdown.Parser

  test "insert_all_from_repos/1 should save all categories" do
    repos = Parser.file("test.md")

    saved_categories = Category.insert_all_from_repos(repos, returning: true)

    {1, [%AwesomeBatteries.Category{id: _, name: "Actors"}]} = saved_categories
  end

end
