class phpmyadmin::gentoo inherits phpmyadmin::base {
    include webapp-config

    Package[phpmyadmin]{
        category => 'dev-db',
        require => Package[webapp-config],
    }
}

