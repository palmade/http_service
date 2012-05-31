require File.expand_path(File.join(File.dirname(__FILE__),'../spec_helper'))
module Palmade::HttpService
 describe Base do

   config = YAML.load(CONFIG_CARESHARING_YML_TEMPLATE)
   let(:base) { Base.new(config) }

   before(:all) do
    base.boot!
   end

   describe "#new" do

    let(:passed_logger){ Logger.new(Tempfile.new('rails `o stdout')) }

    subject{ Base.new(config,:logger => passed_logger) }

    its(:options){ should be_an_instance_of(Hash) }

    context "when logger is specified" do
     its(:logger){ should be_equal(passed_logger) }
    end

    context "when logger is not specified" do
     subject{ Base.new(config) }

     it "should have a logger which logs to STDOUT" do
      Logger.should_receive(:new).with($stdout)
      Base.new(config)
     end

     its(:logger){ should be_an_instance_of(Logger) }
    end

    context "when no config is specified" do
     subject{ Base.new(nil) }

     its(:config){ should be_nil }
    end

    context "when config is specified" do
     its(:config){ should be_an_instance_of(Hash) }

     its(:config){ should have_key("api") }
    end

    its(:http_service){ should be_nil }
   end

   describe "#boot!" do
    subject{ Base.new(config) }

    let(:api_config){ base.api_config(base.config) }
    let(:http_service){ base.http_service }
    let(:options){ base.options }

    context "when base has api config" do
     context "it should return base object" do

      it "should have an api config" do
       api_config.should be_an_instance_of(Hash)
      end

      context "when there are no oauth configs" do

       it "should have an empty options hash" do
        pending "oauth configs"

        options.should be_an_instance_of(Hash)
        options.should be_empty
       end
      end

      it "should have http service created" do
       http_service.should be_an_instance_of(Service)
      end

      context "when log activity is needed" do

       it "should be specified at api config" do
        api_config.should have_key("log_activity")
        api_config['log_activity'].should equal(true)
       end

       it "should have log activity" do
        http_service.log_activity.should be_true
       end
      end

     end
    end

    context "when base has no api config" do
     subject{ Base.new(nil) }

     it { should raise_error }
    end
   end

   describe "#base_url" do
    subject{ base.http_service.base_url }

    it "should return the base url" do
     should be_an_instance_of(String)
     should eql("http://0.0.0.0:3000")
    end
   end

   describe "#api_config" do
    subject{ base.api_config(base.config) }

    it "should return api configurations" do
     should be_an_instance_of(Hash)
    end
   end

   describe "#oauth_config" do
    subject{ base.oauth_config(base.config) }

    it "should return oauth config if specified" do
     pending "oauth configs"
     should be_nil
    end
   end

   describe "#oauth_echo_config" do
    subject{ base.oauth_echo_config(base.config) }

    it "should return oauth config if specified" do
     pending "oauth configs"
     should be_nil
    end
   end

   context "when http request are invoked" do
    shared_context "any other http request that receives http headers" do

      it "should return a service response object" do
       subject.should be_an_instance_of(ServiceResponse)
      end
    end

    describe "#post" do
     subject{ invoke_request(:post,"v1/users!authenticate","data" => {:guid=>"9039113597322682", :password=>"gl4jvu"}) }

     it "should invoke post request" do
      subject["REQUEST_METHOD"].should eql("POST")
     end

     it_behaves_like "any other http request that receives http headers"
    end

    describe "#get" do
     subject{ invoke_request(:get,"/") }

     it "should invoke get request" do
      subject["REQUEST_METHOD"].should eql("GET")
     end

     it_behaves_like "any other http request that receives http headers"
    end
   end

 end
end
