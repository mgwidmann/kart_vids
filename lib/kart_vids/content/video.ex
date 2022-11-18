defmodule KartVids.Content.Video do
  use Ecto.Schema
  import Ecto.Changeset

  alias KartVids.Content.Location
  alias KartVids.Accounts.User

  schema "videos" do
    field :description, :string
    field :duration_seconds, :integer
    field :name, :string
    field :recorded_on, :utc_datetime
    field :size, :integer
    field :mime_type, :string
    field :s3_path, :string
    field :youtube_url, :string
    field :is_deleted?, :boolean, default: false, source: :is_deleted
    field :deleted_at, :utc_datetime

    belongs_to :location, Location
    belongs_to :user, User

    timestamps()
  end

  # Milliseconds to seconds
  @max_duration_seconds :timer.hours(1) / 1000
  @megabyte 1_000_000
  @max_size_bytes 100 * @megabyte

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs |> convert_duration(), [:location_id, :duration_seconds, :size, :name, :description, :recorded_on, :s3_path, :youtube_url])
    |> validate_required([
      :location_id,
      :duration_seconds,
      :size,
      :name,
      :recorded_on
    ])
    |> validate_length(:s3_path, max: 1000)
    |> validate_number(:duration_seconds, less_than: @max_duration_seconds)
    |> validate_length(:description, max: 5000)
    |> validate_number(:size, less_than: @max_size_bytes)
    |> validate_length(:name, max: 500)
    |> validate_length(:mime_type, max: 100)
  end

  def maximum_size_bytes(), do: @max_size_bytes

  def convert_duration(%{"duration_seconds" => seconds} = attrs) when is_float(seconds) do
    %{attrs | "duration_seconds" => trunc(seconds)}
  end

  def convert_duration(%{duration_seconds: seconds} = attrs) when is_float(seconds) do
    %{attrs | duration_seconds: trunc(seconds)}
  end

  def convert_duration(%{"duration_seconds" => ""} = attrs), do: attrs
  def convert_duration(%{duration_seconds: ""} = attrs), do: attrs

  def convert_duration(%{"duration_seconds" => seconds} = attrs) when is_binary(seconds) do
    {seconds, _} = Float.parse(seconds)
    %{attrs | "duration_seconds" => trunc(seconds)}
  end

  def convert_duration(%{duration_seconds: seconds} = attrs) when is_binary(seconds) do
    {seconds, _} = Float.parse(seconds)
    %{attrs | duration_seconds: trunc(seconds)}
  end

  def convert_duration(attrs), do: attrs
end
