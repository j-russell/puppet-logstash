define logstash::config::shipper::output (
  $type,
  $params,
  $file = undef,
  $order = '00') {
  $config_order = "1${order}"

  include concat::setup

  if !$file {
    $filename = "${name}.output"
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

  if !defined(Concat::Fragment["logstash-shipper_${filename}_output_header"]) {
    ::concat::fragment { "logstash-shipper_${filename}_output_header":
      target  => $target,
      order   => '000',
      content => "output {\n",
    }
  }

  if !defined(Concat::Fragment["logstash-shipper_${filename}_output_footer"]) {
    ::concat::fragment { "logstash-shipper_${filename}_output_footer":
      target  => $target,
      order   => '200',
      content => "}\n",
    }
  }

  ::concat::fragment { "logstash_shipper_output_${type}_${name}":
    target  => $target,
    order   => $config_order,
    content => template('logstash/config/fragment.erb'),
    notify  => Service[$service],
  }
}
