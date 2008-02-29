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
#    file{
#        "/var/www/localhost/htdocs/phpmyadmin/":
#            source => [
#                "puppet://$server/dist/php/apache2_php5_php.ini/${fqdn}/php.ini",
#                "puppet://$server/php/apache2_php5_php.ini/${fqdn}/php.ini",
#                "puppet://$server/php/apache2_php5_php.ini/php.ini"
#            ],
#            owner => root,
#            group => 0,
#            mode => 0644,
#            require => Package[phpmyadmin],
#    }
}
