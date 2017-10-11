defmodule MehrSchulferienWeb.BeweglicherFerientagControllerTest do
  use MehrSchulferienWeb.ConnCase

  alias MehrSchulferien.Timetables

  @create_attrs %{value: 42}
  @update_attrs %{value: 43}
  @invalid_attrs %{value: nil}

  def fixture(:beweglicher_ferientag) do
    {:ok, beweglicher_ferientag} = Timetables.create_beweglicher_ferientag(@create_attrs)
    beweglicher_ferientag
  end

  describe "index" do
    test "lists all bewegliche_ferientage", %{conn: conn} do
      conn = get conn, beweglicher_ferientag_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Bewegliche ferientage"
    end
  end

  describe "new beweglicher_ferientag" do
    test "renders form", %{conn: conn} do
      conn = get conn, beweglicher_ferientag_path(conn, :new)
      assert html_response(conn, 200) =~ "New Beweglicher ferientag"
    end
  end

  describe "create beweglicher_ferientag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, beweglicher_ferientag_path(conn, :create), beweglicher_ferientag: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == beweglicher_ferientag_path(conn, :show, id)

      conn = get conn, beweglicher_ferientag_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Beweglicher ferientag"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, beweglicher_ferientag_path(conn, :create), beweglicher_ferientag: @invalid_attrs
      assert html_response(conn, 200) =~ "New Beweglicher ferientag"
    end
  end

  describe "edit beweglicher_ferientag" do
    setup [:create_beweglicher_ferientag]

    test "renders form for editing chosen beweglicher_ferientag", %{conn: conn, beweglicher_ferientag: beweglicher_ferientag} do
      conn = get conn, beweglicher_ferientag_path(conn, :edit, beweglicher_ferientag)
      assert html_response(conn, 200) =~ "Edit Beweglicher ferientag"
    end
  end

  describe "update beweglicher_ferientag" do
    setup [:create_beweglicher_ferientag]

    test "redirects when data is valid", %{conn: conn, beweglicher_ferientag: beweglicher_ferientag} do
      conn = put conn, beweglicher_ferientag_path(conn, :update, beweglicher_ferientag), beweglicher_ferientag: @update_attrs
      assert redirected_to(conn) == beweglicher_ferientag_path(conn, :show, beweglicher_ferientag)

      conn = get conn, beweglicher_ferientag_path(conn, :show, beweglicher_ferientag)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, beweglicher_ferientag: beweglicher_ferientag} do
      conn = put conn, beweglicher_ferientag_path(conn, :update, beweglicher_ferientag), beweglicher_ferientag: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Beweglicher ferientag"
    end
  end

  describe "delete beweglicher_ferientag" do
    setup [:create_beweglicher_ferientag]

    test "deletes chosen beweglicher_ferientag", %{conn: conn, beweglicher_ferientag: beweglicher_ferientag} do
      conn = delete conn, beweglicher_ferientag_path(conn, :delete, beweglicher_ferientag)
      assert redirected_to(conn) == beweglicher_ferientag_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, beweglicher_ferientag_path(conn, :show, beweglicher_ferientag)
      end
    end
  end

  defp create_beweglicher_ferientag(_) do
    beweglicher_ferientag = fixture(:beweglicher_ferientag)
    {:ok, beweglicher_ferientag: beweglicher_ferientag}
  end
end
