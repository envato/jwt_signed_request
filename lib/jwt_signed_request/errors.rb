module JWTSignedRequest
  UnauthorizedRequestError = Class.new(StandardError)
  MissingAuthorizationHeaderError = Class.new(UnauthorizedRequestError)
  JWTDecodeError = Class.new(UnauthorizedRequestError)
  RequestVerificationFailedError = Class.new(UnauthorizedRequestError)
  %w[Method Path Header Body Query].each do |type|
    module_eval("Request#{type}VerificationFailedError = Class.new(RequestVerificationFailedError)")
  end
  MissingKeyIdError = Class.new(UnauthorizedRequestError)
  UnknownKeyIdError = Class.new(UnauthorizedRequestError)
  AlgorithmMismatchError = Class.new(UnauthorizedRequestError)
end
