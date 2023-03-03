defmodule KartVids.Races do
  @moduledoc """
  The Races context.
  """
  use Nebulex.Caching
  import Ecto.Query, warn: false
  import KartVids.Helpers
  alias KartVids.Repo

  alias KartVids.Races.{Racer, RacerProfile, Kart, Season}
  alias KartVids.Races.RacerProfile.Cache, as: RacerProfileCache

  @doc """
  Returns the list of karts.

  ## Examples

      iex> list_karts()
      [%Kart{}, ...]

  """
  def list_karts(location_id) do
    from(k in Kart, where: k.location_id == ^location_id, order_by: {:asc, k.kart_num})
    |> Repo.all()
  end

  @doc """
  Gets a single kart.

  Raises `Ecto.NoResultsError` if the Kart does not exist.

  ## Examples

      iex> get_kart!(123)
      %Kart{}

      iex> get_kart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kart!(id), do: Repo.get!(Kart, id)

  def find_kart_by_location_and_number(location_id, kart_num) do
    Repo.get_by(Kart, %{location_id: location_id, kart_num: kart_num})
  end

  @doc """
  Creates a kart.

  ## Examples

      iex> create_kart(:system, %{field: value})
      {:ok, %Kart{}}

      iex> create_kart(:system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kart(current_user, attrs \\ %{})

  def create_kart(:system, attrs) do
    %Kart{}
    |> Kart.changeset(attrs)
    |> Repo.insert()
    |> broadcast()
  end

  def create_kart(current_user, attrs) do
    admin_only(current_user) do
      create_kart(:system, attrs)
    end
  end

  @doc """
  Updates a kart.

  ## Examples

      iex> update_kart(:system, kart, %{field: new_value})
      {:ok, %Kart{}}

      iex> update_kart(:system, kart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kart(current_user, kart, attrs)

  def update_kart(:system, %Kart{} = kart, attrs) do
    kart
    |> Kart.changeset(attrs)
    |> Repo.update()
    |> broadcast()
  end

  def update_kart(current_user, %Kart{} = kart, attrs) do
    admin_only(current_user) do
      update_kart(:system, kart, attrs)
    end
  end

  @doc """
  Deletes a kart.

  ## Examples

      iex> delete_kart(kart)
      {:ok, %Kart{}}

      iex> delete_kart(kart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kart(current_user, kart)

  def delete_kart(:system, %Kart{} = kart) do
    Repo.delete(kart)
  end

  def delete_kart(current_user, kart) do
    admin_only(current_user) do
      delete_kart(:system, kart)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kart changes.

  ## Examples

      iex> change_kart(kart)
      %Ecto.Changeset{data: %Kart{}}

  """
  def change_kart(%Kart{} = kart, attrs \\ %{}) do
    Kart.changeset(kart, attrs)
  end

  def broadcast({:ok, %Kart{} = kart} = result) do
    KartVidsWeb.Endpoint.broadcast!(
      kart_topic_name(kart.location_id, kart.kart_num),
      "update",
      kart
    )

    KartVidsWeb.Endpoint.broadcast!(all_karts_topic_name(kart.location_id), "update", kart)

    result
  end

  def broadcast({:error, _} = result) do
    result
  end

  def all_karts_topic_name(location_id) do
    "location:#{location_id}:kart_stats"
  end

  def kart_topic_name(location_id, kart_num) do
    "location:#{location_id}:kart_stats:#{kart_num}"
  end

  alias KartVids.Races.Race

  @doc """
  Returns the list of races.

  ## Examples

      iex> list_races()
      [%Race{}, ...]

  """
  def list_races(location_id) do
    from(r in Race,
      where: r.location_id == ^location_id,
      order_by: {:desc, r.started_at},
      limit: 100
    )
    |> Repo.all()
  end

  @doc """
  Gets a single race.

  Raises `Ecto.NoResultsError` if the Race does not exist.

  ## Examples

      iex> get_race!(123)
      %Race{}

      iex> get_race!(456)
      ** (Ecto.NoResultsError)

  """
  def get_race!(id), do: Repo.get!(Race, id)

  @doc """
  Creates a race.

  ## Examples

      iex> create_race(:system, %{field: value})
      {:ok, %Race{}}

      iex> create_race(:system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_race(current_user, attrs \\ %{})

  def create_race(:system, attrs) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert()
  end

  def create_race(current_user, attrs) do
    admin_only(current_user) do
      create_race(:system, attrs)
    end
  end

  @doc """
  Updates a race.

  ## Examples

      iex> update_race(:system, race, %{field: new_value})
      {:ok, %Race{}}

      iex> update_race(:system, race, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_race(current_user, race, attrs)

  def update_race(:system, %Race{} = race, attrs) do
    race
    |> Race.changeset(attrs)
    |> Repo.update()
  end

  def update_race(current_user, %Race{} = race, attrs) do
    admin_only(current_user) do
      update_race(:system, race, attrs)
    end
  end

  @doc """
  Deletes a race.

  ## Examples

      iex> delete_race(:system, race)
      {:ok, %Race{}}

      iex> delete_race(:system, race)
      {:error, %Ecto.Changeset{}}

  """
  def delete_race(current_user, race)

  def delete_race(current_user, %Race{} = race) do
    admin_only(current_user) do
      delete_race(:system, race)
    end
  end

  def delete_race(:system, %Race{} = race) do
    Repo.delete(race)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking race changes.

  ## Examples

      iex> change_race(race)
      %Ecto.Changeset{data: %Race{}}

  """
  def change_race(%Race{} = race, attrs \\ %{}) do
    Race.changeset(race, attrs)
  end

  def transaction(func) do
    Repo.transaction(func)
  end

  def persist(multi) do
    Repo.transaction(multi)
  end

  defmodule League do
    @moduledoc false
    defstruct date: DateTime.utc_now() |> DateTime.to_date(), races: 0, racer_names: []
  end

  defimpl Phoenix.Param, for: League do
    def to_param(league) do
      Date.to_string(league.date)
    end
  end

  def leagues() do
    query =
      from(race in Race,
        where: race.league? == true,
        join: racer in Racer,
        on: racer.race_id == race.id,
        group_by: fragment("?::date", race.started_at),
        order_by: {:desc, fragment("?::date", race.started_at)}
      )

    from([race, racer] in query,
      select: %League{
        date: fragment("?::date", race.started_at),
        races: count(race.id, :distinct),
        racer_names: fragment("array_agg(distinct ?)", racer.nickname)
      }
    )
    |> Repo.all()
  end

  def league_races_on_date(%Date{} = date) do
    tomorrow = Date.add(date, 1)

    from(r in Race,
      where:
        r.league? == true and
          (fragment("?::date", r.started_at) == ^date or
             fragment("?::date", r.started_at) == ^tomorrow),
      order_by: {:desc, r.started_at}
    )
    |> Repo.all()
    |> Repo.preload(:racers)
  end

  @doc """
  Returns the list of racers.

  ## Examples

      iex> list_racers()
      [%Racer{}, ...]

  """
  def list_racers(race_id) do
    from(r in Racer, where: r.race_id == ^race_id, order_by: r.position)
    |> Repo.all()
  end

  @doc """
  Gets a single racer.

  Raises `Ecto.NoResultsError` if the Racer does not exist.

  ## Examples

      iex> get_racer!(123)
      %Racer{}

      iex> get_racer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_racer!(id), do: Repo.get!(Racer, id)

  def list_races_by_nickname(nickname) do
    from(r in Racer,
      where: fragment("lower(?) = ?", r.nickname, ^String.downcase(nickname)),
      order_by: {:desc, r.inserted_at}
    )
    |> Repo.all()
    |> Repo.preload(:race)
  end

  def autocomplete_racer_nickname(search) do
    from(r in RacerProfile,
      where: fragment("nickname_vector @@ to_tsquery(quote_literal(?) || ':*')", ^search),
      select: {r.nickname, r.id, r.photo},
      distinct: true,
      limit: 5
    )
    |> Repo.all()
  end

  @doc """
  Creates a racer.

  ## Examples

      iex> create_racer(:system, %{field: value})
      {:ok, %Racer{}}

      iex> create_racer(:system, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_racer(current_user, attrs \\ %{})

  def create_racer(:system, attrs) do
    %Racer{}
    |> Racer.changeset(attrs)
    |> Repo.insert()
  end

  def create_racer(current_user, attrs) do
    admin_only(current_user) do
      create_racer(:system, attrs)
    end
  end

  @doc """
  Updates a racer.

  ## Examples

      iex> update_racer(:system, racer, %{field: new_value})
      {:ok, %Racer{}}

      iex> update_racer(:system, racer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_racer(current_user, racer, attrs)

  def update_racer(:system, %Racer{} = racer, attrs) do
    racer
    |> Racer.changeset(attrs)
    |> Repo.update()
  end

  def update_racer(current_user, %Racer{} = racer, attrs) do
    admin_only(current_user) do
      update_racer(:system, racer, attrs)
    end
  end

  @doc """
  Deletes a racer.

  ## Examples

      iex> delete_racer(racer)
      {:ok, %Racer{}}

      iex> delete_racer(racer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_racer(current_user, racer)

  def delete_racer(:system, %Racer{} = racer) do
    Repo.delete(racer)
  end

  def delete_racer(current_user, %Racer{} = racer) do
    admin_only(current_user) do
      delete_racer(:system, racer)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking racer changes.

  ## Examples

      iex> change_racer(racer)
      %Ecto.Changeset{data: %Racer{}}

  """
  def change_racer(%Racer{} = racer, attrs \\ %{}) do
    Racer.changeset(racer, attrs)
  end

  @doc """
  Creates or updates a racer profile with the given attributes.

  ## Examples

      iex> upsert_racer_profile(%{fastest_lap_time: 19.23, nickname: "Speedy", photo: "https://images.com/speedy.jpg"})
      {:ok, %RacerProfile{}}
  """
  def upsert_racer_profile(attrs) do
    profile = get_racer_profile_by_attrs(attrs)

    if profile do
      fastest_lap_time = profile.fastest_lap_time
      attrs_fastest_lap = attrs["fastest_lap_time"] || attrs[:fastest_lap_time]

      attrs =
        if fastest_lap_time < attrs_fastest_lap do
          Map.drop(attrs, [:fastest_lap_time, :fastest_lap_kart, :fastest_lap_race_id, "fastest_lap_time", "fastest_lap_kart", "fastest_lap_race_id"])
        else
          attrs
        end

      update_racer_profile(profile, attrs)
    else
      create_racer_profile(attrs)
    end
  end

  @doc """
  Creates a racer profile.

  ## Examples

      iex> create_racer_profile(%{field: value})
      {:ok, %RacerProfile{}}

      iex> create_racer_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_racer_profile(attrs) do
    %RacerProfile{}
    |> RacerProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single racer profile.

  Raises `Ecto.NoResultsError` if the RacerProfile does not exist.

  ## Examples

      iex> get_racer_profile!(123)
      %RacerProfile{}

      iex> get_racer_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_racer_profile!(id), do: Repo.get!(RacerProfile, id) |> Repo.preload(races: [:race])

  def get_racer_profiles!(ids) when is_list(ids) do
    from(r in RacerProfile, where: r.id in ^ids)
    |> Repo.all()
  end

  def get_racer_profile_by_attrs(%{"nickname" => nickname, "photo" => photo}), do: get_racer_profile_by_attrs(nickname, photo)

  def get_racer_profile_by_attrs(%{nickname: nickname, photo: photo}) when not is_nil(nickname) and not is_nil(photo) do
    get_racer_profile_by_attrs(nickname, photo)
  end

  def get_racer_profile_by_attrs(_), do: nil

  @spec get_racer_profile_by_attrs(String.t(), String.t()) :: RacerProfile.t()
  def get_racer_profile_by_attrs(nickname, photo) do
    query_racer_profile_by_attrs(nickname, photo)
    |> limit(1)
    |> Repo.one()
  end

  @racer_profile_ttl :timer.hours(1)
  @decorate cacheable(cache: RacerProfileCache, key: {RacerProfile, {nickname, photo}}, opts: [ttl: @racer_profile_ttl])
  @spec get_racer_profile_id(String.t(), String.t()) :: pos_integer()
  def get_racer_profile_id(nickname, photo) do
    from(r in query_racer_profile_by_attrs(nickname, photo), select: r.id, limit: 1)
    |> Repo.one()
  end

  defp query_racer_profile_by_attrs(nickname, photo, query \\ RacerProfile) do
    from(r in query, or_where: r.nickname == ^nickname and r.photo == ^photo)
  end

  @doc """
  Updates a racer profile.

  ## Examples

      iex> update_racer_profile(racer_profile, %{field: new_value})
      {:ok, %RacerProfile{}}

      iex> update_racer_profile(racer_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_racer_profile(%RacerProfile{} = racer_profile, attrs) do
    racer_profile
    |> RacerProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a racer profile.

  ## Examples

      iex> delete_racer_profile(racer_profile)
      {:ok, %RacerProfile{}}

      iex> delete_racer_profile(racer_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_racer_profile(%RacerProfile{} = racer_profile) do
    Repo.delete(racer_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking racer profile changes.

  ## Examples

      iex> change_racer_profile(racer_profile)
      %Ecto.Changeset{data: %RacerProfile{}}

  """
  def change_racer_profile(%RacerProfile{} = racer_profile, attrs \\ %{}) do
    RacerProfile.changeset(racer_profile, attrs)
  end

  @doc """
  Returns the list of active seasons.

  ## Examples

      iex> list_active_seasons()
      [%Kart{}, ...]

  """
  def list_active_seasons() do
    from(s in Season, where: s.ended == false)
    |> Repo.all()
  end

  @doc """
  Gets a single season.

  Raises `Ecto.NoResultsError` if the Season does not exist.

  ## Examples

      iex> get_season!(123)
      %Kart{}

      iex> get_season!(456)
      ** (Ecto.NoResultsError)

  """
  def get_season!(id), do: Repo.get!(Season, id)

  @doc """
  Creates a Season.

  ## Examples

      iex> create_season(%{field: value})
      {:ok, %Season{}}

      iex> create_season(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_season(attrs) do
    %Season{}
    |> Season.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a season.

  ## Examples

      iex> update_season(season, %{field: new_value})
      {:ok, %Season{}}

      iex> update_season(season, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_season(%Season{} = season, attrs) do
    season
    |> Season.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a season.

  ## Examples

      iex> delete_season(season)
      {:ok, %Season{}}

      iex> delete_season(season)
      {:error, %Ecto.Changeset{}}

  """
  def delete_season(%Season{} = season) do
    Repo.delete(season)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking season changes.

  ## Examples

      iex> change_season(season)
      %Ecto.Changeset{data: %Season{}}

  """
  def change_season(%Season{} = season, attrs \\ %{}) do
    Season.changeset(season, attrs)
  end
end
