defmodule MehrSchulferien.UsersTest do
  use MehrSchulferien.DataCase

  alias MehrSchulferien.Users

  describe "religions" do
    alias MehrSchulferien.Users.Religion

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def religion_fixture(attrs \\ %{}) do
      {:ok, religion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_religion()

      religion
    end

    test "list_religions/0 returns all religions" do
      religion = religion_fixture()
      assert Users.list_religions() == [religion]
    end

    test "get_religion!/1 returns the religion with given id" do
      religion = religion_fixture()
      assert Users.get_religion!(religion.id) == religion
    end

    test "create_religion/1 with valid data creates a religion" do
      assert {:ok, %Religion{} = religion} = Users.create_religion(@valid_attrs)
      assert religion.name == "some name"
      assert religion.slug == "some slug"
    end

    test "create_religion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_religion(@invalid_attrs)
    end

    test "update_religion/2 with valid data updates the religion" do
      religion = religion_fixture()
      assert {:ok, religion} = Users.update_religion(religion, @update_attrs)
      assert %Religion{} = religion
      assert religion.name == "some updated name"
      assert religion.slug == "some updated slug"
    end

    test "update_religion/2 with invalid data returns error changeset" do
      religion = religion_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_religion(religion, @invalid_attrs)
      assert religion == Users.get_religion!(religion.id)
    end

    test "delete_religion/1 deletes the religion" do
      religion = religion_fixture()
      assert {:ok, %Religion{}} = Users.delete_religion(religion)
      assert_raise Ecto.NoResultsError, fn -> Users.get_religion!(religion.id) end
    end

    test "change_religion/1 returns a religion changeset" do
      religion = religion_fixture()
      assert %Ecto.Changeset{} = Users.change_religion(religion)
    end
  end
end
