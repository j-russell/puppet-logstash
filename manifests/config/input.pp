define logstash::config::input (
  $daemon,
  $type,
  $params,
  $order = '00') {
  $config_order = "10${order}"

  case $daemon {
    'indexer' : {
      $target  = "${::logstash::config::logstash_etc}/indexer.conf"
      $service = 'logstash-indexer'
    }
    'shipper' : {
      $target  = "${::logstash::config::logstash_etc}/shipper.conf"
      $service = 'logstash-shipper'
    }
    default   : {
      fail("Unknown daemon: ${daemon} - should be one of (indexer|shipper)")
    }
  }

  ::concat::fragment { "logstash_${daemon}_input_${type}_${name}":
    target  => $target,
    order   => $config_order,
    content => template('logstash/config/fragment.erb'),
    notify  => Service[$service],
  }
}
