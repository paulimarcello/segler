defmodule Aufbereitung.Model.Tarif do
  alias Aufbereitung.Model.Tarif, as: Tarif

  defstruct id: nil,
            grundpraemien: [],
            zuschlaege: [],
            leistungsumfang: [],
            leistungstexte: [],
            tarifbereiche: [],
            versicherungssteuer: nil

  def new(id, grundpraemien, zuschlaege, leistungsumfang) do
    %Tarif{id: id, grundpraemien: grundpraemien, zuschlaege: zuschlaege, leistungsumfang: leistungsumfang}
  end
end
