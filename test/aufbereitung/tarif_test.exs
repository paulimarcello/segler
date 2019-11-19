defmodule TarifTest do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Tarif, as: Tarif
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvariantenbausteinId, as: TarifvariantenbausteinId
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag
  alias Aufbereitung.Services.TarifAufbereitungService, as: TarifAufbereitungService

  use ExUnit.Case

  @tarif_id 1
  @grundpraemie_id_1 1
  @grundpraemie_id_2 2
  @zuschlag_id_1 1
  @reihenfolge_1 1
  # Merkmale
  @eintrittsalter 1
  @objekt_mitbewohnt 2

  # --------------------------------------------------------------------------------------------------
  # Nur Grundpraemien
  # --------------------------------------------------------------------------------------------------
  @tag :skip
  test "nur Grundpraemien 1" do
    result =
      %Tarif{
        id: @tarif_id,
        leistungsumfang: [Merkmal.new_bereich(@eintrittsalter, 18, 60)],
        grundpraemien: [
          Grundpraemie.new(
            @grundpraemie_id_1,
            "10*0,9",
            Merkmal.new_bereich(@eintrittsalter, 20, 50) |> Bedingung.new()
          )
        ],
        zuschlaege: []
      }
      |> TarifAufbereitungService.alle_tarifvarianten_des_tarifs()

    assert result === [
             %Tarifvariante{
               baustein_id: %TarifvariantenbausteinId{
                 tarif_id: @tarif_id,
                 grundpraemie_id: @grundpraemie_id_1
               },
               leistungsumfang: [%Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 20, max: 50}}]
             }
           ]
  end

  @tag :skip
  test "nur Grundpraemien 2" do
    result =
      %Tarif{
        id: @tarif_id,
        leistungsumfang: [Merkmal.new_bereich(@eintrittsalter, 18, 60)],
        grundpraemien: [
          Grundpraemie.new(
            @grundpraemie_id_1,
            "10*0,9",
            Merkmal.new_bereich(@eintrittsalter, 20, 50) |> Bedingung.new()
          ),
          Grundpraemie.new(
            @grundpraemie_id_2,
            "10*1,1",
            Merkmal.new_bereich(@eintrittsalter, 51, 60) |> Bedingung.new()
          )
        ],
        zuschlaege: []
      }
      |> TarifAufbereitungService.alle_tarifvarianten_des_tarifs()

    assert result === [
             %Tarifvariante{
               baustein_id: %TarifvariantenbausteinId{
                 tarif_id: @tarif_id,
                 grundpraemie_id: @grundpraemie_id_1
               },
               leistungsumfang: [%Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 20, max: 50}}]
             },
             %Tarifvariante{
               baustein_id: %TarifvariantenbausteinId{
                 tarif_id: @tarif_id,
                 grundpraemie_id: @grundpraemie_id_2
               },
               leistungsumfang: [%Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 51, max: 60}}]
             }
           ]
  end

  # --------------------------------------------------------------------------------------------------
  # Split Grundprämie und Zuschlag anhand logischem Merkmal
  # --------------------------------------------------------------------------------------------------
  @tag :skip
  test "Split logisches Merkmal: Grundtarif Egal, Zuschlag Erfuellt -> Split" do
    result =
      %Tarif{
        id: @tarif_id,
        leistungsumfang: [
          Merkmal.new_bereich(@eintrittsalter, 18, 60),
          Merkmal.new_logisch(@objekt_mitbewohnt, :egal)
        ],
        grundpraemien: [
          Grundpraemie.new(
            @grundpraemie_id_1,
            "100",
            []
          )
        ],
        zuschlaege: [
          Zuschlag.new(
            @zuschlag_id_1,
            :tarif,
            "praemie*1,2",
            @reihenfolge_1,
            Merkmal.new_logisch(@objekt_mitbewohnt, :erfuellt) |> Bedingung.new()
          )
        ]
      }
      |> TarifAufbereitungService.alle_tarifvarianten_des_tarifs()
      |> IO.inspect()

    assert result === [
             %Tarifvariante{
               baustein_id: %TarifvariantenbausteinId{
                 tarif_id: @tarif_id,
                 grundpraemie_id: @grundpraemie_id_1
               },
               leistungsumfang: [
                 %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 18, max: 60}},
                 %Merkmal{id: @objekt_mitbewohnt, typ: :logisch, data: :erfuellt}
               ]
             },
             %Tarifvariante{
               baustein_id: %TarifvariantenbausteinId{
                 tarif_id: @tarif_id,
                 grundpraemie_id: @grundpraemie_id_1
               },
               leistungsumfang: [
                 %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 18, max: 60}},
                 %Merkmal{id: @objekt_mitbewohnt, typ: :logisch, data: :nicht_erfuellt}
               ]
             }
           ]
  end
end
