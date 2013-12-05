# Functions that Houston makes available to the app
root = exports ? this

# Let Houston know about a collection manually, as an alternative
# to the current autodiscovery process
Houston.add_collection = (collection) ->
  # TODO options arg can be used to configure admin UI like Django does
  Houston._setup_collection(collection)
