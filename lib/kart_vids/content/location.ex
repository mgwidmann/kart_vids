defmodule KartVids.Content.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :city, :string
    field :code, :string
    field :country, :string
    field :name, :string
    field :state, :string
    field :street, :string
    field :street_2, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :street, :street_2, :city, :state, :code, :country])
    |> validate_required([:name, :street, :city, :state, :code, :country])
  end
end
