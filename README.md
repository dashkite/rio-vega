# Rio Vega

*Rio combinators for use with the HTTP/Vega Client*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

## API

There are two kinds of functions in Rio Vega: request and filter combinators.

Request combinators are Rio combinators that start a Vega HTTP reactor. Request combinators:

- Take a list of filter combinators, which are composed into an aggregate filter
- Pass each event from the reactor to the resulting filter
- Are defined for each HTTP method

Filter combinators really filter-map combinators that:

- Take an event, determine if it matches a given filter criteria. If it does, they map it into a value. For example, they might filter events where the response content is JSON and map them into a JSON value. 
- Take a list of Rio combinators which are composed into an aggregate Rio flow. If the filter applies, the mapped value, if any, is pushed onto the Rio stack so that it can be accessed by the flow. 
- Are defined for success, failure,  and different content types.

### Currently Supported

| Combinator                | Type    | Description                                                  |
| ------------------------- | ------- | ------------------------------------------------------------ |
| get, put, delete, post    | request | Starts an HTTP reactor for the corresponding method          |
| text, json, blob, content | filter  | If the request was successful and the response content is of the given type, push the response content onto the Rio stack |
| success                   | filter  | Matches if the request was success, but doesn’t push anything onto the stack |
| failure                   | filter  | Matches if the request failed, pushing the error onto the stack |

### Possible Future Enhancements

- Support for `patch`
- Support for announcements, which can be used to display messages via the user agent for unrecoverable errors. See below.

### Why There Are No Error Filters

Generally, Vega HTTP tries to handle errors for the caller. For unrecoverable errors, there is presently only one filter, the _failure_ filter, which places the error object associated with the failure on the stack. The caller can then inspect the error and provide any necessary feedback via the user agent.

The announce interface will provide a higher-level interface for such events, so that the caller no longer needs to inspect the error. Instead, a message object will be placed on the stack that can be used to generate a message suitable for display. The message object will follow the typical I18N pattern of providing a code and parameters. In conjuction with a message catalog, the caller can transform the message object into the display text. For example, a *409 Conflict* error would be translated into a message object with the code `conflict`.
