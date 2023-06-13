defmodule CouponData do


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
    rows = CSV.decode!(File.stream!("data/coupon_data.csv"), headers: true) 
    Map.new(rows, fn row ->
      # Map imported data by key "sku"
      {row["code"], row}
    end)
  end

  def load_exclusions do
    rows = CSV.decode!(File.stream!("data/coupon_data_excluded.csv"), headers: true) 
    Map.new(rows, fn row ->
      # Map imported data by key "sku"
      {row["code"], row}
    end)
  end


  

end