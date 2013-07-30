# encoding: utf-8
module IbateleSms

  class Error < ::StandardError; end

  class ConnectionError < ::IbateleSms::Error; end

  class SessionIdError < ::IbateleSms::Error; end

  class SessionExpiredError < ::IbateleSms::Error; end

  class SendingError < ::IbateleSms::Error; end

  class TimeoutError < ::IbateleSms::Error; end

  class AuthError < ::IbateleSms::Error; end

  class ArgumentError < ::IbateleSms::Error; end

  class SourceAddressError < ::IbateleSms::Error; end

  class MissingError < ::IbateleSms::Error; end

  class InactiveError < ::IbateleSms::Error; end

  class UnknownError < ::IbateleSms::Error; end

end # IbateleSms
