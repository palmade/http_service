CONFIG_CARESHARING_YML_TEMPLATE = <<CCYT
api:
  server: http://0.0.0.0:3000/api
  log_activity: true
CCYT

$test_config = YAML.load(CONFIG_CARESHARING_YML_TEMPLATE)

require 'palmade/puppet_master'

Master = Palmade::PuppetMaster::Master
m = Master.new(:listen => ["0.0.0.0:3000"])

class RackApp
  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new
    msg = env.to_json
    res.write msg
    res.finish
  end
end

app = Proc.new { |env| RackApp.new  }

family = m.single_family!
thin = family.thin_puppet(:adapter => :rack_legacy,:adapter_options => {:rack_boot => app})
module Palmade::HttpService
 class Base
  attr_reader :options
 end
end

module HelperMethods
 def invoke_request(req,*args)
  base.send(req,args[0],args[1])
 end
end
RSpec.configure do |config|
 config.before(:all) do
  @pid = Kernel.fork { m.start.join }
 end
 config.after(:all) do
  Process.kill("QUIT",@pid)
 end
 config.include HelperMethods
end
