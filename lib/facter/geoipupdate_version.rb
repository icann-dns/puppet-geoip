if File.exist?('/usr/bin/geoipupdate')
  version = Facter::Util::Resolution.exec('/usr/bin/geoipupdate -V').match(
    %r{geoipupdate\s(\d\.\d\.\d)},
  )[1]
  Facter.add(:geoipupdate_version) do
    setcode do
      version
    end
  end
end
