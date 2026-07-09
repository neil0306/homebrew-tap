class Bltusb < Formula
  desc "Read/write BitLocker-encrypted USB drives on macOS (Apple Silicon)"
  homepage "https://github.com/neil0306/bltusb"
  url "https://github.com/neil0306/bltusb/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "5dfbf3ad5088a4ad3523c0a30e460bb8fb07fc7d0edebb394414434620df0d86"
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
