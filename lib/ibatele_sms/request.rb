# encoding: utf-8
module IbateleSms

  class Request

    class << self

      def sms_send(params = {})
        new(params).sms_send.to_s
      end # sms_send

      def sms_state(params = {})
        new(params).sms_state.to_s
      end # sms_state

      def balance(params = {})
        new(params).balance.to_s
      end # balance

      def time(params = {})
        new(params).time.to_s
      end # time

      def info(params = {})
        new(params).info.to_s
      end # info

    end # class << self

    def initialize(params = {})
      @params = params
    end # new

    def sms_send

      create_xml do |xml|

        xml.message({ "type" => "sms" }) {

          xml.sender   xml_escape(@params[:sender])
          xml.text!    xml_escape(@params[:text])
          xml.abonent({

            "phone"           => @params[:phone],
            "number_sms"      => 1,
            "client_id_sms"   => @params[:client_id_sms],
            "time_send"       => @params[:time_send],
            "validity_period" => @params[:validity_period]

          })

        } # message

      end # create_xml

    end # sms_send

    def sms_state

      create_xml do |xml|

        xml.get_state {
          xml.id_sms @params[:mid]
        } # message

      end # create_xml

    end # sms_state

    def balance
      create_xml
    end # balance

    def time
      create_xml
    end # time

    def info

      create_xml do |xml|

        xml.phones {
          xml.phone @params[:phone]
        } # message

      end # create_xml

    end # info

    def to_s
      @source ? @source.to_xml : ""
    end # to_s

    private

    def create_xml

      @source = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

        xml.request {

          auth(xml)

          yield(xml) if block_given?

        } # request

      end # builder
      self

    end # create_xml

    def auth(xml)

      xml.security {

        xml.login({
          "value" => xml_escape(@params[:login])
        })

        xml.password({
          "value" => xml_escape(@params[:password])
        })

      } # security
      self

    end # auth

    def xml_escape(str)

      return nil if str.nil?

      str.
        gsub(/&/, "&amp;").
        gsub(/'/, "&apos;").
        gsub(/"/, "&quot;").
        gsub(/>/, "&gt;").
        gsub(/</, "&lt;")

    end # xml_escape

  end # Request

end # IbateleSms
