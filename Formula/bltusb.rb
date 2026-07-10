class Bltusb < Formula
  desc "Read/write BitLocker-encrypted USB drives on macOS (Apple Silicon)"
  homepage "https://github.com/neil0306/bltusb"
  url "https://github.com/neil0306/bltusb/archive/refs/tags/v1.3.5.tar.gz"
  sha256 "1a257eb5087f6c77c863e6a467c11e8cf231aa91e4d1d7301e76e75fb88fdbf5"
  license "MIT"

  depends_on :macos

  def install
    bin.install "bltusb"
  end

  # Auto-unlock daemon, delegated to `brew services` when bltusb is Homebrew-
  # installed. A per-user agent (never a root LaunchDaemon): start it WITHOUT
  # sudo via `brew services start bltusb` (or `bltusb autounlock install`).
  service do
    run [opt_bin/"bltusb", "__autounlock-daemon"]
    run_type :immediate
    keep_alive true
    process_type :interactive
    log_path "/dev/null"
    error_log_path "/dev/null"
  end

  def caveats
    <<~EOS
      bltusb needs the anylinuxfs backend (no macFUSE / no kernel extension).
      Install it once with:
        bltusb install
      Then just run `bltusb` to detect and mount your BitLocker drive.
    EOS
  end

  test do
    assert_match "bltusb #{version}", shell_output("#{bin}/bltusb version")
  end
end
