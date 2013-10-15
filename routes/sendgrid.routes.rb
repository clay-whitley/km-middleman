require File.expand_path(File.join(File.dirname(__FILE__), '..', 'models', 'sendgrid'))

post '/sendgrid.track' do
  sendgrid = SendGrid.new

  # Check for basic authentication
  if sendgrid.valid_signature?(env['HTTP_AUTHORIZATION'])
    sendgrid.parse_and_record_events(request.body.read)
    status(200)
    body("Acknowledged")
  else
    # SendGrid expects a 200 HTTP response to the POST.
    # Otherwise, the event notification will be retried.
    status(200)
    body("Basic Authentication Failed")
  end
end