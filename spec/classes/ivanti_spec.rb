# frozen_string_literal: true

require 'spec_helper'

describe 'ivanti' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'Checking for package installation' do
        # Check for packages needed to be installed.
        packages = ['ivanti-software-distribution', 'ivanti-base-agent', 'ivanti-pds2', 'ivanti-schedule', 'ivanti-inventory', 'ivanti-vulnerability', 'ivanti-cba8']
        packages.each do |package|
          it { is_expected.to contain_package(package.to_s).with_ensure('installed') }
        end
      end

      context 'Check sudo file entry for landesk user' do
        it { is_expected.to contain_file('/etc/sudoers.d/10_landesk').with_content(%r{^landesk\s+ALL=\(ALL\)\s+NOPASSWD:\s+ALL$}) }

        # Ensure certificate file copied to /opt/landesk/var/cbaroot/certs/187227ec.0
        #
        # Base linux clients:
        # http://epmcore-02p.nfii.com/ldlogon/unix/linux/baseclient64.tar.gz
        #
        # Vulnerability scan RPMs/DEBs.
        # http://epmcore-02p.nfii.com/ldlogon/unix/linux/vulscan64.tar.gz
        #
        # ivanti/foobar.log:Thu Feb 23 10:24:00 EST 2023: Core certificates: 187227ec.0
        # ivanti/foobar.log:Thu Feb 23 10:24:10 EST 2023: Fetch requested file: http://epmcore-02p.nfii.com/ldlogon/187227ec.0
        #
        # Ensure landesk is in sudoers
        # landesk ALL=(ALL)  NOPASSWD: ALL
        # Defaults:landesk !requiretty
        #
        # Ensure ivanti can modify cron job (it tries to install cron job when running the nixsetup.sh script)
        # device id = dmidecode.product.uuid
        # run /opt/landesk/bin/ldiscan to 'register' the server.
        #
        #
      end
    end
  end
end
