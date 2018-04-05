module JWTSignedRequest
  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)

  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)
  RequestBodyVerificationFailedError = Class.new(RequestVerificationFailedError)
  RequestHeaderVerificationFailedError = Class.new(RequestVerificationFailedError)
  RequestMethodVerificationFailedError = Class.new(RequestVerificationFailedError)
  RequestPathVerificationFailedError = Class.new(RequestVerificationFailedError)
  RequestQueryVerificationFailedError = Class.new(RequestVerificationFailedError)

  MissingKeyIdError = Class.new(UnauthorizedRequestError)
  UnknownKeyIdError = Class.new(UnauthorizedRequestError)
  AlgorithmMismatchError = Class.new(UnauthorizedRequestError)
end
