Houston._show_flash = (err, result) ->
  Houston._session 'flash_error', err?
  if err?
    Houston._session 'flash_message', "Error: #{err.message}"
  else
    Houston._session 'flash_message', result
  Houston._session 'flash_show', true
  setTimeout (-> Houston._session('flash_show', false)), 2000

Template._houston_flash_message.helpers
  err: -> Houston._session 'flash_error'
  show: -> Houston._session 'flash_show'
  message: -> Houston._session 'flash_message'
