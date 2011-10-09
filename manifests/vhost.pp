define phpmyadmin::vhost(
  $ensure = 'present',
  $domainalias = 'absent',
  $ssl_mode = 'force',
  $monitor_url = 'absent',
  $auth_method = 'http',
  $logmode = 'default'
){
  include ::phpmyadmin::vhost::absent_webconfig
  $documentroot = $operatingsystem ? {
    gentoo => '/var/www/localhost/htdocs/phpmyadmin',
    default => '/usr/share/phpMyAdmin'
  }
  apache::vhost::php::standard{$name:
    ensure => $ensure,
    domainalias => $domainalias,
    manage_docroot => false,
    path => $documentroot,
    logpath => $operatingsystem ? {
      gentoo => '/var/log/apache2/',
      default => '/var/log/httpd'
    },
    php_settings => {
      'session.save_path' =>  "/var/www/session.save_path/${name}/",
      'upload_tmp_dir'    =>  "/var/www/upload_tmp_dir/${name}/",
      'open_basedir'      =>  "${documentroot}/:/etc/phpMyAdmin/:/var/www/upload_tmp_dir/${name}/:/var/www/session.save_path/${name}/",
    },
    logmode => $logmode,
    manage_webdir => false,
    path_is_webdir => true,
    ssl_mode => $ssl_mode,
    template_partial => 'phpmyadmin/vhost/php_stuff.erb',
    require => Package['phpMyAdmin'],
    mod_security => false,
  }

  if $use_nagios {
    $real_monitor_url = $monitor_url ? {
      'absent' => $name,
      default => $monitor_url,
    }
    nagios::service::http{"${real_monitor_url}":
      ensure => $ensure,
      check_code => $auth_method ? {
        'http' => '401',
        default => 'OK'
      },
      ssl_mode => $ssl_mode,
    }
  }
}
