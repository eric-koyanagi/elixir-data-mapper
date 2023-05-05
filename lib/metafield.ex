defmodule Shopify.Metafield do
  @moduledoc """
  [https://shopify.dev/docs/api/admin-rest/2023-01/resources/metafield](https://shopify.dev/docs/api/admin-rest/2023-01/resources/metafield)
  """

  @doc """
  List all product metafields
  """
  @spec list(binary, map) :: Shopify.Operation.t()
  def list(product_id, params) do
    %Shopify.Operation{
      http_method: :get,
      params: params,
      path: "/products/#{product_id}/metafields.json"
    }
  end

  @doc """
  Delete a product metafields
  """
  @spec delete(binary, binary) :: Shopify.Operation.t()
  def delete(product_id, field_id) do
    %Shopify.Operation{
      http_method: :delete,
      path: "/products/#{product_id}/metafields/#{field_id}.json"
    }
  end

  @doc """
  Create a product metafield 
  """
  @spec create(binary, map) :: Shopify.Operation.t()
  def create(product_id, params) do
    %Shopify.Operation{
      http_method: :post,
      params: params,
      path: "/products/#{product_id}/metafields.json"
    }
  end

  @doc """
  Update a product metafield 
  """
  @spec update(binary, binary, map) :: Shopify.Operation.t()
  def update(product_id, field_id, params) do
    %Shopify.Operation{
      http_method: :put,
      params: params,
      path: "/products/#{product_id}/metafields/#{field_id}.json"
    }
  end
end
