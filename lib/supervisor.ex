defmodule DM.Supervisor do 
	use Supervisor

	def start_links(opts) do 
		Supervisor.start_link(__MODULE__, :ok, opts)
	end 


	@impl true
	  def init(:ok) do
	    children = [	      
	      Shopify.RateLimiter,
	      Shopify.GraphQL.Limiter
	    ]

	    Supervisor.init(children, strategy: :one_for_one)
	  end

end 