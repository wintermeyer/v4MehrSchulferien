defmodule MehrSchulferien.TimetablesTest do
  use MehrSchulferien.DataCase

  alias MehrSchulferien.Timetables

  describe "years" do
    alias MehrSchulferien.Timetables.Year

    @valid_attrs %{slug: "some slug", value: 42}
    @update_attrs %{slug: "some updated slug", value: 43}
    @invalid_attrs %{slug: nil, value: nil}

    def year_fixture(attrs \\ %{}) do
      {:ok, year} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timetables.create_year()

      year
    end

    test "list_years/0 returns all years" do
      year = year_fixture()
      assert Timetables.list_years() == [year]
    end

    test "get_year!/1 returns the year with given id" do
      year = year_fixture()
      assert Timetables.get_year!(year.id) == year
    end

    test "create_year/1 with valid data creates a year" do
      assert {:ok, %Year{} = year} = Timetables.create_year(@valid_attrs)
      assert year.slug == "some slug"
      assert year.value == 42
    end

    test "create_year/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timetables.create_year(@invalid_attrs)
    end

    test "update_year/2 with valid data updates the year" do
      year = year_fixture()
      assert {:ok, year} = Timetables.update_year(year, @update_attrs)
      assert %Year{} = year
      assert year.slug == "some updated slug"
      assert year.value == 43
    end

    test "update_year/2 with invalid data returns error changeset" do
      year = year_fixture()
      assert {:error, %Ecto.Changeset{}} = Timetables.update_year(year, @invalid_attrs)
      assert year == Timetables.get_year!(year.id)
    end

    test "delete_year/1 deletes the year" do
      year = year_fixture()
      assert {:ok, %Year{}} = Timetables.delete_year(year)
      assert_raise Ecto.NoResultsError, fn -> Timetables.get_year!(year.id) end
    end

    test "change_year/1 returns a year changeset" do
      year = year_fixture()
      assert %Ecto.Changeset{} = Timetables.change_year(year)
    end
  end

  describe "months" do
    alias MehrSchulferien.Timetables.Month

    @valid_attrs %{slug: "some slug", value: 42}
    @update_attrs %{slug: "some updated slug", value: 43}
    @invalid_attrs %{slug: nil, value: nil}

    def month_fixture(attrs \\ %{}) do
      {:ok, month} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timetables.create_month()

      month
    end

    test "list_months/0 returns all months" do
      month = month_fixture()
      assert Timetables.list_months() == [month]
    end

    test "get_month!/1 returns the month with given id" do
      month = month_fixture()
      assert Timetables.get_month!(month.id) == month
    end

    test "create_month/1 with valid data creates a month" do
      assert {:ok, %Month{} = month} = Timetables.create_month(@valid_attrs)
      assert month.slug == "some slug"
      assert month.value == 42
    end

    test "create_month/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timetables.create_month(@invalid_attrs)
    end

    test "update_month/2 with valid data updates the month" do
      month = month_fixture()
      assert {:ok, month} = Timetables.update_month(month, @update_attrs)
      assert %Month{} = month
      assert month.slug == "some updated slug"
      assert month.value == 43
    end

    test "update_month/2 with invalid data returns error changeset" do
      month = month_fixture()
      assert {:error, %Ecto.Changeset{}} = Timetables.update_month(month, @invalid_attrs)
      assert month == Timetables.get_month!(month.id)
    end

    test "delete_month/1 deletes the month" do
      month = month_fixture()
      assert {:ok, %Month{}} = Timetables.delete_month(month)
      assert_raise Ecto.NoResultsError, fn -> Timetables.get_month!(month.id) end
    end

    test "change_month/1 returns a month changeset" do
      month = month_fixture()
      assert %Ecto.Changeset{} = Timetables.change_month(month)
    end
  end
end
