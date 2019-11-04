defmodule AwesomeBatteries.Markdown.Parser do

  import String, only: [starts_with?: 2, trim: 1]

  @repo_info_re ~r/(https:\/\/github.com\/(?<owner>.+)\/(?<name>.+?))\/*\) - (?<description>.+)\./

  @category_description_re ~r/[^*]+/

  def string(content) do
    content
      |> Stream.take_while(fn line -> not starts_with?(line, "# Resources") end)
      |> Stream.filter(fn line -> starts_with?(line, "##") || starts_with?(line, "*") end)
      |> Stream.map(fn line -> trim(line) end)
      |> Enum.reduce({}, fn

        "## " <> category, {}           -> {[], {category, ""}}

        "## " <> category, {repos, _}   -> {repos, {category, ""}}

        "* [" <> info, {repos, category_info}->
          case parsed_repo_info(info) do
            nil   -> {repos, category_info}

            data  -> {
                repos ++ [Map.put(data, "category", category_info)],
                category_info
              }

          end

        "*" <> new_description, {repos, {category, _}}    ->
          new_description = parsed_category_description(new_description)
          {repos, {category, new_description}}

      end) #END Enum.reduce
      |> case do
        {repos, _} -> repos
      end
  end

  def file(path) do
    path
    |> File.stream!()
    |> string()
  end

  defp parsed_category_description(string) do
    [result] = Regex.run(@category_description_re, string, capture: :first)
    result
  end

  defp parsed_repo_info(string), do:
    Regex.named_captures(@repo_info_re, string)

end
