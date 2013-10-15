require 'base64'
require 'httparty'
require 'json'

class SendGrid

  def initialize
    @username = "sendgrid_and_km"
    @password = "PkCUn01sTTXyPIp"
    @post_url = "https://app.kissmetrics.com/services/track"
  end

  # Records a KM Account-based event for each SendGrid event contained in
  #  the collection posted.
  # http://sendgrid.com/docs/API_Reference/Webhooks/event.html
  #
  # @param body [string] a POST string representing an array of SendGrid events
  # @return nil
  def parse_and_record_events(body)
    content = JSON.parse(body)
    content.each {|event|
      parser = EventParser.new(event)
      record_event(parser.account_id, parser.km_event_name, parser.km_properties) if parser.can_record_event?
    }
  end

  # Makes a POST to the KISSmetrics app's endpoint for account-based tracking.
  #
  # @param account_id [Int] corresponds to the KM Account ID
  # @param event [String] the KISSmetrics event name to record
  # @param properties [Hash] a hash of additional properties for recording
  # @return nil
  def record_event(account_id, event, properties={})
    post_hash = {
      :_n => event,
      :current_account => account_id
    }.merge(properties)

    HTTParty.post(@post_url, :body => post_hash)
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

  class EventParser
    def initialize(event_hash = {})
      @event = event_hash
    end

    def can_record_event?
      !from_internal_email? && has_param?("account_id")
    end

    def account_id
      @event["account_id"] if has_param?("account_id")
    end

    def email
      @event["email"] if has_param?("email")
    end

    def km_event_name
      "Templated Email #{@event["event"]}" if has_param?("event")
    end

    def km_properties
      km_props = {}
      if has_param?("url")
        km_props["Email URL Clicked"] = @event["url"]
      end
      if has_param?("template_name")
        km_props["Email Template Name"] = @event["template_name"]
      end
      if has_param?("timestamp")
        km_props["_t"] = @event["timestamp"]
        km_props["_d"] = 1
      end

      km_props
    end

    private
    def has_param?(parameter)
      !!@event[parameter]
    end

    def from_internal_email?
      internal_emails =  [
        "bcc@kissmetrics.com",
        "support@kissmetrics.com",
        "billing@kissmetrics.com",
        "cancelations@kissmetrics.com",
        "feedback@kissmetrics.com"
      ]
      internal_emails.index(self.email)
    end
  end

end