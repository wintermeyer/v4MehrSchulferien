defmodule MehrSchulferien.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias MehrSchulferien.Repo

  alias MehrSchulferien.Users.Religion

  @doc """
  Returns the list of religions.

  ## Examples

      iex> list_religions()
      [%Religion{}, ...]

  """
  def list_religions do
    Repo.all(Religion)
  end

  @doc """
  Gets a single religion by id or slug.

  Raises `Ecto.NoResultsError` if the Religion does not exist.

  ## Examples

      iex> get_religion!(123)
      %Religion{}

      iex> get_religion!("Katholisch")
      %Religion{}

      iex> get_religion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_religion!(id_or_slug) do
    case is_integer(id_or_slug) or Regex.match?(~r/^[1-9][0-9]*$/, id_or_slug) do
      true ->
        Repo.get!(Religion, id_or_slug)
      false ->
        query = from f in Religion, where: f.slug == ^id_or_slug
        Repo.one!(query)
    end
  end

  @doc """
  Creates a religion.

  ## Examples

      iex> create_religion(%{field: value})
      {:ok, %Religion{}}

      iex> create_religion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_religion(attrs \\ %{}) do
    %Religion{}
    |> Religion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a religion.

  ## Examples

      iex> update_religion(religion, %{field: new_value})
      {:ok, %Religion{}}

      iex> update_religion(religion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_religion(%Religion{} = religion, attrs) do
    religion
    |> Religion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Religion.

  ## Examples

      iex> delete_religion(religion)
      {:ok, %Religion{}}

      iex> delete_religion(religion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_religion(%Religion{} = religion) do
    Repo.delete(religion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking religion changes.

  ## Examples

      iex> change_religion(religion)
      %Ecto.Changeset{source: %Religion{}}

  """
  def change_religion(%Religion{} = religion) do
    Religion.changeset(religion, %{})
  end
end
