# encoding: utf-8
require "ibatele_sms/version"
require "ibatele_sms/errors"

module IbateleSms

  extend self

  HOST      = 'integrationapi.net'
  USE_SSL   = true
  PHONE_RE  = /\A(\+7|7|8)(\d{10})\Z/
  TITLE_SMS = "Anlas.ru"

  def login(usr, pass)

    res = ::IbateleSms::Base.sessionid(usr, pass)
    raise res if res.is_a?(::IbateleSms::Error)

    @usr     = usr
    @pass    = pass
    @session = res

    self

  end # login

  def message(phone, msg)

    return unless self.active?

    phone = ::IbateleSms::convert_phone(phone)
    return false unless phone

    res = ::IbateleSms::Base.sms_send(@session, phone, msg)

    # Повторная авторизация и отправка сообщения
    if res.is_a?(::IbateleSms::SessionExpiredError)

      self.login(@usr, @pass)
      self.message(phone, msg)

    elsif res.is_a?(::IbateleSms::Error)
      raise res
    end

    res

  end # message

  def balance
    ::IbateleSms::Base.balance(@session)
  end # balance

  def sms_state(mid)

    res = ::IbateleSms::Base.sms_state(@session, mid)
    raise res if res.is_a?(::IbateleSms::Error)

    res

  end # sms_state

  def sms_stats(start, stop)

    res = ::IbateleSms::Base.sms_stats(@session, start, stop)
    raise res if res.is_a?(::IbateleSms::Error)

    res

  end # sms_stats

  def logout

    @session = nil
    self

  end # logout

  def turn_on

    @active = true
    puts "Отправка SMS ВКЛЮЧЕНА"
    self

  end # turn_on

  def turn_off

    @active = false
    puts "Отправка SMS ОТКЛЮЧЕНА"
    self

  end # turn_off

  def debug_on

    @debug = true
    puts "Отладочный режим ВКЛЮЧЕН"
    self

  end # debug_on

  def debug_off

    @debug = false
    puts "Отладочный режим ОТКЛЮЧЕН"
    self

  end # debug_off

  def debug?
    @debug === true
  end # debug?

  def active?
    @active != false
  end # active?

  def valid_phone?(phone)
    !(phone.to_s.gsub(/\D/, "") =~ ::IbateleSms::PHONE_RE).nil?
  end # valid_phone?

  def convert_phone(phone, prefix = "7")

    r = phone.to_s.gsub(/\D/, "").scan(::IbateleSms::PHONE_RE)
    r.empty? ? nil : "#{prefix}#{r.last.last}"

  end # convert_phone

end # IbateleSms

require "ibatele_sms/base"
