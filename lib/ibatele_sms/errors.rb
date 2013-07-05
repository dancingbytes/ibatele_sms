# encoding: utf-8
module IbateleSms

  class Error < ::StandardError; end

  class SessionIdError < ::IbateleSms::Error; end

  class SessionExpiredError < ::IbateleSms::Error; end

  class AuthError < ::IbateleSms::Error; end

  class ArgumentError < ::IbateleSms::Error; end

  class SourceAddressError < ::IbateleSms::Error; end

  class MissingError < ::IbateleSms::Error; end

  class UnknownError < ::IbateleSms::Error; end

=begin
  class DestinationAddressError < ::IbateleSms::Error

    def message
      "Неверно введен адрес отправителя"
    end # message

  end # DestinationAddressError

  class SourceAddressError < ::IbateleSms::Error

    def message
      "Неверно введен адрес получателя"
    end # message

  end # SourceAddressError

  class IllegalDestinationAddressError < ::IbateleSms::Error

    def message
      "Недопустимый адрес получателя"
    end # message

  end # IllegalDestinationAddressError

  class RejectProviderError < ::IbateleSms::Error

    def message
      "Отклонено смс-центром"
    end # message

  end # RejectProviderError

  class ExpiredSmsError < ::IbateleSms::Error

    def message
      "Просрочено (истек срок жизни сообщения)"
    end # message

  end # ExpiredSmsError

  class RejectPlatformError < ::IbateleSms::Error

    def message
      "Отклонено платформой"
    end # message

  end # RejectPlatformError

  class RejectError < ::IbateleSms::Error

    def message
      "Отклонено"
    end # message

  end # RejectError



  class MissingSmsError < ::IbateleSms::Error

    def message
      "Сообщение не попало в БД, либо оно старше 48 часов"
    end # message

  end # MissingSmsError

  class DeleteError < ::IbateleSms::Error

    def message
      "Удалено"
    end # message

  end # DeleteError
=end

end # IbateleSms
