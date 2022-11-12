defmodule KartVids.Content.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :duration_seconds, :integer
    field :location, :string
    field :name, :string
    field :recorded_on, :utc_datetime
    field :size, :float
    field :mime_type, :string

    timestamps()
  end

  # Milliseconds to seconds
  @max_duration_seconds :timer.hours(1) / 1000
  @megabyte 1_000_000
  @max_size_bytes 500 * @megabyte

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:location, :duration_seconds, :size, :name, :description, :recorded_on])
    |> validate_required([
      :location,
      :duration_seconds,
      :size,
      :name,
      :description,
      :recorded_on
    ])
    |> validate_length(:location, max: 1000)
    |> validate_number(:duration_seconds, less_than: @max_duration_seconds)
    |> validate_length(:description, max: 5000)
    |> validate_number(:size, less_than: @max_size_bytes)
    |> validate_length(:name, max: 500)
    |> validate_length(:mime_type, max: 100)
  end
end
