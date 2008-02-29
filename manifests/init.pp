# modules/phpmyadmin/manifests/init.pp - manage phpmyadmin stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "phpmyadmin": }

class phpmyadmin {

    case $operatingsystem {
        gentoo: { include webapp-config }
    }
    
    package { 'phpmyadmin':
        ensure => present,
        category => $operatingsystem ? {
            gentoo => 'dev-db',
            default => '',
        }
    }

    # config files
    file{
        "/var/www/localhost/htdocs/phpmyadmin/config.inc.php":
            source => [
                "puppet://$server/dist/phpmyadmin/${fqdn}/config.inc.php",
                "puppet://$server/phpmyadmin/${fqdn}/config.inc.php",
                "puppet://$server/phpmyadmin/config.inc.php"
            ],
            owner => root,
            group => 0,
            mode => 0444,
            require => Package[phpmyadmin],
    }
}
