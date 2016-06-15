require 'webrick'
require 'webrick/httpproxy'
require 'stringio'
require 'logger'

def match_credentials(req, res)
  type, credentials = req.header['proxy-authorization'].first.to_s.split(/\s+/, 2)
  received_username, received_password = credentials.to_s.unpack("m*")[0].split(":", 2)
  unless  received_username == 'validUser' && received_password == 'validPass'
    res['proxy-authenticate'] = %{Basic realm="testing"}
    raise WEBrick::HTTPStatus::ProxyAuthenticationRequired
  end
end

Before('@needs-proxy') do
  @log = StringIO.new
  logger = Logger.new(@log)
  @proxy = WEBrick::HTTPProxyServer.new(:ServerType => Thread,
                                        :Logger => logger,
                                        :AccessLog => [[@log, "[ %m  %U  ->  %s %b"]],
                                        :Port => 8888,
                                        :ProxyAuthProc => method(:match_credentials)
  )
  @proxy.start
end

After('@needs-proxy') do
  @proxy.stop
  @proxy.shutdown
  #puts @log
end

