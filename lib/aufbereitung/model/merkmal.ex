defmodule Aufbereitung.Model.Merkmal do
  alias Aufbereitung.Model.Merkmal, as: Merkmal

  defstruct id: nil,
            typ: nil,
            data: nil

  # --------------------------------------------------------------------------------------------------
  # New
  # --------------------------------------------------------------------------------------------------
  @spec new_logisch(number, :egal | :erfuellt | :nicht_erfuellt) :: Aufbereitung.Model.Merkmal.t()
  def new_logisch(id, erfuellung)
      when is_number(id) and
             (erfuellung === :erfuellt or
                erfuellung === :nicht_erfuellt or
                erfuellung === :egal) do
    %Merkmal{id: id, typ: :logisch, data: erfuellung}
  end

  @spec new_bereich(number, number, number) :: Aufbereitung.Model.Merkmal.t()
  def new_bereich(id, min, max)
      when is_number(id) and
             is_number(min) and
             is_number(max) and
             min <= max do
    %Merkmal{id: id, typ: :bereich, data: %{min: min, max: max}}
  end

  @spec new_auswahl(number, maybe_improper_list) :: Aufbereitung.Model.Merkmal.t()
  def new_auswahl(id, auspraegungen) when is_number(id) and is_list(auspraegungen) do
    %Merkmal{id: id, typ: :auswahl, data: auspraegungen |> MapSet.new()}
  end

  @spec new_selbstbeteiligung(number, maybe_improper_list) :: Aufbereitung.Model.Merkmal.t()
  def new_selbstbeteiligung(id, auspraegungen) when is_number(id) and is_list(auspraegungen) do
    %Merkmal{id: id, typ: :sb, data: auspraegungen |> MapSet.new()}
  end

  # --------------------------------------------------------------------------------------------------
  # Aufbereitung
  # --------------------------------------------------------------------------------------------------
  @spec hinzufuegen_wenn_nicht_vorhanden([Aufbereitung.Model.Merkmal.t()], Aufbereitung.Model.Merkmal.t()) :: [
          Aufbereitung.Model.Merkmal.t()
        ]
  def hinzufuegen_wenn_nicht_vorhanden(merkmale = [%Merkmal{}], neues_merkmal = %Merkmal{}) do
    case Enum.any?(merkmale, fn m -> m.id === neues_merkmal.id end) do
      true -> merkmale
      false -> [neues_merkmal | merkmale]
    end
  end

  def hinzufuegen_wenn_nicht_vorhanden([], neues_merkmal = %Merkmal{}) do
    [neues_merkmal]
  end

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Logisch
  # --------------------------------------------------------------------------------------------------
  @spec splitte(Aufbereitung.Model.Merkmal.t(), Aufbereitung.Model.Merkmal.t()) :: [Aufbereitung.Model.Merkmal.t()]
  def splitte(left = %Merkmal{data: erf}, left = %Merkmal{data: erf}) when erf !== :egal do
    [left]
  end

  def splitte(%Merkmal{id: id, typ: :logisch, data: :egal}, %Merkmal{id: id, typ: :logisch}) do
    [
      Merkmal.new_logisch(id, :erfuellt),
      Merkmal.new_logisch(id, :nicht_erfuellt)
    ]
  end

  def splitte(%Merkmal{id: id, typ: :logisch}, %Merkmal{id: id, typ: :logisch, data: :egal}) do
    [
      Merkmal.new_logisch(id, :erfuellt),
      Merkmal.new_logisch(id, :nicht_erfuellt)
    ]
  end

  def splitte(left = %Merkmal{id: id, typ: :logisch}, _ = %Merkmal{id: id, typ: :logisch}) do
    [left]
  end

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Bereich
  # --------------------------------------------------------------------------------------------------
  def splitte(m1 = %Merkmal{id: id, typ: :bereich, data: left}, %Merkmal{id: id, typ: :bereich, data: right}) do
    cond do
      right.max < left.min ->
        [m1]

      right.min > left.max ->
        [m1]

      right.min <= left.min and right.max >= left.max ->
        [m1]

      right.min <= left.min and right.max < left.max ->
        [
          %Merkmal{id: id, typ: :bereich, data: %{min: left.min, max: right.max}},
          %Merkmal{id: id, typ: :bereich, data: %{min: right.max + 1, max: left.max}}
        ]

      right.max < left.max ->
        [
          %Merkmal{id: id, typ: :bereich, data: %{min: left.min, max: right.min - 1}},
          %Merkmal{id: id, typ: :bereich, data: %{min: right.min, max: right.max}},
          %Merkmal{id: id, typ: :bereich, data: %{min: right.max + 1, max: left.max}}
        ]

      true ->
        [
          %Merkmal{id: id, typ: :bereich, data: %{min: left.min, max: right.min - 1}},
          %Merkmal{id: id, typ: :bereich, data: %{min: right.min, max: left.max}}
        ]
    end
  end

  # --------------------------------------------------------------------------------------------------
  # Split-Logik Auswahl und Selbstbeteiligung
  # --------------------------------------------------------------------------------------------------
  def splitte(m1 = %Merkmal{id: id, typ: typ, data: left}, %Merkmal{id: id, typ: typ, data: right}) when typ === :auswahl
                                                                                                      or typ === :sb do
    delta = MapSet.difference(left, right)
    intersection = MapSet.intersection(left, right)

    case MapSet.size(intersection) do
      0 -> [m1]

      _ ->
        [
          %Merkmal{m1 | data: intersection},
          %Merkmal{m1 | data: delta}
        ]
    end
  end
end
