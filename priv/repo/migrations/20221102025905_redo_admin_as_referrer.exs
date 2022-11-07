defmodule KartVids.Repo.Migrations.RedoAdminAsReferrer do
  use Ecto.Migration
  alias KartVids.Accounts

  def up do
    {:ok, user} =
      Accounts.register_user(
        %{
          email: System.get_env("ADMIN_EMAIL", "admin@kart-vids.com"),
          password: System.get_env("ADMIN_PASSWORD", "AdminPa$$word"),
          password_confirmation: System.get_env("ADMIN_PASSWORD", "AdminPa$$word"),
          referred_by: System.get_env("ADMIN_EMAIL", "admin@kart-vids.com")
        },
        validate_referrer: false
      )

    # If it doesn't exist in production, thats ok
    try do
      apply(Accounts, :make_admin!, [user])
    rescue
      # Ignore error
      _ -> nil
    end
  end

  def down do
    Accounts.delete_user(System.get_env("ADMIN_EMAIL", "admin@kart-vids.com"))
  end
end
