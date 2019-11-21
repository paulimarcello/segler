defmodule TarifTest do
  alias Aufbereitung.Model.Bedingung, as: Bedingung
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Praemie, as: Praemie
  alias Aufbereitung.Model.Tarif, as: Tarif
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.TarifvarianteBausteinId, as: TarifvarianteBausteinId
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
  @versicherungssteuer 1.19

  # --------------------------------------------------------------------------------------------------
  # Nur Grundpraemien
  # --------------------------------------------------------------------------------------------------

  test "nur Grundpraemien 1" do
    result =
      Tarif.new(
        @tarif_id,
        [
          Grundpraemie.new(@grundpraemie_id_1, "10*0,9", Merkmal.new_bereich(@eintrittsalter, 20, 50) |> Bedingung.new())
        ],
        [],
        [Merkmal.new_bereich(@eintrittsalter, 18, 60)],
        @versicherungssteuer
      )
      |> Tarif.bilde_alle_tarifvarianten()

    assert result === [
             %Tarifvariante{
                baustein_id:
                  %TarifvarianteBausteinId{
                    tarif_id: @tarif_id,
                    grundpraemie_id: @grundpraemie_id_1
                  },
                leistungsumfang: [
                  %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 20, max: 50}}
                ],
                praemie:
                  %Praemie{
                    versicherungssteuer: @versicherungssteuer,
                    formeln: ["10*0,9"]
                  }
             }
           ]
  end

  test "nur Grundpraemien 2" do
    result =
      Tarif.new(
        @tarif_id,
        [
          Grundpraemie.new(@grundpraemie_id_1, "10*0,9", Merkmal.new_bereich(@eintrittsalter, 20, 50) |> Bedingung.new()),
          Grundpraemie.new(@grundpraemie_id_2, "10*1,1", Merkmal.new_bereich(@eintrittsalter, 51, 60) |> Bedingung.new())
        ],
        [],
        [Merkmal.new_bereich(@eintrittsalter, 18, 60)],
        @versicherungssteuer
      )
      |> Tarif.bilde_alle_tarifvarianten()

    assert result === [
             %Tarifvariante{
                baustein_id:
                  %TarifvarianteBausteinId{
                    tarif_id: @tarif_id,
                    grundpraemie_id: @grundpraemie_id_1
                  },
                leistungsumfang: [
                  %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 20, max: 50}}
                ],
                praemie:
                  %Praemie{
                    versicherungssteuer: @versicherungssteuer,
                    formeln: ["10*0,9"]
                  }
             },
             %Tarifvariante{
              baustein_id:
                %TarifvarianteBausteinId{
                  tarif_id: @tarif_id,
                  grundpraemie_id: @grundpraemie_id_2
                },
              leistungsumfang: [
                %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 51, max: 60}}
              ],
              praemie:
                %Praemie{
                  versicherungssteuer: @versicherungssteuer,
                  formeln: ["10*1,1"]
                }
           }
           ]
  end

  # --------------------------------------------------------------------------------------------------
  # Feature: Split Grundprämie und Zuschlag anhand logischem Merkmal
  # --------------------------------------------------------------------------------------------------
  test "Split logisches Merkmal Szenario 1" do
    result =
      Tarif.new(
        @tarif_id,
        [
          Grundpraemie.new(@grundpraemie_id_1, "100")
        ],
        [
          Zuschlag.new(
            @zuschlag_id_1,
            :tarif,
            "praemie*1,2",
            1,
            Merkmal.new_logisch(@objekt_mitbewohnt, :erfuellt) |> Bedingung.new()
          )
        ],
        [
          Merkmal.new_bereich(@eintrittsalter, 18, 60),
          Merkmal.new_logisch(@objekt_mitbewohnt, :egal)
        ],
        @versicherungssteuer
      )
      |> Tarif.bilde_alle_tarifvarianten()

      expected = [
        %Tarifvariante{
           baustein_id:
             %TarifvarianteBausteinId{
               tarif_id: @tarif_id,
               grundpraemie_id: @grundpraemie_id_1,
               zuschlaege_ids: [@zuschlag_id_1]
             },
           leistungsumfang: [
             %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 18, max: 60}},
             %Merkmal{id: @objekt_mitbewohnt, typ: :logisch, data: :erfuellt}
           ],
           praemie:
             %Praemie{
               versicherungssteuer: @versicherungssteuer,
               formeln: ["praemie*1,2", "100"]
             }
        },
        %Tarifvariante{
          baustein_id:
            %TarifvarianteBausteinId{
              tarif_id: @tarif_id,
              grundpraemie_id: @grundpraemie_id_1,
              zuschlaege_ids: []
            },
          leistungsumfang: [
            %Merkmal{id: @eintrittsalter, typ: :bereich, data: %{min: 18, max: 60}},
            %Merkmal{id: @objekt_mitbewohnt, typ: :logisch, data: :nicht_erfuellt}
          ],
          praemie:
            %Praemie{
              versicherungssteuer: @versicherungssteuer,
              formeln: ["100"]
            }
       },
      ]

      assert_equivalence(result, expected)
  end

  defp assert_equivalence(result, expected) when is_list(result) and is_list(expected) do
    assert Enum.filter(result, fn x -> Enum.member?(expected, fn y -> x === y end) end) === []
  end
end
