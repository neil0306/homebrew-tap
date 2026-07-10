class Bltusb < Formula
  desc "Read/write BitLocker-encrypted USB drives on macOS (Apple Silicon)"
  homepage "https://github.com/neil0306/bltusb"
  url "https://github.com/neil0306/bltusb/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "0639c70177ea8ebd891592334a12c014a85e40f44c00ec752620f82e9b12eb80"
  license "MIT"

  depends_on :macos

  def install
    bin.install "bltusb"
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
