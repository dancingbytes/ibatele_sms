# encoding: utf-8
require 'em-net-http'

module IbateleSms

  module Base

    extend self

    def sessionid(user, password)

      data = ""
      em_run do |http|

        log("[sessionid] => /rest/User/SessionId?login=#{escape(user)}&password=#{escape(password)}")

        res  = http.get("/rest/User/SessionId?login=#{escape(user)}&password=#{escape(password)}")
        data = (res.body || "").gsub('"', '')

        log("[sessionid] <= #{data}")

      end # em_run

      return data unless data.is_a?(::Hash)

      case data["Code"]

        when 1 then ::IbateleSms::AuthError.new(data["Desc"])
        when 4 then ::IbateleSms::AuthError.new(data["Desc"])
        else        ::IbateleSms::UnknownError.new(data["Desc"])

      end # case

    end # sessionid

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

      return data unless data.is_a?(::Hash)

      case data["Code"]

        when 1 then ::IbateleSms::SessionIdError.new(data["Desc"])
        when 2 then ::IbateleSms::ArgumentError.new(data["Desc"])
        when 4 then ::IbateleSms::SessionExpiredError.new(data["Desc"])
        when 6 then ::IbateleSms::SourceAddressError.new(data["Desc"])
        else        ::IbateleSms::UnknownError.new(data["Desc"])

      end # case

    end # sms_send

    def balance(sid)

      data = ""
      em_run do |http|

        log("[balance] => /rest/User/Balance?sessionId=#{escape(sid)}")

        res  = http.get("/rest/User/Balance?sessionId=#{escape(sid)}")
        data = (res.body || "").to_f

        log("[balance] <= #{data}")

      end # em_run
      data

    end # balance

    def sms_state(sid, mid)

      data = ""
      em_run do |http|

        log("[sms_state] => /rest/Sms/State?sessionId=#{escape(sid)}&messageId=#{escape(mid)}")

        res  = http.get("/rest/Sms/State?sessionId=#{escape(sid)}&messageId=#{escape(mid)}")
        data = ::JSON.parse(res.body) rescue {}

        log("[sms_state] <= #{data}")

      end # em_run

      return ::IbateleSms::ArgumentError.new(data["Desc"]) if data["Code"] == 1
      data

    end # sms_state

    def sms_stats(sid, start, stop)

      data = ""
      em_run do |http|

        log("[sms_stats] => /rest/Sms/Statistics?sessionId=#{escape(sid)}&startDateTime=#{escape(start)}&endDateTime=#{escape(stop)}")

        res  = http.get("/rest/Sms/Statistics?sessionId=#{escape(sid)}&startDateTime=#{escape(start)}&endDateTime=#{escape(stop)}")
        data = ::JSON.parse(res.body) rescue {}

        log("[sms_stats] <= #{data}")

      end # em_run

      return data if data["Code"].nil?

      case data["Code"]

        when 1 then ::IbateleSms::SessionIdError.new(data["Desc"])
        when 2 then ::IbateleSms::ArgumentError.new(data["Desc"])
        when 9 then ::IbateleSms::ArgumentError.new(data["Desc"])
        else        ::IbateleSms::UnknownError.new(data["Desc"])

      end # case

    end # sms_stats

    private

    def escape(str)
      ::URI::escape(str || "")
    end # escape

    def log(msg)

      puts(msg) if ::IbateleSms.debug?
      self

    end # log

    def em_run

      ::EM.run do

#        ::Fiber.new do

          ::Net::HTTP.start( ::IbateleSms::HOST, :use_ssl => ::IbateleSms::USE_SSL ) do |http|

            begin
              yield(http)
            rescue => e
              puts e.message
              puts e.backtrace.join("\n")
            end

          end
          ::EM.stop_event_loop

#       end.resume

      end # run

    end # em_run

  end # Base

end # IbateleSms
