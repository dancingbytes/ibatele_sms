# encoding: utf-8
require 'nokogiri'
require 'net/http'
require 'timeout'

require 'ibatele_sms/version'
require 'ibatele_sms/errors'

module IbateleSms

  extend self

  TIMEOUT   = 30.freeze
  HOST      = 'lk.ibatele.com'.freeze
  PORT      = 443.freeze
  USE_SSL   = true.freeze
  RETRY     = 3.freeze
  WAIT_TIME = 5.freeze
  PHONE_RE  = /\A(\+7|7|8)(\d{10})\Z/.freeze
  TITLE_SMS = "Anlas.ru".freeze

  def login(usr, pass)

    @usr  = usr
    @pass = pass
    self

  end # login

  def message(phone, msg, opts = {})

    return ::IbateleSms::InactiveError.new("Работа смс остановлена") unless self.active?

    new_phone = ::IbateleSms::convert_phone(phone)
    return ::IbateleSms::ArgumentError.new("Неверный формат телефона: #{phone}") unless new_phone

    ::IbateleSms::Base.sms_send(@usr, @pass, phone, msg, opts)

  end # message

  def state(args)

    return ::IbateleSms::InactiveError.new("Работа смс остановлена") unless self.active?
    ::IbateleSms::Base.sms_state(@usr, @pass, args)

  end # state

  def balance

    return ::IbateleSms::InactiveError.new("Работа смс остановлена") unless self.active?
    ::IbateleSms::Base.balance(@usr, @pass)

  end # balance

  def time

    return ::IbateleSms::InactiveError.new("Работа смс остановлена") unless self.active?
    ::IbateleSms::Base.time(@usr, @pass)

  end # time

  def info(*args)

    return ::IbateleSms::InactiveError.new("Работа смс остановлена") unless self.active?
    ::IbateleSms::Base.info(@usr, @pass, args)

  end # info

  def error?(e)
    e.is_a?(::IbateleSms::Error)
  end # error?

  def logout

    @usr  = nil
    @pass = nil
    self

  end # logout

  def turn_on

    @active = true
    puts "[IbateleSms] Отправка SMS ВКЛЮЧЕНА"
    self

  end # turn_on

  def turn_off

    @active = false
    puts "[IbateleSms] Отправка SMS ОТКЛЮЧЕНА"
    self

  end # turn_off

  def debug_on

    @debug = true
    puts "[IbateleSms] Отладочный режим ВКЛЮЧЕН"
    self

  end # debug_on

  def debug_off

    @debug = false
    puts "[IbateleSms] Отладочный режим ОТКЛЮЧЕН"
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

require 'ibatele_sms/request'
require 'ibatele_sms/respond'
require "ibatele_sms/base"
