defmodule Aufbereitung.Model.Tarif do
  alias Aufbereitung.Model.{Grundpraemie, Tarif, Tarifvariante, Zuschlag}

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

  @spec bilde_alle_tarifvarianten(Aufbereitung.Model.Tarif.t()) :: [Aufbereitung.Model.Tarifvariante.t()]
  def bilde_alle_tarifvarianten(tarif) do
    tarif.grundpraemien
    |> bilde_grundtarifvarianten(tarif.id, tarif.versicherungssteuer)
    |> erweitere_um_leistungsumfang(tarif.leistungsumfang)
    |> wende_tarifzuschlaege_an(tarif.zuschlaege)
    |> wende_leistungstexte_an(tarif.leistungstexte)
    |> uebernimm_tarifbereiche(tarif.tarifbereiche)
  end

  defp bilde_grundtarifvarianten(grundpraemien, tarif_id, versicherungssteuer) when is_list(grundpraemien) do
    grundpraemien
    |> Enum.map(&bilde_grundtarifvarianten(&1, tarif_id, versicherungssteuer))
  end

  defp bilde_grundtarifvarianten(grundpraemie, tarif_id, versicherungssteuer) do
    grundpraemie
    |> Grundpraemie.erzeuge_grundtarifvariante(tarif_id, versicherungssteuer)
  end

  defp erweitere_um_leistungsumfang(tarifvarianten, leistungsumfang) do
    tarifvarianten
    |> Enum.map(&Tarifvariante.erweitere_leistungsumfang(&1, leistungsumfang))
  end

  defp wende_tarifzuschlaege_an(tarifvarianten, []) do
    tarifvarianten
  end

  defp wende_tarifzuschlaege_an(tarifvarianten, [zuschlag|zuschlaege_rest]) do
    varianten =
      tarifvarianten
      |> Enum.map(&Zuschlag.anwenden(zuschlag, &1))
      |> List.flatten()

    wende_tarifzuschlaege_an(varianten, zuschlaege_rest)
  end

  defp wende_leistungstexte_an(tarifvarianten, _leistungstexte) do
    tarifvarianten
  end

  defp uebernimm_tarifbereiche(tarifvarianten, tarifbereiche) do
    tarifvarianten
    |> Enum.map(&Tarifvariante.fuege_tarifbereiche_hinzu(&1, tarifbereiche))
  end
end
