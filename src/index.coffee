import * as Fn from "@dashkite/joy/function"
import * as Obj from "@dashkite/joy/object"
import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as K from "@dashkite/katana/async"
import { Daisho } from "@dashkite/katana"
import _HTTP from "@dashkite/vega-client"
    
# Rio-friendly combinators for saving (binding)
# the resource to the handle and retrieving it
# so that we can make a request.
#
# The request combinator also begins the run loop
# for the resulting HTTP reactor. The run loop
# calls each handler function with the daisho
# and returns the resulting daisho so that the
# handlers can update it if they want.

Resource =

  save: ( daisho ) ->
    handle = daisho.read "handle"
    handle.resource = daisho.pop()
    daisho

  request: ( method, fx ) ->
    ( daisho ) ->
      start = _HTTP[ method ]
      { resource } = daisho.read "handle"
      reactor = switch method
        when "get", "delete"
          start resource
        when "put", "post"
          content = daisho.peek()
          start resource, content
        else 
          throw new Error "rio-vega:
            unsupported method '#{ method }'"
      for await r from _HTTP.bind reactor
        for f in fx
          daisho = await f daisho, r
      daisho  

# TODO accommodate unary post?
# TODO add support for patch when ready

# simple adapter for making HTTP requests
http = ( method ) ->
  ( fx ) -> Resource.request method, fx
  
# A map-filter, used to construct handlers
# We push the result of the accessor onto 
# the daisho stack. If a Rio flow is provided
# we invoke it with the daisho. We return
# the resulting daisho either way.

filter = ( specifier ) ->

  do ({ g } = {}) ->

    g = generic name: "rio-vega:#{ name }"

    generic g, 
      Type.isArray,
      ( fx ) ->
          f = Fn.flow fx
          ( daisho, r ) ->
            if r.when specifier.when
              daisho.push r.get specifier.get
              f daisho 
            else daisho
    
    generic g,
      ( Type.isKind Daisho ),
      Type.isObject,
      ( daisho, r ) ->
        if r.when specifier.when
          daisho.push r.get specifier.get
        daisho

    g  

HTTP = 

  # combine the description with the specifier
  # which allows us to get bindings dynamically
  # but binding the resource class statically
  resource: ( specifier ) ->
    Fn.flow [
      K.poke ( description ) ->
        { specifier..., description... }
      Resource.save
    ]

  get: http "get"

  put: http "put"
  
  delete: http "delete"

  post: http "post"

  # patch: http "patch"

  success: filter 
    when: "success"
    get: "response content"

  failure: filter 
    when: "failure"
    get: "failure error"

  json: filter 
    when: "response content is json"
    get: "response json"

  text: filter 
    when: "response content is text"
    get: "response text"

  blob: filter 
    when: "response content is a blob"
    get: "response blob"

  content: filter 
    when: "response has content"
    get: "response content"

  # announce: filter "announce"

export { HTTP }
export default HTTP