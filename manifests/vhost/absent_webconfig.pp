# make sure the default httpd file is away
class phpmyadmin::vhost::absent_webconfig {
  include ::phpmyadmin
  file{'/etc/httpd/conf.d/phpMyAdmin.conf':
    ensure  => absent,
    require => Package['phpMyAdmin'],
    notify  => Service['apache'],
  }
}
