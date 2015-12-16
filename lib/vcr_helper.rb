require 'vcr'
require 'vcr_helper/version'

if defined?(Test::Unit)
  require 'webmock/test_unit'
end
if defined?(Rspec)
  require 'webmock/rspec'
end

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

  def build_rspec_cassette_name(example_group)
    if example_group
      example_group[:description_args].clone.unshift(*build_rspec_cassette_name(example_group[:example_group]))
    else
      []
    end
  end

  def cassette_name
    if self.respond_to?(:described_class)
      build_rspec_cassette_name(self.example.metadata).join("_").underscore.gsub('/','_').gsub(' ', '_').gsub(/[^a-z0-9\s_]/, '')
    else
      test_class = self.class.name.underscore.gsub('/','_')
      test_method = self.method_name.gsub(/^test[:_]+(\s?)/, '')
      class_and_method = (test_class + '__' + test_method)
      class_and_method.strip.downcase.squeeze(' ').gsub(/[^a-z0-9\s_]/, '').gsub(' ', '_')
    end
  end

  # This method will be overridden in Test::Unit with the alias_method_chain method below; it exists to make rspec work
  def setup_without_vcr
  end

  def setup_with_vcr
    # call this at the top of ActiveSupport::TestCase
    if record?
      FileUtils.rm_rf "#{VCR.configuration.cassette_library_dir}/#{cassette_name}.yml"
      VCR.insert_cassette(cassette_name, :record => :all)
      ::WebMock.allow_net_connect!
    else
      VCR.insert_cassette(cassette_name, :record => :none, :match_requests_on => [:host, :path])
      ::WebMock.disable_net_connect!
    end
    setup_without_vcr
  end

  # This method will be overridden in Test::Unit with the alias_method_chain method below; it exists to make rspec work
  def teardown_without_vcr
  end

  def teardown_with_vcr
    teardown_without_vcr
    VCR.eject_cassette
  end

  def self.included(base)
    base.class_eval do
      if base.respond_to?(:before)
        base.before do
          setup_with_vcr
        end
        base.after do
          teardown_with_vcr
        end
      else
        # We use alias method chain here because we need these setup methods to wrap the entire suit
        alias_method_chain :setup, :vcr
        alias_method_chain :teardown, :vcr
      end
    end
  end
end
