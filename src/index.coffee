import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as K from "@dashkite/katana/async"
import { Resource } from "@dashkite/vega-client"

HTTP = 

  resource: do ({ resource } = {}) ->
    
    resource = generic name: "HTTP.resource"

    generic resource,
      Type.isObject,
      ( specifier ) ->
        Fn.flow [
          K.read "handle"
          K.poke ( handle ) ->
            handle.resource = Resource.create specifier
        ]
    
    generic resource,
      Type.isFunction,
      ( specify ) ->
        Fn.flow [
          K.push specify
          K.read "handle"
          K.poke ( handle, specifier ) ->
            handle.resource = Resource.create specifier
        ]
    
    resource

  get: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }) -> do resource.get
    ]

  put: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }, update ) -> 
        data = await do resource.get
        resource.put { data..., update... }
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

  patch: ->
    Fn.flow [
      K.read "handle"
      K.poke ({ resource }, update ) -> 
        resource.patch update
    ]

export { HTTP }
export default HTTP