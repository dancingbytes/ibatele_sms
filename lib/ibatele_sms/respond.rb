# encoding: utf-8
module IbateleSms

  class Respond

    class << self

      STATE_MESSAGE = {

        0   => "Ожидает отправки",
        1   => "Доставлено",
        2   => "Не доставлено",
        3   => "Доставка просрочена",
        4   => "Частичная доставка"

      }.freeze

      def sms_send(body)
        new(body).sms_send
      end # send_sms

      def sms_state(body)
        new(body).sms_state
      end # sms_state

      def balance(body)
        new(body).balance
      end # balance

      def time(body)
        new(body).time
      end # time

      def info(body)
        new(body).info
      end # info

    end # class << self

    def initialize(body)
      @doc = ::Nokogiri::XML::Document.parse(body)
    end # new

    def sms_send

      error = get_error
      return error if error

      res   = @doc.search(".//response/information").first

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.nil?

      if res.text == "send"

        {

          number_sms: res["number_sms"],
          id_sms:     res["id_sms"],
          parts:      res["parts"].to_i,
          id_turn:    res["id_turn"]

        }

      else

        {

          number_sms: res["number_sms"],
          error:      ::IbateleSms::RespondError.new(res.text)

        }

      end # if

    end # sms_send

    def sms_state

      error = get_error
      return error if error

      res   = @doc.search(".//response/state").first

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.nil?

      code = get_state(res.text)
      {

        time:     res["time"],
        state:    code,
        message:  STATE_MESSAGE[code] || "Неизвестная ошибка"

      }

    end # sms_state

    def balance

      error = get_error
      return error if error

      res   = @doc.search(".//response/money").first

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.nil?

      data = {
        balance:  res.text,
        currency: res["currency"],
        sms:      {}
      }

      @doc.search(".//response/sms").each do |sms|
        data[:sms][sms["area"]] = sms.text
      end # search

      data

    end # balance

    def time

      error = get_error
      return error if error

      res   = @doc.search(".//response/time").first

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.nil?

      res.text

    end # time

    def info

      error = get_error
      return error if error

      res   = @doc.search(".//response/phone").first

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.nil?

      return {} if res["operator"] != "unknown"

      {

        operator:   res["operator"],
        region:     res["region"],
        time_zone:  res["time_zone"]

      }

    end # info

    private

    def get_error

      error = @doc.search(".//response/error")
      ::IbateleSms::RequestError.new(error.first || "Неизвестная ошибка") if error.size > 0
      false

    end # get_error

    def get_state(msg)

      case (msg || "").downcase

        when "send"             then 0
        when "deliver"          then 1
        when "not_deliver"      then 2
        when "expired"          then 3
        when "partly_deliver"   then 4
        else -1

      end # case

    end # get_state

  end # Respond

end # IbateleSms
