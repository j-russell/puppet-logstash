define logstash::config::shipper::input (
  $type,
  $params,
  $file = undef,
  $order = '00') {
  $config_order = "1${order}"

  include concat::setup

  if !$file {
    $filename = "${name}.input"
  } else {
    $filename = $file
  }

  $target  = "${::logstash::config::logstash_etc}/shipper/${filename}"
  $service = 'logstash-shipper'

  if !defined(Concat[$target]) {
    ::concat { $target:
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        notify => Service[$service],
    }
  }

  if !defined(Concat::Fragment['logstash-shipper_${filename}_input_header']) {
    ::concat::fragment { 'logstash-shipper_${filename}_input_header':
      target  => $target,
      order   => '000',
      content => "input {\n",
    }
  }

  if !defined(Concat::Fragment['logstash-shipper_${filename}_input_footer']) {
    ::concat::fragment { 'logstash-shipper_${filename}_input_footer':
      target  => $target,
      order   => '200',
      content => "}\n",
    }
  }

  ::concat::fragment { "logstash_shipper_input_${type}_${name}":
    target  => $target,
    order   => $config_order,
    content => template('logstash/config/fragment.erb'),
    notify  => Service[$service],
  }
}
