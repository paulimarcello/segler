defmodule Aufbereitung.Services.TarifAufbereitungService do
  alias Aufbereitung.Model.Grundpraemie, as: Grundpraemie
  alias Aufbereitung.Model.Tarif, as: Tarif
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante
  alias Aufbereitung.Model.Zuschlag, as: Zuschlag

  def alle_tarifvarianten_des_tarifs(tarif = %Tarif{}) do
    tarif.grundpraemien
    |> Enum.map(&bilde_grundtarifvarianten(tarif.id, &1))
    |> erweitere_um_leistungsumfang(tarif.leistungsumfang)
    |> wende_tarifzuschlaege_an(tarif.zuschlaege)
    |> wende_leistungstexte_an(tarif.leistungstexte)
    |> uebernimm_tarifbereiche(tarif.tarifbereiche)
    |> uebernimm_versicherungssteuer(tarif.versicherungssteuer)
  end

  defp bilde_grundtarifvarianten(tarif_id, praemie) do
    Tarifvariante.new(tarif_id, praemie.id, Grundpraemie.get_leistungsumfang_aus_bedingung(praemie))
  end

  defp erweitere_um_leistungsumfang(tarifvarianten, leistungsumfang) do
    tarifvarianten
    |> Enum.map(&Tarifvariante.erweitere_leistungsumfang(&1, leistungsumfang))
  end

  defp wende_tarifzuschlaege_an(tarifvarianten, tarif_zuschlaege) do
    for variante <- tarifvarianten, zuschlag <- tarif_zuschlaege do
      Zuschlag.anwenden(zuschlag, variante)
    end
  end

  defp wende_leistungstexte_an(tarifvarianten, _leistungstexte) do
    tarifvarianten
  end

  defp uebernimm_tarifbereiche(tarifvarianten, tarifbereiche) do
    tarifvarianten
    |> Enum.map(&Tarifvariante.fuege_tarifbereiche_hinzu(&1, tarifbereiche))
  end

  defp uebernimm_versicherungssteuer(tarifvarianten, _versicherungssteuer) do
    tarifvarianten
  end
end
