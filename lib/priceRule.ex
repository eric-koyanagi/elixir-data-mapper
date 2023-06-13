defmodule Shopify.PriceRule do
  @moduledoc """
  https://shopify.dev/docs/api/admin-rest/2023-01/resources/pricerule
  """

  @doc """
  Retrieve a list of rules.
  """
  @spec list(map) :: Shopify.Operation.t()
  def list(params \\ %{}) do
    %Shopify.Operation{
      http_method: :get,
      params: params,
      path: "/price_rules.json"
    }
  end

  @doc """
  Create a rule.
  """
  @spec create(map) :: Shopify.Operation.t()
  def create(params) do
    %Shopify.Operation{
      http_method: :post,
      params: params,
      path: "/price_rules.json"
    }
  end

  @doc """
  Create a discount.
  """
  @spec create_discount(binary, string) :: Shopify.Operation.t()
  def create_discount(id, code) do
    %Shopify.Operation{
      http_method: :post,
      params: %{
        :discount_code => %{
          :code => code
        }
      },
      path: "/price_rules/#{id}/discount_codes.json"
    }
  end

  @doc """
  Delete a rule.
  """
  @spec delete(binary) :: Shopify.Operation.t()
  def delete(price_rule_id) do
    %Shopify.Operation{
      http_method: :delete,
      path: "/price_rules/#{price_rule_id}.json"
    }
  end

end
