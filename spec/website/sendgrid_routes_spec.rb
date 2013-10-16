require File.expand_path(File.join(File.dirname(__FILE__), '..', 'setup'))
require 'base64'
require 'webmock/rspec'

describe "POST /sendgrid.track" do
  before do
    WebMock.disable_net_connect!
    stub_request(:post, "https://app.kissmetrics.com/services/track")

    @user_pass = ["sendgrid_and_km",
                  "PkCUn01sTTXyPIp"].join(':')
    @auth = "Basic #{Base64.encode64(@user_pass).strip}"
  end

  let(:click_data) {
    '[{"email":"example@kissmetrics.com","event":"click","template_name":"click_template","account_id":5,"url":"http://www.example.com/landing"}]'
    }
  let(:multi_line) {
    '[{"email":"tex@ample.com","template_name":"new_template","event":"open","account_id":5},
      {"email":"dex@ample.com","template_name":"new_template_alt","event":"open","account_id":5}]'
    }

  context "with wrong authentication in the headers" do
    before do
      post '/sendgrid.track', click_data, {'HTTP_AUTHORIZATION' => 'WRONG'}
    end
    it "responds with 200 status" do
      last_response.should be_ok
    end
    it "responds with 'Basic Authentication Failed' message" do
      last_response.body.should include("Basic Authentication Failed")
    end
  end

  context "with proper authentication in the headers" do
    it "responds with 200 status" do
      post '/sendgrid.track', click_data, {'HTTP_AUTHORIZATION' => @auth}
      last_response.should be_ok
    end

    it "responds with body 'Acknowledged' message" do
      post '/sendgrid.track', click_data, {'HTTP_AUTHORIZATION' => @auth}
      last_response.body.should include("Acknowledged")
    end

    it "POSTs the hash of parameters to app.kissmetrics.com/services/track" do
=begin
      post '/sendgrid.track', click_data, {'HTTP_AUTHORIZATION' => @auth}
      a_request(:post, "https://app.kissmetrics.com/services/track").
        with(:body => {
          "_n" => "Templated Email click",
          "Email Template Name" => "click_template",
          "Current Account" => 5,
          "Email URL Clicked" => "http://www.example.com/landing"
          }).should have_been_made.once
=end
    end

    it "makes a POST to app.kissmetrics.com/services/track for each event" do
=begin
      post '/sendgrid.track', multi_line, {'HTTP_AUTHORIZATION' => @auth}
      a_request(:post, "https://app.kissmetrics.com/services/track").
        with(:query => {
          "_n" => "Templated Email open",
          "Email Template Name" => "new_template",
          "Current Account" => 5
          }).should have_been_made.once

      a_request(:post, "https://app.kissmetrics.com/services/track").
        with(:body => {
          "_n" => "Templated Email open",
          "Email Template Name" => "new_template_alt",
          "Current Account" => 5
          }).should have_been_made.once
=end
    end
  end
end
