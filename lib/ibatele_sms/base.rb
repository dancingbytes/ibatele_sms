# encoding: utf-8
require 'em-net-http'

module IbateleSms

  module Base

    extend self

    MSG_CODES = {

      -1  => "Отправлено (передано в мобильную сеть)",
      -2  => "В очереди",
      47  => "Удалено",
      -98 => "Остановлено",
      0   => "Доставлено абоненту",
      10  => "Неверно введен адрес отправителя",
      11  => "неверно введен адрес получателя",
      41  => "недопустимый адрес получателя",
      42  => "Отклонено смс-центром",
      46  => "Просрочено (истек срок жизни сообщения)",
      48  => "Отклонено платформой",
      69  => "Отклонено",
      99  => "Нетзвестно",
      255 => "Сообщение не попало в БД, либо оно старше 48 часов"

    }.freeze

    def sessionid(user, password)

      data = ""
      em_run do |http|

        log("[sessionid] => /rest/User/SessionId?login=#{escape(user)}&password=#{escape(password)}")

        res  = http.get("/rest/User/SessionId?login=#{escape(user)}&password=#{escape(password)}")
        data = (res.body || "").strip.gsub('"', '')

        log("[sessionid] <= #{data}")

      end # em_run
      data

    end # sessionid

    def balance(sid)

      data = ""
      em_run do |http|

        log("[balance] => /rest/User/Balance?sessionId=#{escape(sid)}")

        res  = http.get("/rest/User/Balance?sessionId=#{escape(sid)}")
        data = (res.body || "").strip.to_f

        log("[balance] <= #{data}")

      end # em_run
      data

    end # balance

    def sms_send(sid, phone, msg, ttl = 48*60)

      request = {

        sessionId:          sid,
        data:               msg,
        validity:           ttl,
        destinationAddress: phone,
        sourceAddress:      ::IbateleSms::TITLE_SMS

      }

      data = ""
      em_run do |http|

        pr = ::URI.encode_www_form(request)
        log("[sms_send] => /rest/Sms/Send  #{pr}")

        res  = http.post("/rest/Sms/Send", pr)
        data = ::JSON.parse(res.body) rescue {}

        log("[sms_send] <= #{data}")

      end # em_run
      data

    end # sms_send

    def sms_state(sid, mid)

      data = ""
      em_run do |http|

        log("[sms_state] => /rest/Sms/State?sessionId=#{escape(sid)}&messageId=#{escape(mid)}")

        res  = http.get("/rest/Sms/State?sessionId=#{escape(sid)}&messageId=#{escape(mid)}")
        data = ::JSON.parse(res.body) rescue {}

        log("[sms_state] <= #{data}")

      end # em_run
      data

    end # sms_state

    def sms_stats(sid, start, stop)

      data = ""
      em_run do |http|

        log("[sms_stats] => /rest/Sms/Statistics?sessionId=#{escape(sid)}&startDateTime=#{escape(stop)}&endDateTime=#{stop}")

        res  = http.get("/rest/Sms/Statistics?sessionId=#{escape(sid)}&startDateTime=#{escape(stop)}&endDateTime=#{stop}")
        data = ::JSON.parse(res.body) rescue {}

        log("[sms_stats] <= #{data}")

      end # em_run
      data

    end # sms_stats

    private

    def escape(str)
      ::URI::escape(str)
    end # escape

    def log(msg)

      puts(msg) if ::IbateleSms.debug?
      self

    end # log

    def em_run

      ::EM.run do

        ::Fiber.new do

          ::Net::HTTP.start( ::IbateleSms::HOST, :use_ssl => ::IbateleSms::USE_SSL ) do |http|
            yield(http)
          end
          ::EM.stop_event_loop

        end.resume

      end # run

    end # em_run

  end # Base

end # IbateleSms
