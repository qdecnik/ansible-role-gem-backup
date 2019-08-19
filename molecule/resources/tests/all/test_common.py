
debian_os = ['debian', 'ubuntu']
rhel_os = ['redhat', 'centos']


def test_distribution(host):
    assert host.system_info.distribution.lower() in debian_os + rhel_os


def test_conf_dir(host):
    f = host.file('/etc/backup')

    assert f.exists
    assert f.is_directory


def test_data_dir(host):
    f = host.file('/home/backup')

    assert f.exists
    assert f.is_directory


def test_tmp_dir(host):
    f = host.file('/home/backup/tmp')

    assert f.exists
    assert f.is_directory
