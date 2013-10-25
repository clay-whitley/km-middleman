require 'httparty'
require 'uri'

class SendGridEvent
  def initialize(event_hash = {})
    @event = event_hash
    @post_url = "https://app.kissmetrics.com/services/track"
    @origin = "http://middleman.kissmetrics.com"
  end

  def record
    if can_record_event?
      post_hash = {
        :_n => km_event_name,
        :current_account => account_id
      }.merge(km_properties)

      puts "Attempting to post with parameters: #{URI.encode_www_form(post_hash)}"
      HTTParty.post(@post_url, :headers => {"Origin" => @origin}, :body => URI.encode_www_form(post_hash))
    end
    nil
  end

  def can_record_event?
    !from_internal_email? && has_param?("account_id") && has_param?("event")
  end

  def account_id
    @event["account_id"]
  end

  def km_event_name
    "Templated Email #{@event["event"]}"
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
    internal_emails.index(@event["email"])
  end
end