defmodule KartVids.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  alias KartVids.Repo

  alias KartVids.Races.Kart

  @doc """
  Returns the list of karts.

  ## Examples

      iex> list_karts()
      [%Kart{}, ...]

  """
  def list_karts do
    Repo.all(Kart)
  end

  @doc """
  Gets a single kart.

  Raises `Ecto.NoResultsError` if the Kart does not exist.

  ## Examples

      iex> get_kart!(123)
      %Kart{}

      iex> get_kart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kart!(id), do: Repo.get!(Kart, id)

  def find_kart_by_location_and_number(location_id, kart_num) do
    Repo.get_by(%{location_id: location_id, kart_num: kart_num})
  end

  @doc """
  Creates a kart.

  ## Examples

      iex> create_kart(%{field: value})
      {:ok, %Kart{}}

      iex> create_kart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kart(attrs \\ %{}) do
    %Kart{}
    |> Kart.changeset(attrs)
    |> Repo.insert()
    |> broadcast()
  end

  @doc """
  Updates a kart.

  ## Examples

      iex> update_kart(kart, %{field: new_value})
      {:ok, %Kart{}}

      iex> update_kart(kart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kart(%Kart{} = kart, attrs) do
    kart
    |> Kart.changeset(attrs)
    |> Repo.update()
    |> broadcast()
  end

  @doc """
  Deletes a kart.

  ## Examples

      iex> delete_kart(kart)
      {:ok, %Kart{}}

      iex> delete_kart(kart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kart(%Kart{} = kart) do
    Repo.delete(kart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kart changes.

  ## Examples

      iex> change_kart(kart)
      %Ecto.Changeset{data: %Kart{}}

  """
  def change_kart(%Kart{} = kart, attrs \\ %{}) do
    Kart.changeset(kart, attrs)
  end

  def broadcast(item) do
    IO.puts("KartVids.Endpoint.broadcast(#{inspect "location_1"}, #{inspect "kart_stats_1"}, item)")

    item
  end
end
