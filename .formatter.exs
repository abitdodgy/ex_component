# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [assert_safe: 2],
  export: [
    locals_without_parens: [assert_safe: 2]
  ]
]
