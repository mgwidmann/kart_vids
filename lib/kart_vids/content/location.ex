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
    field :timezone, :string
    field :image_url, :string
    field :websocket_url, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :street, :street_2, :city, :state, :code, :country, :adult_kart_min, :adult_kart_max, :junior_kart_min, :junior_kart_max, :timezone, :image_url, :websocket_url])
    |> validate_required([:name, :street, :city, :state, :code, :country, :adult_kart_min, :adult_kart_max, :junior_kart_min, :junior_kart_max, :timezone, :image_url, :websocket_url])
    |> validate_timezone()
  end

  def validate_timezone(changeset) do
    timezone = get_change(changeset, :timezone)

    if timezone do
      if Tzdata.zone_exists?(timezone) do
        changeset
      else
        add_error(changeset, :timezone, "Time zone does not exist, please enter a valid timezone.")
      end
    else
      changeset
    end
  end
end
