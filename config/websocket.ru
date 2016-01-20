require_relative './shared.rb'

Ginatra::Env.websocket_port = 9290

EM.run {
  # websocket server
  Ginatra::WebsocketServer.start
}
