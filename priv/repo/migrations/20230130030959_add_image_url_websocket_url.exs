defmodule KartVids.Repo.Migrations.AddImageUrlWebsocketUrl do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :image_url, :string,
        null: false,
        default:
          "https://autobahnspeed.com/wp-content/themes/autobahn/assets/images/logos/new/redwhite.svg"

      add :websocket_url, :string,
        null: false,
        default: "ws://autobahn-livescore.herokuapp.com/?track=1&location=aisdulles"
    end
  end
end
