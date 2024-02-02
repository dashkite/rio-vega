import * as Fn from "@dashkite/joy/function"
import * as Obj from "@dashkite/joy/object"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as K from "@dashkite/katana/async"
import { Daisho } from "@dashkite/katana"
import * as Vega from "@dashkite/vega-client"

filter = ( name ) ->

  do ({ g } = {}) ->

    g = generic name: "HTTP:#{ name }"

    generic g, 
      Type.isArray,
      ( fx ) ->
          f = Fn.flow fx
          ( daisho, event ) ->
            if event.name == name
              daisho.push event.value
              f daisho 
            else daisho
    
    generic g,
      ( Type.isKind Daisho ),
      Type.isObject,
      ( daisho, event ) ->
        if event.name == name
          daisho.push event.value
        daisho

    g
    
Resource =

  get: ( daisho ) ->
    handle = daisho.read "handle"
    daisho.poke handle.resource
    daisho

  set: ( daisho ) ->
    handle = daisho.read "handle"
    handle.resource = daisho.pop()
    daisho

  request: ( method ) ->
    ( daisho ) ->
      start = Vega.HTTP[ method ]
      resource = daisho.pop()
      reactor = switch method
        when "get", "delete"
          start resource
        when "put", "post"
          content = daisho.peek()
          start resource, content
        else 
          throw new Error "rio-vega: unsupport method '#{ method }'"
      for await event from reactor
        for f in fx
          daisho = await f daisho, event
      daisho  

# TODO accommodate unary post?
# TODO add support for patch when ready
http = ( method ) ->
  ( fx ) ->
    Fn.flow [
      Resource.get
      Resource.request method
    ]
  
HTTP = 

  resource: ( specifier ) ->
    Fn.flow [
      K.poke ( description ) ->
        { specifier..., description... }
      Resource.set
    ]

  get: http "get"

  put: http "put"
  
  delete: http "delete"

  post: http "post"

  # patch: http "patch"

  success: filter "success"

  failure: filter "failure"

  json: filter "json"

  text: filter "text"

  blob: filter "blob"

  content: filter "content"

  announce: filter "announce"

export { HTTP }
export default HTTP