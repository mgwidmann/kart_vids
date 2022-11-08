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
    field :adult_kart_min, :integer
    field :adult_kart_max, :integer
    field :junior_kart_min, :integer
    field :junior_kart_max, :integer

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :street, :street_2, :city, :state, :code, :country, :adult_kart_min, :adult_kart_max, :junior_kart_min, :junior_kart_max])
    |> validate_required([:name, :street, :city, :state, :code, :country, :adult_kart_min, :adult_kart_max, :junior_kart_min, :junior_kart_max])
  end
end
