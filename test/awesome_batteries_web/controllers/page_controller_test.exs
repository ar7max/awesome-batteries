defmodule AwesomeBatteriesWeb.PageControllerTest do
  use AwesomeBatteriesWeb.ConnCase

  import AwesomeBatteries

  setup do
    import_data("test.md")
    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    response = html_response(conn, 200)

    for repo <- fetch_repos() do
      assert response =~ repo.owner
      assert response =~ repo.name
    end

  end
end
