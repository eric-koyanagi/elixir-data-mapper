defmodule Shopify.Redirect do
  @moduledoc """
  [https://shopify.dev/docs/api/admin-rest/2023-01/resources/redirect](https://shopify.dev/docs/api/admin-rest/2023-01/resources/redirect)
  """

  @doc """
  Create a redirct.
  """
  @spec create(map) :: Shopify.Operation.t()
  def create(params) do
    %Shopify.Operation{
      http_method: :post,
      params: params,
      path: "/redirects.json"
    }
  end
end
