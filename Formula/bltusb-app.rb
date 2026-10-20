# bltusb-app.rb — Homebrew formula for the PREBUILT bltusb Mode B ("install-and-use").
#
# This is a REFERENCE formula. `release-bundle.sh` copies it into the tap
# (neil0306/homebrew-tap Formula/bltusb-app.rb) with `url`, `version`, and
# `sha256` filled in for each release.
#
# Homebrew installs UNPRIVILEGED (into the Cellar), but Mode B needs a root
# LaunchDaemon — which brew cannot bootstrap. The Cellar copy is user-writable AFTER
# brew's download-time verification, so staging the privileged install FROM the
# Cellar would be UNAUTHENTICATED (a same-UID swap before `sudo` would go unchecked).
# So brew is only a discovery/convenience entry: the `caveats` tell the user to run
# the SECURE NETWORK INSTALLER (install.sh), which verifies the release's SIGNED
# SHA256SUMS against the release key built into install.sh, then re-verifies
# root-owned copies in its root stage before installing (audit HIGH, round 3 /
# FIX F). The Cellar copy is kept for OFFLINE reference only.
# The bundle is a curl download, so it is not Gatekeeper-quarantined and the
# ad-hoc-signed + hypervisor-entitled binaries run without notarization — same model
# as `brew install qemu`.
class BltusbApp < Formula
  desc "Zero-sudo BitLocker/NTFS/exFAT/ext USB mounting for macOS (discovery entry; installs via secure network installer)"
  homepage "https://github.com/neil0306/bltusb"
  version "1.5.2"
  url "https://github.com/neil0306/bltusb/releases/download/v1.5.2/bltusb-bundle-1.5.2-arm64.tar.gz"
  sha256 "b71acd4d18dcb2fbda573da5a3e3d6731336a7d49e431401c549073a1beecab6"
  license "MIT"
  depends_on arch: :arm64
  depends_on macos: :ventura           # Mode B XPC peer-requirement APIs

  def install
    # Stage the whole self-contained bundle; the sudo setup step installs the
    # root daemon from here. Nothing privileged happens at `brew install` time.
    libexec.install Dir["*"]
  end

  def caveats
    <<~EOS
      bltusb Mode B is staged for reference but NOT yet active. Finish setup by
      running the SECURE NETWORK INSTALLER. It verifies the release's signed
      SHA256SUMS with the release key built into install.sh (compare the key
      fingerprint it prints with one you got outside GitHub, e.g. from the maintainer) and re-checks
      root-owned copies before installing:

          /usr/bin/curl -fsSL https://raw.githubusercontent.com/neil0306/bltusb/main/helper/scripts/install.sh | /bin/bash

      Pinned form (recommended): download install.sh from the release tag and run
          /bin/bash install.sh --version #{version}

      WHY NOT stage from the Cellar (audit HIGH, round 3 / FIX F): the Homebrew
      Cellar is user-writable AFTER brew's download-time verification, so a same-UID
      swap before a `sudo` staging step would be UNAUTHENTICATED. install.sh downloads
      and verifies the signed release itself, then re-verifies root-owned copies in
      a root-only 0700 dir before staging. Brew here is only a discovery/convenience
      entry; the privileged install goes through install.sh.

      Then grant the daemon Full Disk Access (raw-disk reads are TCC-gated):
          System Settings ▸ Privacy & Security ▸ Full Disk Access ▸ [+] ▸ add:
              /Library/Application Support/bltusb/bin/bltusb-helperd
          then:  sudo launchctl kickstart -k system/co.carryai.bltusb.helperd

      Use it (no sudo):   bltusb list
      Uninstall:          bltusb-uninstall   (or: bash "/Library/Application Support/bltusb/scripts/uninstall.sh")

      Optional Finder setting (the installer offers it; shown here for brew users).
      macOS treats drives opened with bltusb as network (NFS) volumes. This stops
      Finder writing .DS_Store files (window/icon layout, some file names) onto
      them, and onto SMB/AFP shares, for your user account only:

          defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true && killall Finder

      Effect: Finder forgets per-folder view settings on network volumes and
      restarts once. ._* files can still appear on read-write mounts (use
      read-only mounts or dot_clean). Undo:

          defaults delete com.apple.desktopservices DSDontWriteNetworkStores && killall Finder
    EOS
  end

  test do
    assert_predicate libexec/"scripts/install-prebuilt.sh", :exist?
    assert_predicate libexec/"bin/bltusb-client", :executable?
  end
end
