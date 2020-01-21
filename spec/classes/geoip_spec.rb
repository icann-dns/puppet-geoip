require 'spec_helper'

describe 'geoip' do
  let(:node) { 'foobar.example.com' }
  let(:params) { {} }

  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('libmaxminddb0') }
        it { is_expected.to contain_package('geoipupdate') }
        it do
          is_expected.to contain_file(
            '/etc/GeoIP.conf',
          ).with_ensure('file').with_content(
            %r{AccountID 0},
          ).with_content(
            %r{LicenseKey 000000000000},
          ).with_content(
            %r{EditionIDs GeoLite2-City GeoLite2-Country},
          ).without_content(
            %r{DatabaseDirectory},
          ).without_content(
            %r{Host},
          ).without_content(
            %r{Proxy},
          ).without_content(
            %r{ProxyUserPassword},
          ).without_content(
            %r{PreserveFileTimes},
          ).without_content(
            %r{LockFile},
          )
        end
        it do
          is_expected.to contain_exec('/usr/bin/geoipupdate').with_refreshonly(true)
        end
        it do
          is_expected.to contain_cron('geoipupdate weekly').with(
            command: '/usr/bin/geoipupdate',
            minute: '0',
            hour: '1',
            weekday: '7',
          )
        end
      end
      describe 'Change Defaults' do
        context 'packages' do
          before(:each) { params.merge!(packages: ['foobar']) }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'config_file' do
          before(:each) { params.merge!(config_file: '/etc/GeoIP.conf') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/etc/GeoIP.conf') }
        end
        context 'account_id' do
          before(:each) { params.merge!(account_id: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{AccountID 42},
            )
          end
        end
        context 'licence_key' do
          before(:each) { params.merge!(licence_key: '42') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{LicenseKey 42},
            )
          end
        end
        context 'edition_ids' do
          before(:each) { params.merge!(edition_ids: ['GeoLite2-ASN']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{EditionIDs GeoLite2-ASN},
            )
          end
        end
        context 'database_dir Just DATADIR' do
          before(:each) { params.merge!(database_dir: 'DATADIR') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{DatabaseDirectory DATADIR},
            )
          end
        end
        context 'database_dir with DATADIR' do
          before(:each) { params.merge!(database_dir: 'DATADIR/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{DatabaseDirectory DATADIR/foo/bar},
            )
          end
        end
        context 'database_dir' do
          before(:each) { params.merge!(database_dir: '/foo/bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{DatabaseDirectory /foo/bar},
            )
          end
        end
        context 'host' do
          before(:each) { params.merge!(host: 'foo.bar') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{Host foo.bar},
            )
          end
        end
        context 'proxy_ip' do
          before(:each) { params.merge!(proxy_ip: '192.0.2.42') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{Proxy 192.0.2.42},
            )
          end
        end
        context 'proxy_port' do
          before(:each) { params.merge!(proxy_ip: '192.0.2.42', proxy_port: 42) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{Proxy 192.0.2.42:42},
            )
          end
        end
        context 'proxy_username' do
          before(:each) do
            params.merge!(proxy_username: 'foobar', proxy_password: 'foobar')
          end
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{ProxyUserPassword foobar:foobar},
            )
          end
        end
        context 'preserve_file_times' do
          before(:each) { params.merge!(preserve_file_times: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{PreserveFileTimes 1},
            )
          end
        end
        context 'preserve_file_times false' do
          before(:each) { params.merge!(preserve_file_times: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{PreserveFileTimes 0},
            )
          end
        end
        context 'lock_file' do
          before(:each) { params.merge!(lock_file: '/foo/bar.lock') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{LockFile /foo/bar.lock},
            )
          end
        end
        context 'lock_file with DATADIR' do
          before(:each) { params.merge!(lock_file: 'DATADIR/foo/bar.lock') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file(
              '/etc/GeoIP.conf',
            ).with_ensure('file').with_content(
              %r{LockFile DATADIR/foo/bar.lock},
            )
          end
        end
      end
      describe 'check bad type' do
        context 'packages' do
          before(:each) { params.merge!(packages: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'config_file' do
          before(:each) { params.merge!(config_file: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'account_id' do
          before(:each) { params.merge!(account_id: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'licence_key' do
          before(:each) { params.merge!(licence_key: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'edition_ids' do
          before(:each) { params.merge!(edition_ids: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'edition_ids string' do
          before(:each) { params.merge!(edition_ids: 'GeoFOOBAR') }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'database_dir' do
          before(:each) { params.merge!(database_dir: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'host' do
          before(:each) { params.merge!(host: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_ip' do
          before(:each) { params.merge!(proxy_ip: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_port' do
          before(:each) { params.merge!(proxy_port: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_username' do
          before(:each) { params.merge!(proxy_username: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_username no password' do
          before(:each) { params.merge!(proxy_username: 'foobar') }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_password' do
          before(:each) { params.merge!(proxy_password: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'proxy_password  no user' do
          before(:each) { params.merge!(proxy_password: 'foobar') }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'preserve_file_times' do
          before(:each) { params.merge!(preserve_file_times: 'foobar') }
          it { is_expected.to raise_error(Puppet::Error) }
        end
        context 'lock_file' do
          before(:each) { params.merge!(lock_file: true) }
          it { is_expected.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
