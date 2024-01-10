defmodule KartVids.Content.Location do
  use Ecto.Schema
  import Ecto.Changeset

  # https://autobahn-livescore.herokuapp.com/?track=1&location=aisdulles
  # TODO: Add locations
  # https://autobahn-livescore.herokuapp.com/?track=1&location=aismanassas adult min: 1 max: 39, junior min: 40 max: 50
  # https://autobahn-livescore.herokuapp.com/?track=1&location=aisbaltimore adult min: 1 max: 49, junior min: 50 max: 69, adult extras: 71, 72, 73, 74
  # https://autobahn-livescore.herokuapp.com/?track=2&location=aisbaltimore (fast track) adult min: 1 max: 49, junior min: 50 max: 69, adult extras: 71, 72, 73, 74
  # https://autobahn-livescore.herokuapp.com/?track=1&location=aiswhitemarsh adult min: 1 max: 29, junior min: 30 max: 70

  # INSERT INTO LOCATIONS(NAME, STREET, CITY, STATE, CODE, COUNTRY, INSERTED_AT, UPDATED_AT, ADULT_KART_MIN, ADULT_KART_MAX, JUNIOR_KART_MIN, JUNIOR_KART_MAX, TIMEZONE, IMAGE_URL, WEBSOCKET_URL, MIN_LAP_TIME, MAX_LAP_TIME)
  # VALUES ('Autobahn Speedway Manassas', '8300 Sudley Rd A5', 'Manassas', 'VA', '20109', 'USA', '2023-12-01 03:58:51', '2023-12-01 03:58:51', 1, 39, 40, 50, 'America/New_York', 'https://autobahnspeed.com/wp-content/uploads/2023/04/AUT17047_Autobahn-LogoUpdate-CMYK-MECH__Autobahn-Logotype-RedWhite.png', 'ws://autobahn-livescore.herokuapp.com/?track=1&location=aismanassas', 15, 25);
  # INSERT INTO LOCATIONS(NAME, STREET, CITY, STATE, CODE, COUNTRY, INSERTED_AT, UPDATED_AT, ADULT_KART_MIN, ADULT_KART_MAX, JUNIOR_KART_MIN, JUNIOR_KART_MAX, TIMEZONE, IMAGE_URL, WEBSOCKET_URL, MIN_LAP_TIME, MAX_LAP_TIME)
  # VALUES ('Autobahn Speedway Jessup Monaco', '8251 Preston Ct', 'Jessup', 'MD', '20794', 'USA', '2023-12-01 04:01:32', '2023-12-01 04:01:32', 1, 49, 50, 69, 'America/New_York', 'https://autobahnspeed.com/wp-content/uploads/2023/04/AUT17047_Autobahn-LogoUpdate-CMYK-MECH__Autobahn-Logotype-RedWhite.png', 'ws://autobahn-livescore.herokuapp.com/?track=1&location=aisbaltimore', 15, 25);
  # INSERT INTO LOCATIONS(NAME, STREET, CITY, STATE, CODE, COUNTRY, INSERTED_AT, UPDATED_AT, ADULT_KART_MIN, ADULT_KART_MAX, JUNIOR_KART_MIN, JUNIOR_KART_MAX, TIMEZONE, IMAGE_URL, WEBSOCKET_URL, MIN_LAP_TIME, MAX_LAP_TIME)
  # VALUES ('Autobahn Speedway Jessup Le Mans', '8251 Preston Ct', 'Jessup', 'MD', '20794', 'USA', '2023-12-01 04:03:14', '2023-12-01 04:03:14', 1, 49, 50, 69, 'America/New_York', 'https://autobahnspeed.com/wp-content/uploads/2023/04/AUT17047_Autobahn-LogoUpdate-CMYK-MECH__Autobahn-Logotype-RedWhite.png', 'ws://autobahn-livescore.herokuapp.com/?track=2&location=aisbaltimore', 13, 25);
  # INSERT INTO LOCATIONS(NAME, STREET, CITY, STATE, CODE, COUNTRY, INSERTED_AT, UPDATED_AT, ADULT_KART_MIN, ADULT_KART_MAX, JUNIOR_KART_MIN, JUNIOR_KART_MAX, TIMEZONE, IMAGE_URL, WEBSOCKET_URL, MIN_LAP_TIME, MAX_LAP_TIME)
  # VALUES ('Autobahn Speedway White Marsh', '8415 Kelso Dr Ste 100', 'Essex', 'MD', '21211', 'USA', '2023-12-01 04:17:15', '2023-12-01 04:17:15', 1, 29, 30, 70, 'America/New_York', 'https://autobahnspeed.com/wp-content/uploads/2023/04/AUT17047_Autobahn-LogoUpdate-CMYK-MECH__Autobahn-Logotype-RedWhite.png', 'ws://autobahn-livescore.herokuapp.com/?track=1&location=aiswhitemarsh', 15, 25);

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
    field :adult_kart_reset_on, :date
    field :junior_kart_reset_on, :date
    field :min_lap_time, :float
    field :max_lap_time, :float

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [
      :name,
      :street,
      :street_2,
      :city,
      :state,
      :code,
      :country,
      :adult_kart_min,
      :adult_kart_max,
      :junior_kart_min,
      :junior_kart_max,
      :timezone,
      :image_url,
      :websocket_url,
      :adult_kart_reset_on,
      :junior_kart_reset_on,
      :min_lap_time,
      :max_lap_time
    ])
    |> validate_required([:name, :street, :city, :state, :code, :country, :adult_kart_min, :adult_kart_max, :junior_kart_min, :junior_kart_max, :timezone, :image_url, :websocket_url, :min_lap_time, :max_lap_time])
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
