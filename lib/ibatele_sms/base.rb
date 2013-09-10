# encoding: utf-8
module IbateleSms

  module Base

    extend self

    def sms_send(login, pass, phone, msg, opts = {})

      client_id_sms = opts[:client_id] || [phone, rand].join

      r = ::IbateleSms::Request.sms_send({

        login:            login,
        password:         pass,

        sender:           ::IbateleSms::TITLE_SMS,
        text:             msg,
        phone:            phone,
        client_id_sms:    client_id_sms,
        time_send:        opts[:time_send],
        validity_period:  opts[:ttl]

      })

      uri   = url_for
      data  = {}
      err   = block_run do |http|

        log("[sms_send] => #{uri} \n\r#{r}")

        res = request do |headers|
          http.post(uri, r, headers)
        end

        log("[sms_send] <= #{uri} \n\r#{res.body}")

        data = ::IbateleSms::Respond.sms_send(res.body)

      end # block_run

      return err  if err
      return data if data.is_a?(::IbateleSms::Error)
      return data[:error] if data[:error]

      data[:client_id_sms] = client_id_sms
      data

    end # sms_send

    def sms_state(login, pass, mid)

      r = ::IbateleSms::Request.sms_state({

        login:      login,
        password:   pass,
        mid:        mid

      })

      uri   = url_for "state"
      data  = {}
      err   = block_run do |http|

        log("[sms_state] => #{uri} \n\r#{r}")

        res = request do |headers|
          http.post(uri, r, headers)
        end

        log("[sms_state] <= #{uri} \n\r#{res.body}")

        data = ::IbateleSms::Respond.sms_state(res.body)

      end # block_run

      return err  if err
      return data if data.is_a?(::IbateleSms::Error)

      data

    end # sms_state

    def balance(login, pass)

      r = ::IbateleSms::Request.balance({

        login:      login,
        password:   pass

      })

      uri   = url_for "balance"
      data  = {}
      err   = block_run do |http|

        log("[balance] => #{uri} \n\r#{r}")

        res = request do |headers|
          http.post(uri, r, headers)
        end

        log("[balance] <= #{uri} \n\r#{res.body}")

        data = ::IbateleSms::Respond.balance(res.body)

      end # block_run

      return err  if err
      return data if data.is_a?(::IbateleSms::Error)

      data

    end # balance

    def time(login, pass)

      r = ::IbateleSms::Request.time({

        login:      login,
        password:   pass

      })

      uri   = url_for "time"
      data  = {}
      err   = block_run do |http|

        log("[time] => #{uri} \n\r#{r}")

        res = request do |headers|
          http.post(uri, r, headers)
        end

        log("[time] <= #{uri} \n\r#{res.body}")

        data = ::IbateleSms::Respond.time(res.body)

      end # block_run

      return err  if err
      return data if data.is_a?(::IbateleSms::Error)

      data

    end # time

    def info(login, pass, phone)

      r = ::IbateleSms::Request.info({

        login:      login,
        password:   pass,
        phone:      phone

      })

      uri   = url_for "def"
      data  = {}
      err   = block_run do |http|

        log("[info] => #{uri} \n\r#{r}")

        res = request do |headers|
          http.post(uri, r, headers)
        end

        log("[info] <= #{uri} \n\r#{res.body}")

        data = ::IbateleSms::Respond.info(res.body)

      end # block_run

      return err  if err
      return data if data.is_a?(::IbateleSms::Error)

      data

    end # info

    private

    def log(msg)

      puts(msg) if ::IbateleSms.debug?
      self

    end # log

    def url_for(func = nil)

      uri = "/xml/"
      uri << "#{func}.php" unless func.nil?
      uri

    end # url_for

    def block_run

      error     = false
      try_count = ::IbateleSms::RETRY

      begin

        ::Timeout::timeout(::IbateleSms::TIMEOUT) {

          ::Net::HTTP.start(
            ::IbateleSms::HOST,
            ::IbateleSms::PORT,
            :use_ssl => ::IbateleSms::USE_SSL
          ) do |http|
            yield(http)
          end

        }

      rescue ::Errno::ECONNREFUSED

        if try_count > 0
          try_count -= 1
          sleep ::IbateleSms::WAIT_TIME
          retry
        else
          error = ::IbateleSms::ConnectionError.new("Прервано соедиение с сервером")
        end

      rescue ::Timeout::Error

        if try_count > 0
          try_count -= 1
          sleep ::IbateleSms::WAIT_TIME
          retry
        else
          error = ::IbateleSms::TimeoutError.new("Превышен интервал ожидания #{::IbateleSms::TIMEOUT} сек. после #{::IbateleSms::RETRY} попыток")
        end

      rescue => e
        error = ::IbateleSms::UnknownError.new(e.message)
      end

      error

    end # block_run

    def request

      try_count = ::IbateleSms::RETRY
      headers   = {
        "Content-Type" => "text/xml; charset=utf-8"
      }

      res = yield(headers)
      while(try_count > 0 && res.code.to_i >= 300)

        log("[retry] #{try_count}. Wait #{::IbateleSms::WAIT_TIME} sec.")

        res = yield(headers)
        try_count -= 1
        sleep ::IbateleSms::WAIT_TIME

      end # while

      res

    end # request

  end # Base

end # IbateleSms
