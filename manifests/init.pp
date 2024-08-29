# @summary puppet class to manage geoip
#
# @param packages packages to install
# @param config_file location of config file
# @param account_id account ID see https://www.maxmind.com/en/my_license_key
# @param licence_key Licence key see https://www.maxmind.com/en/my_license_key
# @param edition_ids edition IDs of the databases you would like to update.
# @param database_dir database dir, defaults to DATADIR
# @param host The server to use. Defaults to "updates.maxmind.com".
# @param proxy_ip The proxy host name or IP address
# @param proxy_port The proxy host name or port defaults to 1080
# @param proxy_username The user name to use with your proxy server.
# @param proxy_password The password to use with your proxy server.
# @param preserve_file_times
#   Whether to preserve modification times of files downloaded from the server.
#   defaults to false
# @param lock_file
#   The lock file to use. 
#   Defaults to ".geoipupdate.lock" under the DatabaseDirectory.
# @param autoupdate update geoip DB when config file changes
class geoip (
  Array[String[1]]              $packages,
  Stdlib::Unixpath              $config_file,
  Integer[0]                    $account_id,
  Pattern[/\d+/]                $licence_key,
  Array[Geoip::Edition_id]      $edition_ids,
  Optional[Geoip::Path]         $database_dir,
  Optional[Stdlib::Host]        $host,
  Optional[Stdlib::IP::Address] $proxy_ip,
  Optional[Stdlib::Port]        $proxy_port,
  Optional[String[1]]           $proxy_username,
  Optional[String[1]]           $proxy_password,
  Optional[Boolean]             $preserve_file_times,
  Optional[Geoip::Path]         $lock_file,
  Boolean                       $autoupdate = true,
) {
  if ($proxy_username and ! $proxy_password) or
      ( $proxy_password and ! $proxy_username) {
    fail('you must specify both proxy_username and proxy_password')
  }
  ensure_packages($packages)
  file { $config_file:
    ensure  => file,
    content => template('geoip/etc/GeoIP.conf.erb'),
    require => Package[$packages],
  }
  exec {'/usr/bin/geoipupdate':
    refreshonly => true,
    subscribe   => File[$config_file],
  }
  cron {'geoipupdate weekly':
    command => '/usr/bin/geoipupdate',
    minute  => '0',
    hour    => '1',
    weekday => '7',
  }
}
