set :bind, '0.0.0.0'
set :port, {{ port }}
config[:ws_config] = '/etc/riemann/layout.json'
