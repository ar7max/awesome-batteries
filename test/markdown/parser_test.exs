defmodule AwesomeBatteries.Markdown.ParserTest do
  use ExUnit.Case, async: true

  alias AwesomeBatteries.Markdown.Parser

  @valid_mapping [
    %{"category" => {"Actors", "Libraries and tools for working with actors and such."}, "description" => "Pipelined flow processing engine", "owner" => "dalmatinerdb", "name" => "dflow"},
    %{"category" => {"Actors", "Libraries and tools for working with actors and such."}, "description" => "Helpers for easier implementation of actors in Elixir", "owner" => "sasa1977", "name" => "exactor"}
  ]

  test "file/1 should return proper mapping" do
    assert Parser.file("test.md") == @valid_mapping
  end

end
