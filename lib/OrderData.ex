defmodule OrderData do


  @moduledoc """
  Product data module; this loads "source" data from a CSV and holds it in memory 
  We then pull products from Shopify and enrich it using this source data
  """

  @doc """
  Loads custom order data from a source; in this case, a CSV...but you could replace this if you wanted

  ## Examples

      iex> OrderData.load()

  """
  def load do
    rows = CSV.decode!(File.stream!("data/order_data.csv"), headers: true) 
    # This maps each row by order_id, and if the order_id already exists,
    # it adds it to the order_id key as a list
    Enum.reduce(rows, %{}, fn row, acc ->
      order_id = row["order_id"]
      Map.update(acc, order_id, [row], &[row | &1])
    end)
  end

  

end