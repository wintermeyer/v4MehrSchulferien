defmodule MehrSchulferienWeb.ReligionControllerTest do
  use MehrSchulferienWeb.ConnCase

  alias MehrSchulferien.Users

  @create_attrs %{name: "some name", slug: "some slug"}
  @update_attrs %{name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{name: nil, slug: nil}

  def fixture(:religion) do
    {:ok, religion} = Users.create_religion(@create_attrs)
    religion
  end

  describe "index" do
    test "lists all religions", %{conn: conn} do
      conn = get conn, religion_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Religions"
    end
  end

  describe "new religion" do
    test "renders form", %{conn: conn} do
      conn = get conn, religion_path(conn, :new)
      assert html_response(conn, 200) =~ "New Religion"
    end
  end

  describe "create religion" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, religion_path(conn, :create), religion: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == religion_path(conn, :show, id)

      conn = get conn, religion_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Religion"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, religion_path(conn, :create), religion: @invalid_attrs
      assert html_response(conn, 200) =~ "New Religion"
    end
  end

  describe "edit religion" do
    setup [:create_religion]

    test "renders form for editing chosen religion", %{conn: conn, religion: religion} do
      conn = get conn, religion_path(conn, :edit, religion)
      assert html_response(conn, 200) =~ "Edit Religion"
    end
  end

  describe "update religion" do
    setup [:create_religion]

    test "redirects when data is valid", %{conn: conn, religion: religion} do
      conn = put conn, religion_path(conn, :update, religion), religion: @update_attrs
      assert redirected_to(conn) == religion_path(conn, :show, religion)

      conn = get conn, religion_path(conn, :show, religion)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, religion: religion} do
      conn = put conn, religion_path(conn, :update, religion), religion: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Religion"
    end
  end

  describe "delete religion" do
    setup [:create_religion]

    test "deletes chosen religion", %{conn: conn, religion: religion} do
      conn = delete conn, religion_path(conn, :delete, religion)
      assert redirected_to(conn) == religion_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, religion_path(conn, :show, religion)
      end
    end
  end

  defp create_religion(_) do
    religion = fixture(:religion)
    {:ok, religion: religion}
  end
end
