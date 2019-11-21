defmodule Aufbereitung.Model.Tarif do
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Tarif, as: Tarif
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  defstruct id: nil,
            grundpraemien: [],
            zuschlaege: [],
            leistungsumfang: [],
            leistungstexte: [],
            tarifbereiche: [],
            versicherungssteuer: nil

  def new(id, grundpraemien, zuschlaege, leistungsumfang, versicherungssteuer) do
    %Tarif{
      id: id,
      grundpraemien: grundpraemien,
      zuschlaege: zuschlaege,
      leistungsumfang: leistungsumfang,
      versicherungssteuer: versicherungssteuer}
  end

  def bilde_alle_tarifvarianten(tarif) do
    tarif.grundpraemien
    |> Enum.map(&bilde_grundtarifvarianten(&1, tarif.id, tarif.versicherungssteuer))
    |> erweitere_um_leistungsumfang(tarif.leistungsumfang)
    |> wende_tarifzuschlaege_an(tarif.zuschlaege)
    |> wende_leistungstexte_an(tarif.leistungstexte)
    |> uebernimm_tarifbereiche(tarif.tarifbereiche)
  end

  # --------------------------------------------------------------------------------------------------

  defp bilde_grundtarifvarianten(grundpraemie, tarif_id, versicherungssteuer), do:
    Tarifvariante.new(
      tarif_id,
      grundpraemie,
      Grundpraemie.get_leistungsumfang_aus_bedingung(grundpraemie),
      versicherungssteuer)

  # --------------------------------------------------------------------------------------------------

  defp erweitere_um_leistungsumfang(tarifvarianten, leistungsumfang), do:
    tarifvarianten
    |> Enum.map(&Tarifvariante.erweitere_leistungsumfang(&1, leistungsumfang))

  # --------------------------------------------------------------------------------------------------

  defp wende_tarifzuschlaege_an(tarifvarianten, []) do
    tarifvarianten
  end

  defp wende_tarifzuschlaege_an(tarifvarianten, [zuschlag|zuschlaege_rest]) do
    varianten =
      tarifvarianten
      |> Enum.map(&Zuschlag.anwenden(zuschlag, &1))

    wende_tarifzuschlaege_an(varianten, zuschlaege_rest)
  end

  # --------------------------------------------------------------------------------------------------

  defp wende_leistungstexte_an(tarifvarianten, _leistungstexte) do
    tarifvarianten
  end

  # --------------------------------------------------------------------------------------------------

  defp uebernimm_tarifbereiche(tarifvarianten, tarifbereiche), do:
    tarifvarianten
    |> Enum.map(&Tarifvariante.fuege_tarifbereiche_hinzu(&1, tarifbereiche))
end
