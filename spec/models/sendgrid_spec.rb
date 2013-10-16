require File.expand_path(File.join(File.dirname(__FILE__), '..', 'setup'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'models', 'sendgrid'))

describe SendGrid do
  before do
    @sendgrid = SendGrid.new
  end

  describe "#parse_and_record_events" do
=begin
    let (:with_timestamp) {
      '[{"email":"john.doe@sendgrid.com","event":"open","account_id":5,"timestamp":1356998400}]'
    }
    let (:with_template) {
      '[{"email":"john.doe@sendgrid.com","event":"open","account_id":5,"template_name":"a_template"}]'
    }
    let (:with_url) {
      '[{"email":"john.doe@sendgrid.com","event":"click","account_id":5,"url":"http://www.example.com"}]'
    }

    it "does not record a KM event for bcc@kissmetrics.com" do
      @sendgrid.parse_and_record({"email"=>"bcc@kissmetrics.com","account_id"=>5,"event"=>"open"})
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for support@kissmetrics.com" do
      @sendgrid.parse_and_record({"email"=>"support@kissmetrics.com","account_id"=>5,"event"=>"open"})
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for billing@kissmetrics.com" do
      @sendgrid.parse_and_record({"email"=>"billing@kissmetrics.com","account_id"=>5,"event"=>"open"})
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for cancelations@kissmetrics.com" do
      @sendgrid.parse_and_record({"email"=>"cancelations@kissmetrics.com","account_id"=>5,"event"=>"open"})
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for feedback@kissmetrics.com" do
      @sendgrid.parse_and_record({"email"=>"feedback@kissmetrics.com","account_id"=>5,"event"=>"open"})
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for bcc@kissmetrics.com" do
      @sendgrid.parse_and_record_events('[{"email":"bcc@kissmetrics.com","account_id":5,"event"=>"open"}]')
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for support@kissmetrics.com" do
      @sendgrid.parse_and_record_events('[{"email":"support@kissmetrics.com","account_id":5,"event"=>"open"}]')
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for billing@kissmetrics.com" do
      @sendgrid.parse_and_record_events('[{"email":"billing@kissmetrics.com","account_id":5,"event"=>"open"}]')
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for cancelations@kissmetrics.com" do
      @sendgrid.parse_and_record_events('[{"email":"cancelations@kissmetrics.com","account_id":5,"event"=>"open"}]')
      KM.data_recorded.should be_empty
    end

    it "does not record a KM event for feedback@kissmetrics.com" do
      @sendgrid.parse_and_record_events('[{"email":"feedback@kissmetrics.com","account_id":5,"event"=>"open"}]')
      KM.data_recorded.should be_empty
    end

    context "when the account id is not included" do
      it "does not record a KM event" do
        @sendgrid.parse_and_record({"email"=>"john.doe@sendgrid.com","event"=>"open"})
        KM.data_recorded.should be_empty
      end
    end

    context "when the account id is not included" do
      it "does not record a KM event" do
        @sendgrid.parse_and_record_events('[{"email":"john.doe@sendgrid.com","event":"open"}]')
        KM.data_recorded.should be_empty
      end
    end

    context "when the account id is included" do
      context "when the timestamp is included" do
        it "records a KM event with the provided timestamp" do
          @sendgrid.parse_and_record(with_timestamp)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email open", :props => {
            "_t" => 1356998400, "_d" => 1
          }, :id => "My Account")
        end
      end

      context "when the template name is included" do
        it "records a KM event with the provided template_name" do
          @sendgrid.parse_and_record(with_template)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email open", :props => {
            "Email Template Name" => "a_template"
          }, :id => "My Account")
        end
      end

      context "when the URL clicked is included" do
        it "records a KM event with the clicked URL" do
          @sendgrid.parse_and_record(with_url)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email click", :props => {
            "Email URL Clicked" => "http://www.example.com"
          }, :id => "My Account")
        end
      end
    end

    context "when the account id is included" do
      context "when the timestamp is included" do
        it "records a KM event with the provided timestamp" do
          @sendgrid.parse_and_record_events(with_timestamp)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email open", :props => {
            "_t" => 1356998400, "_d" => 1
          }, :id => "My Account")
        end
      end

      context "when the template name is included" do
        it "records a KM event with the provided template_name" do
          @sendgrid.parse_and_record_events(with_template)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email open", :props => {
            "Email Template Name" => "a_template"
          }, :id => "My Account")
        end
      end

      context "when the URL clicked is included" do
        it "records a KM event with the clicked URL" do
          @sendgrid.parse_and_record_events(with_url)
          should_track(KM.data_recorded.keys.last, :type => :event, :action => "Templated Email click", :props => {
            "Email URL Clicked" => "http://www.example.com"
          }, :id => "My Account")
        end
      end
    end
=end
  end

  describe "#valid_signature?" do
    before do
      @sendgrid.stub(:signature).and_return("valid_signature")
    end

    context "when the given signature is nil" do
      it "returns false" do
        @sendgrid.valid_signature?(nil).should be_false
      end
    end

    context "when the given signature is generated from incorrect credentials" do
      it "returns false" do
        @sendgrid.valid_signature?("wrong_signature").should be_false
      end
    end

    context "when the given signature is generated from correct credentials" do
      it "returns true" do
        @sendgrid.valid_signature?("valid_signature").should be_true
      end
    end
  end

end