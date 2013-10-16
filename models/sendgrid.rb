require File.expand_path(File.join(File.dirname(__FILE__), 'sendgrid_event'))
require 'base64'
require 'json'

class SendGrid
  def initialize
    @username = "sendgrid_and_km"
    @password = "PkCUn01sTTXyPIp"
  end

  # Records a KM Account-based event for each SendGrid event contained in
  #  the collection posted.
  # http://sendgrid.com/docs/API_Reference/Webhooks/event.html
  #
  # @param body [string] a POST string representing an array of SendGrid events
  # @return nil
  def parse_and_record_events(body)
    events = EventsParser.new( JSON.parse(body) )
    events.record_all()
  end

  # Checks for basic HTTP authentication with the Authorization header
  #
  # @param header_signature [String] the Authorization header from SendGrid's postback
  # @return [Boolean] whether the signature matches the generated one
  def valid_signature?(header_signature)
    return !header_signature.nil? && header_signature.strip == signature.strip
  end

  private
  def signature
    user_and_pass = [@username, @password].join(":")
    "Basic #{Base64.encode64(user_and_pass).strip}"
  end

  class EventsParser < Array
    def initialize(sendgrid_events = [])
      sendgrid_events.each {|event|
        self << SendGridEvent.new(event)
      }
    end

    def record_all
      self.each {|event|
        event.record
      }
    end
  end
end