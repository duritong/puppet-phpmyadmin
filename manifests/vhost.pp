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
  $manage_nagios  = false,
  $configuration  = {},
){
  $documentroot = '/usr/share/phpMyAdmin'

  class{'::phpmyadmin':
    upload_dir => "/var/www/upload_tmp_dir/${name}/upload",
    save_dir   => "/var/www/upload_tmp_dir/${name}/save",
  }
  include ::phpmyadmin::vhost::absent_webconfig


  if ($run_mode == 'fcgid'){
    if (($run_uid == 'absent') or ($run_gid == 'absent')) {
      fail("Need to configure \$run_uid and \$run_gid if you want to run Phpmyadmin::Vhost[${name}] as fcgid.")
    }

    user::managed{$name:
      ensure     => $ensure,
      uid        => $run_uid,
      gid        => $run_gid,
      managehome => false,
      homedir    => $documentroot,
      shell      => '/sbin/nologin',
      before     => Apache::Vhost::Php::Standard[$name],
    }
  }

  file{
    '/etc/phpMyAdmin':
      ensure  => directory,
      owner   => root,
      group   => $name,
      mode    => '0640',
      require => Package['phpMyAdmin'];
    '/etc/phpMyAdmin/config.inc.php':
      owner   => root,
      group   => $name,
      mode    => '0640';
  }

  if versioncmp($::operatingsystemmajrelease,'6') > 0 {
    $open_basedir = "${documentroot}/:/usr/share/doc/phpMyAdmin-${phpmyadmin::guessed_version}/html/:/usr/share/php:/etc/phpMyAdmin/:/var/www/upload_tmp_dir/${name}/:/var/www/session.save_path/${name}/"
  } else {
    $open_basedir = "${documentroot}/:/usr/share/php:/etc/phpMyAdmin/:/var/www/upload_tmp_dir/${name}/:/var/www/session.save_path/${name}/"
  }
  apache::vhost::php::standard{$name:
    ensure           => $ensure,
    domainalias      => $domainalias,
    manage_docroot   => false,
    path             => $documentroot,
    logpath          => '/var/log/httpd',
    logprefix        => "${name}-",
    php_settings     => {
      'session.save_path' => "/var/www/session.save_path/${name}/",
      'upload_tmp_dir'    => "/var/www/upload_tmp_dir/${name}/",
      'open_basedir'      => $open_basedir,
    },
    logmode            => $logmode,
    run_mode           => $run_mode,
    run_uid            => $name,
    run_gid            => $name,
    manage_webdir      => false,
    path_is_webdir     => true,
    ssl_mode           => $ssl_mode,
    configuration      => $configuration,
    mod_security       => false,
    require            => Package['phpMyAdmin'],
    additional_options => '<Directory /usr/share/phpMyAdmin/>
    AddDefaultCharset UTF-8
    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require all granted
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Allow from All
    </IfModule>
  </Directory>
  <Directory /usr/share/phpMyAdmin/setup/>
    <IfModule mod_authz_core.c>
      # Apache 2.4
      <RequireAny>
        Require ip 127.0.0.1
        Require ip ::1
      </RequireAny>
    </IfModule>
    <IfModule !mod_authz_core.c>
      # Apache 2.2
      Order Deny,Allow
      Deny from All
      Allow from 127.0.0.1
      Allow from ::1
    </IfModule>
  </Directory>

  # These directories do not require access over HTTP - taken from the original
  # phpMyAdmin upstream tarball
  #
  <Directory /usr/share/phpMyAdmin/libraries/>
    Order Deny,Allow
    Deny from All
    Allow from None
  </Directory>

  <Directory /usr/share/phpMyAdmin/setup/lib/>
    Order Deny,Allow
    Deny from All
    Allow from None
  </Directory>

  <Directory /usr/share/phpMyAdmin/setup/frames/>
    Order Deny,Allow
    Deny from All
    Allow from None
  </Directory>
',
  }

  if $manage_nagios {
    $real_monitor_url = $monitor_url ? {
      'absent'  => $name,
      default   => $monitor_url,
    }
    nagios::service::http{$real_monitor_url:
      ensure     => $ensure,
      check_code => 'OK',
      ssl_mode   => $ssl_mode,
    }
  }

  if $ensure == 'present' {
    file{[$phpmyadmin::upload_dir,$phpmyadmin::save_dir]:
      ensure => directory,
      owner  => $name,
      group  => $name,
      mode   => '0770',
      before => Service['apache'],
    }
  }
}
