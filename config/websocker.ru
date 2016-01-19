require_relative './shared.rb'

EM.run {
  # websocket server
  Ginatra::WebsocketServer.start
}
