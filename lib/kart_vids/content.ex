defmodule KartVids.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  import KartVids.Helpers
  alias KartVids.Repo

  alias KartVids.Content.Video
  alias KartVids.Accounts.User

  @original_video_storage_prefix "videos/originals"

  def user_originals_storage_prefix(%User{id: id}) do
    salt = Application.get_env(:kart_vids, :video_originals_storage_salt)
    if !salt, do: raise("Unconfigured originals storage prefix salt!")

    unique_identifier = :crypto.mac(:hmac, :sha256, salt, "#{id}-#{salt}") |> Base.encode64()

    "#{@original_video_storage_prefix}/user-#{id}-#{unique_identifier}/"
  end

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos(%User{id: id}), do: list_videos(id)

  def list_videos(current_user_id) when is_number(current_user_id) do
    from(v in Video, where: v.user_id == ^current_user_id and v.is_deleted? == false)
    |> Repo.all()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(%User{id: id}, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, id)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    video
    |> Video.changeset(%{})
    # Force changes which the changeset function does not allow to be altered
    |> Ecto.Changeset.put_change(:is_deleted?, true)
    |> Ecto.Changeset.put_change(:deleted_at, DateTime.utc_now())
    |> Repo.update!()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  alias KartVids.Content.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  def with_location(belongs_to_location), do: Repo.preload(belongs_to_location, :location)

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(:system, %{field: value})
      {:ok, %Location{}}

      iex> create_location(:system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(current_user, attrs \\ %{})

  def create_location(:system, attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def create_location(current_user, attrs) do
    admin_only(current_user) do
      create_location(:system, attrs)
    end
  end

  def create_location!(current_user, attrs \\ %{})

  def create_location!(:system, attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert!()
  end

  def create_location!(current_user, attrs) do
    admin_only(current_user) do
      create_location!(:system, attrs)
    end
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(:system, location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(:system, location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(current_user, location, attrs)

  def update_location(:system, %Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  def update_location(current_user, %Location{} = location, attrs) do
    admin_only(current_user) do
      update_location(:system, location, attrs)
    end
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(current_user, location)

  def delete_location(:system, %Location{} = location) do
    Repo.delete(location)
  end

  def delete_location(current_user, %Location{} = location) do
    admin_only(current_user) do
      delete_location(:system, location)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end
end
