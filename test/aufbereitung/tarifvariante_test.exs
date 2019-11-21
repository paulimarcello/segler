defmodule TarifvarianteTest do
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Praemie, as: Praemie
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId

  use ExUnit.Case

  @grundtarif_id 1
  @praemie %{id: 10, formel: "100"}
  @versicherungssteuer 1.10

  # leistungsumfang
  @merkmal_logisch_1 Merkmal.new_logisch(1, :erfuellt)

  # --------------------------------------------------------------------------------------------------
  # new
  # --------------------------------------------------------------------------------------------------
  test "new" do
    result = Tarifvariante.new(@grundtarif_id, @praemie, [@merkmal_logisch_1], @versicherungssteuer)

    assert result ===
      %Tarifvariante{
        baustein_id:
          %TarifvarianteBausteinId{
            tarif_id: @grundtarif_id,
            grundpraemie_id: 10,
            zuschlaege_ids: []
          },
        leistungsumfang: [
          @merkmal_logisch_1
        ],
        tarifbereiche: [],
        praemie:
          %Praemie{
            versicherungssteuer: @versicherungssteuer,
            formeln: ["100"]
          }
      }
  end

  # --------------------------------------------------------------------------------------------------
  # Anwendung Split
  # --------------------------------------------------------------------------------------------------
  test "splitte mit leeren merkmalen" do
    tarifvariante = Tarifvariante.new(@grundtarif_id, @praemie, [Merkmal.new_logisch(1, :erfuellt)], @versicherungssteuer)

    result = Tarifvariante.splitte(tarifvariante, [])

    assert result === [tarifvariante]
  end

  test "splitte bei einem merkmal" do
    tarifvariante = Tarifvariante.new(@grundtarif_id, @praemie, [Merkmal.new_logisch(1, :egal)], @versicherungssteuer)

    result = Tarifvariante.splitte(tarifvariante, Merkmal.new_logisch(1, :erfuellt))

    assert result === [
      Tarifvariante.new(@grundtarif_id, @praemie, [Merkmal.new_logisch(1, :erfuellt)], @versicherungssteuer),
      Tarifvariante.new(@grundtarif_id, @praemie, [Merkmal.new_logisch(1, :nicht_erfuellt)], @versicherungssteuer)
    ]
  end

  test "splitte bei mehreren merkmal" do
    tarifvariante =
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :egal),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 18, 150)
        ],
        @versicherungssteuer
      )

    split_merkmale = [
      Merkmal.new_logisch(1, :erfuellt),
      Merkmal.new_bereich(3, 30, 50)
    ]

    result = Tarifvariante.splitte(tarifvariante, split_merkmale)

    expected = [
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 18, 29),
        ],
        @versicherungssteuer
      ),
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :nicht_erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 18, 29),
        ],
        @versicherungssteuer
      ),
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 30, 50),
        ],
        @versicherungssteuer
      ),
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :nicht_erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 30, 50),
        ],
        @versicherungssteuer
      ),
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 51, 150),
        ],
        @versicherungssteuer
      ),
      Tarifvariante.new(
        @grundtarif_id,
        @praemie,
        [
          Merkmal.new_logisch(1, :nicht_erfuellt),
          Merkmal.new_logisch(2, :erfuellt),
          Merkmal.new_bereich(3, 51, 150),
        ],
        @versicherungssteuer
      )
    ]

    assert Enum.count(result) === 6
    assert Enum.filter(result, fn x -> Enum.member?(expected, fn y -> x === y end) end) === []
  end

  # --------------------------------------------------------------------------------------------------
  # anwendung tarif_zuschlag
  # --------------------------------------------------------------------------------------------------
  test "tarif-zuschlag anwenden" do
    result =
      Tarifvariante.new(@grundtarif_id, @praemie, [Merkmal.new_logisch(1, :erfuellt)], @versicherungssteuer)
      |> Tarifvariante.tarif_zuschlag_anwenden(%{id: 115, formel: "praemie*1,10"})

    assert result ===
      %Tarifvariante{
        baustein_id:
          %TarifvarianteBausteinId{
            tarif_id: @grundtarif_id,
            grundpraemie_id: 10,
            zuschlaege_ids: [115]
          },
        leistungsumfang: [
          @merkmal_logisch_1
        ],
        tarifbereiche: [],
        praemie:
          %Praemie{
            versicherungssteuer: @versicherungssteuer,
            formeln: ["praemie*1,10", "100"]
          }
      }
  end
end
