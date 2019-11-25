defmodule Aufbereitung.Model.Merkmal do
  alias Aufbereitung.Model.Merkmal, as: Merkmal

  defstruct id: nil,
            typ: nil,
            data: nil

  @spec new_logisch(integer, :egal | :erfuellt | :nicht_erfuellt) :: Aufbereitung.Model.Merkmal.t()
  def new_logisch(id, erfuellung) when is_number(id)
                                  and (erfuellung === :erfuellt
                                      or erfuellung === :nicht_erfuellt
                                      or erfuellung === :egal) do
    %Merkmal{id: id, typ: :logisch, data: erfuellung}
  end

  @spec new_bereich(integer, number, number) :: Aufbereitung.Model.Merkmal.t()
  def new_bereich(id, min, max) when is_number(id)
                                and is_number(min)
                                and is_number(max)
                                and min <= max do
    %Merkmal{id: id, typ: :bereich, data: %{min: min, max: max}}
  end

  @spec new_auswahl(integer, [number]) :: Aufbereitung.Model.Merkmal.t()
  def new_auswahl(id, auspraegungen) when is_number(id) and is_list(auspraegungen) do
    %Merkmal{id: id, typ: :auswahl, data: auspraegungen |> MapSet.new()}
  end

  @spec new_selbstbeteiligung(integer, [number]) :: Aufbereitung.Model.Merkmal.t()
  def new_selbstbeteiligung(id, auspraegungen) when is_number(id) and is_list(auspraegungen) do
    %Merkmal{id: id, typ: :sb, data: auspraegungen |> MapSet.new()}
  end

  @spec bezieht_sich_auf?(Aufbereitung.Model.Merkmal.t(), Aufbereitung.Model.Merkmal.t()) :: boolean
  def bezieht_sich_auf?(left, right) do
    left.id === right.id and left.typ === right.typ
  end

  @spec hinzufuegen_wenn_nicht_vorhanden([Aufbereitung.Model.Merkmal.t()], Aufbereitung.Model.Merkmal.t()) ::[Aufbereitung.Model.Merkmal.t()]
  def hinzufuegen_wenn_nicht_vorhanden([], neues_merkmal) do
    [neues_merkmal]
  end

  def hinzufuegen_wenn_nicht_vorhanden(merkmale, neues_merkmal) do
    case Enum.any?(merkmale, fn m -> m.id === neues_merkmal.id end) do
      true -> merkmale
      false -> [neues_merkmal | merkmale]
    end
  end

  @spec splitte(Aufbereitung.Model.Merkmal.t(), Aufbereitung.Model.Merkmal.t()) :: [Aufbereitung.Model.Merkmal.t()]
  def splitte(left = %Merkmal{data: erf}, left = %Merkmal{data: erf}) do
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

  def splitte(m1 = %Merkmal{id: id, typ: typ, data: left}, %Merkmal{id: id, typ: typ, data: right}) when typ === :auswahl
                                                                                                      or typ === :sb do
    delta = MapSet.difference(left, right)
    intersection = MapSet.intersection(left, right)

    case MapSet.size(intersection) do
      0 ->
        [m1]

      _ ->
        [
          %Merkmal{m1 | data: intersection},
          %Merkmal{m1 | data: delta}
        ]
    end
  end

  @doc """
  erfuellt_durch? prueft auf gleiche Id und _identischer_ Ausprägung.
  Das ist ausreichend, da bereits vorher im Aufbereitungsprozess auf genau diese
  Merkmalsausprägungen gesplittet wurde. Es kann also nur identische Ausprägungen oder
  komplett differente handeln.
  """
  @spec erfuellt_durch?(Aufbereitung.Model.Merkmal.t(), Aufbereitung.Model.Merkmal.t()) :: boolean
  def erfuellt_durch?(%Merkmal{id: left_id}, %Merkmal{id: right_id}) when left_id !== right_id, do:
    false

  def erfuellt_durch?(%Merkmal{id: id, data: left}, %Merkmal{id: id, data: right}), do:
    left === right
end
