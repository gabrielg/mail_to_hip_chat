AirbrakeDomain = "airbrake.io"
msg = File.read("test/fixtures/airbrake_exception_body.txt")
ExtractionExpression = %r[\A\n+Project:\s([^\n]+)\n+     # Pull out the project name
                               Environment:\s([^\n]+)\n+ # Pull out the project environment
                               # Pull out the URL to the exception
                               ^(http://[^.]+\.#{Regexp.escape(AirbrakeDomain)}/errors/\d+)\n+
                               # Pull out the first line of the error message
                               Error\sMessage:\n-{14}\n([^\n]+)]mx
                               
puts msg.match(ExtractionExpression).to_a.inspect
