# encoding: utf-8
module IbateleSms

  class Error < ::StandardError; end

  class ConnectionError < ::IbateleSms::Error; end

  class RequestError < ::IbateleSms::Error; end

  class TimeoutError < ::IbateleSms::Error; end

  class RespondError < ::IbateleSms::Error; end

  class ArgumentError < ::IbateleSms::Error; end

  class InactiveError < ::IbateleSms::Error; end

  class UnknownError < ::IbateleSms::Error; end

end # IbateleSms
