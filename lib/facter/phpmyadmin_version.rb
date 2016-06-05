# determine the version of apache installed
Facter.add('phpmyadmin_version') do
  confine :osfamily => ['RedHat']
  setcode do
    Facter::Util::Resolution.exec('rpm -q --queryformat \'%{VERSION}\' phpMyAdmin')
  end
end
