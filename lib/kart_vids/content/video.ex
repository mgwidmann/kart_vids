defmodule KartVids.Content.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :duration_seconds, :integer
    field :location, :string
    field :name, :string
    field :recorded_on, :utc_datetime
    field :size_mb, :float

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:location, :duration_seconds, :size_mb, :name, :description, :recorded_on])
    |> validate_required([
      :location,
      :duration_seconds,
      :size_mb,
      :name,
      :description,
      :recorded_on
    ])
  end
end
