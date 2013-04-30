define logstash::config::shipper::filter (
  $type,
  $params,
  $file = undef,
  $order = '00') {
  $config_order = "1${order}"

  include concat::setup

  if !$file {
    $filename = "${name}.filter"
  } else {
    $filename = $file
  }

  if $type == 'grok' {
    $params['patterns_dir'] = "[\"${::logstash::config::grok_patterns_dir}\"]"
  }

  $target  = "${::logstash::config::logstash_etc}/${filename}"
  $service = 'logstash-shipper'

  if !defined(Concat[$target]) {
    ::concat { $target:
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        notify => Service[$service],
    }

    ::concat::fragment {
      'logstash-shipper_filter_header':
        target  => $target,
        order   => '000',
        content => "filter {\n";

      'logstash-shipper_filter_footer':
        target  => $target,
        order   => '200',
        content => "}\n";
    }
  }

  ::concat::fragment { "logstash_shipper_filter_${type}_${name}":
    target  => $target,
    order   => $config_order,
    content => template('logstash/config/fragment.erb'),
    notify  => Service[$service],
  }
}
