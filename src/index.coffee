import * as Fn from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import { Resource } from "@dashkite/vega-client"

HTTP = 

  resource: ( specifier ) ->
    Fn.flow [
      K.read "handle"
      K.poke ( handle ) ->
        handle.resource = Resource.create specifier
    ]

  get: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }) -> do resource.get
    ]

  put: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }, data ) -> resource.put data
    ]

  delete: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }) -> do resource.delete
    ]

  post: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }, data ) -> resource.post data
    ]

export { HTTP }
export default HTTP