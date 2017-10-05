defmodule MehrSchulferien.Timetables do
  @moduledoc """
  The Timetables context.
  """

  import Ecto.Query, warn: false
  alias MehrSchulferien.Repo

  alias MehrSchulferien.Timetables.Year

  @doc """
  Returns the list of years.

  ## Examples

      iex> list_years()
      [%Year{}, ...]

  """
  def list_years do
    Repo.all(Year)
  end

  @doc """
  Gets a single year by id or slug.

  Raises `Ecto.NoResultsError` if the Year does not exist.

  ## Examples

      iex> get_year!(123)
      %Year{}

      iex> get_year!("2017")
      %Year{}

      iex> get_year!(456)
      ** (Ecto.NoResultsError)

  """
  def get_year!(id_or_slug) do
    query = case is_integer(id_or_slug) do
              true -> as_string = Integer.to_string(id_or_slug)
                   from y in Year, where: y.slug == ^as_string
              _ -> from y in Year, where: y.slug == ^id_or_slug
            end
    year = Repo.one(query)

    case year do
      nil -> Repo.get!(Year, id_or_slug)
      _ -> year
    end
  end

  @doc """
  Creates a year.

  ## Examples

      iex> create_year(%{field: value})
      {:ok, %Year{}}

      iex> create_year(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_year(attrs \\ %{}) do
    %Year{}
    |> Year.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a year.

  ## Examples

      iex> update_year(year, %{field: new_value})
      {:ok, %Year{}}

      iex> update_year(year, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_year(%Year{} = year, attrs) do
    year
    |> Year.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Year.

  ## Examples

      iex> delete_year(year)
      {:ok, %Year{}}

      iex> delete_year(year)
      {:error, %Ecto.Changeset{}}

  """
  def delete_year(%Year{} = year) do
    Repo.delete(year)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking year changes.

  ## Examples

      iex> change_year(year)
      %Ecto.Changeset{source: %Year{}}

  """
  def change_year(%Year{} = year) do
    Year.changeset(year, %{})
  end
end
