define logstash::lumberjack (
  $file,
  $host          = undef,
  $port          = undef,
  $ssl_ca_path   = '/etc/lumberjack/lumberjack.crt',
  $ssl_ca_source = undef,
  $window_size   = undef,
  $fields        = undef
) {
  if !defined(Class['::logstash::lumberjack::package']) {
    class { '::logstash::lumberjack::package': }
  }

  if !defined(Class['::logstash::lumberjack::config']) {
    class { '::logstash::lumberjack::config':
      ssl_ca_path   => $ssl_ca_path,
      ssl_ca_source => $ssl_ca_source,
    }
  }

  Class['::logstash::lumberjack::package'] -> Class['::logstash::lumberjack::config']

  if $host {
    $lumberjack_host = "--host ${host} "
  } else {
    $lumberjack_host = ''
  }

  if $port {
    $lumberjack_port = "--port ${port} "
  } else {
    $lumberjack_port = ''
  }

  if $ssl_ca_path {
    $lumberjack_ssl_ca_path = "--ssl-ca-path ${ssl_ca_path} "
  } else {
    $lumberjack_ssl_ca_path = ''
  }

  if $window_size {
    $lumberjack_window_size = "--window-size ${window_size} "
  } else {
    $lumberjack_window_size = ''
  }

  if $fields {
    $lumberjack_fields = inline_template('<% @fields.sort.map do |name,value|-%>--field <%=name%>=<%=value%> <% end -%>')
  } else {
    $lumberjack_fields = ''
  }

  concat::fragment { "lumberjack_${name}":
    target  => '/etc/lumberjack/lumberjack.conf',
    content => "${lumberjack_host}${lumberjack_port}${lumberjack_ssl_ca_path}${lumberjack_window_size}${lumberjack_fields}${file}\n",
  }
}
