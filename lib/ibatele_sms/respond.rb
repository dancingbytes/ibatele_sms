# encoding: utf-8
module IbateleSms

  class Respond

    class << self

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

      res   = @doc.search(".//response/information")

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.size == 0

      res.inject([]) { |arr, el|

        if el.text == "send"

          arr << {

            number_sms: el["number_sms"],
            id_sms:     el["id_sms"],
            parts:      el["parts"],
            id_turn:    el["id_turn"]

          }

        else

          arr << {

            number_sms: el["number_sms"],
            error:      ::IbateleSms::RespondError.new(el.text)

          }

        end # if

      } # inject

    end # sms_send

    def sms_state

      error = get_error
      return error if error

      res   = @doc.search(".//response/state")

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.size == 0

      hash = {}
      res.each { |el|

        hash[el["id_sms"]] = {

          time:     el["time"],
          state:    get_state(el.text)

        }

      } # inject
      hash

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

      res   = @doc.search(".//response/phone")

      return ::IbateleSms::RequestError.new("Неверный ответ сервера") if res.size == 0

      hash = {}
      res.each { |el|

        if el["operator"] != "unknown"

          hash[el.text] = {

            operator:   el["operator"],
            region:     el["region"],
            time_zone:  el["time_zone"]

          }

        end # if

      } # each
      hash

    end # info

    private

    def get_error

      error = @doc.search(".//response/error")
      ::IbateleSms::RequestError.new(error.first || "Неизвестная ошибка") if error.size > 0
      false

    end # get_error

    def get_state(msg)

      case (msg || "").downcase

        when "send"             then 1
        when "not_deliver"      then 2
        when "expired"          then 3
        when "deliver"          then 0
        when "partly_deliver"   then 4
        else -1

      end # case

    end # get_state

  end # Respond

end # IbateleSms
