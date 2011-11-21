require "test/unit"
require "mocha"
require "webmock/test_unit"
require "pathname"
require "http_parser.rb"
require "stringio"

class Test::Unit::TestCase
  FIXTURES_DIR = Pathname.new(__FILE__).parent + "fixtures"
  
  def self.test(test_description, &test_block)
    define_method("test #{test_description}", &test_block)
  end
  
private

  def read_fixture(fixture_name)
    (FIXTURES_DIR + "#{fixture_name}.txt").read
  end
  
  module RackEnvHelper

    def rack_env_from_fixture(fixture_name)
      parser, request_body = Http::Parser.new, StringIO.new
      parser.on_body = proc {|chunk| request_body << chunk}
      parser.on_message_complete = proc { request_body.rewind }
      parser << read_fixture(fixture_name)

      rack_env = rack_normalize_headers(parser.headers)

      rack_env.merge!({"SCRIPT_NAME"    => "",
                       "REQUEST_METHOD" => parser.http_method,
                       "PATH_INFO"      => parser.request_path,
                       "QUERY_STRING"   => parser.query_string,
                       "SERVER_NAME"    => rack_env["HTTP_HOST"],
                       "SERVER_PORT"    => "443"})

      rack_env.merge!({"rack.version"      => [1, 3],
                       "rack.url_scheme"   => "https",
                       "rack.input"        => request_body,
                       "rack.errors"       => STDERR,
                       "rack.multithread"  => false,
                       "rack.multiprocess" => false,
                       "rack.run_once"     => false})

      rack_env
    end

    def rack_normalize_headers(headers_hash)
      headers_hash.inject({}) do |env,(header,value)|
        header = "http_#{header}" unless header =~ /\A(content-type|content-length)\Z/i
        env[header.upcase.tr('-', '_')] = value
        env
      end
    end
    
  end
  
end