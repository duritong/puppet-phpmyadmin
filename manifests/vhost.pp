# install a phpmyadmin vhost
define phpmyadmin::vhost(
  $ensure         = 'present',
  $domainalias    = 'absent',
  $ssl_mode       = 'force',
  $run_mode       = 'normal',
  $run_uid        = 'absent',
  $run_gid        = 'absent',
  $monitor_url    = 'absent',
  $auth_method    = 'cookie',
  $logmode        = 'default',
  $manage_nagios  = false
){
  $documentroot = $::operatingsystem ? {
    gentoo  => '/var/www/localhost/htdocs/phpmyadmin',
    default => '/usr/share/phpMyAdmin'
  }

  if ($run_mode == 'fcgid'){
    if (($run_uid == 'absent') or ($run_gid == 'absent')) { fail("Need to configure \$run_uid and \$run_gid if you want to run Phpmyadmin::Vhost[${name}] as fcgid.") }

    $shell = $::operatingsystem ? {
      debian  => '/usr/sbin/nologin',
      ubuntu  => '/usr/sbin/nologin',
      default => '/sbin/nologin'
    }
    user::managed{$name:
      ensure      => $ensure,
      uid         => $run_uid,
      gid         => $run_gid,
      managehome  => false,
      homedir     => $documentroot,
      shell       => $shell,
      before      => Apache::Vhost::Php::Standard[$name],
    }
  }

  include ::phpmyadmin::vhost::absent_webconfig

  $logpath = $::operatingsystem ? {
    gentoo  => '/var/log/apache2/',
    default => '/var/log/httpd'
  }
  apache::vhost::php::standard{$name:
    ensure            => $ensure,
    domainalias       => $domainalias,
    manage_docroot    => false,
    path              => $documentroot,
    logpath           => $logpath,
    php_settings      => {
      'session.save_path' =>  "/var/www/session.save_path/${name}/",
      'upload_tmp_dir'    =>  "/var/www/upload_tmp_dir/${name}/",
      'open_basedir'      =>  "${documentroot}/:/usr/share/php:/etc/phpMyAdmin/:/var/www/upload_tmp_dir/${name}/:/var/www/session.save_path/${name}/",
    },
    logmode           => $logmode,
    run_mode          => $run_mode,
    run_uid           => $name,
    run_gid           => $name,
    manage_webdir     => false,
    path_is_webdir    => true,
    ssl_mode          => $ssl_mode,
    template_partial  => 'apache/vhosts/php/partial.erb',
    require           => Package['phpMyAdmin'],
    mod_security      => false,
  }

  if $run_mode == 'fcgid' {
    Apache::Vhost::Php::Standard[$name]{
      additional_options => "RewriteEngine On
RewriteRule .* - [E=REMOTE_USER:%{HTTP:Authorization},L]",
    }
  }

  if $manage_nagios {
    $real_monitor_url = $monitor_url ? {
      'absent'  => $name,
      default   => $monitor_url,
    }
    # old version that might do http-auth
    if ($auth_method == 'http') and ($::operatingsystem == 'CentOS') and ($::operatingsystemrelease < 6) {
      $check_code = '401'
    } else {
      $check_code = 'OK'
    }
    nagios::service::http{$real_monitor_url:
      ensure      => $ensure,
      check_code  => $check_code,
      ssl_mode    => $ssl_mode,
    }
  }
}
