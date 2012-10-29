require "vcr_helper/version"

module VcrHelper
  #
  # Must be included after #setup and #teardown have been defined.
  #
  # Pass VR=true to a test or rake to open network connectivity and re-record all requests and responses
  # Otherwise, blocks all network connectivity and uses cassettes to replay requests and responses.
  # 
  # Stores all cassettes in test/vcr_cassettes.
  # Each test case is saved to a different file.
  #

  def record?
    ENV['VR']
  end

  def cassette_name
    (self.class.name.underscore.gsub('/','_') + '__' + self.method_name.gsub(/^test[:_](\s?)/, '')).strip.downcase.squeeze(' ').gsub(/[^a-z0-9\s_]/, '').gsub(' ', '_')
  end

  def setup_with_vcr
    puts __method__
    # call this at the top of ActiveSupport::TestCase
    if record?
      FileUtils.rm_rf "#{VCR.configuration.cassette_library_dir}/#{cassette_name}.yml"
      VCR.insert_cassette(cassette_name, :record => :all)
      ::FakeWeb.allow_net_connect = true
    else
      VCR.insert_cassette(cassette_name, :record => :none, :match_requests_on => [:host, :path, :q])
      ::FakeWeb.allow_net_connect = false
    end
    setup_without_vcr
  end

  def teardown_with_vcr
    teardown_without_vcr
    VCR.eject_cassette
  end

  def self.included(base)
    puts "LOADING VCR HELPER"
    base.class_eval do
      # We use alias method chain here because we need these setup methods to wrap the entire suit
      alias_method_chain :setup, :vcr
      alias_method_chain :teardown, :vcr
    end
  end
end

