# typed: false
# frozen_string_literal: true

class Sortie < Formula
  desc "Mac companion CLI for Sortie"
  homepage "https://github.com/thebasedcapital/homebrew-sortie"
  url "https://github.com/thebasedcapital/homebrew-sortie/releases/download/v0.14.0-0/sortie-cli-0.14.0-0.tgz"
  sha256 "4e127dcc04c801d1b1127c2aa59a12bc6637027b508560448028300efa3026c8"
  license "MIT"

  depends_on "node"

  def install
    source = buildpath/"package"
    source = buildpath unless (source/"bin/sortie.mjs").exist?

    libexec.install source/"dist"
    libexec.install source/"bin"
    libexec.install source/"scripts"
    libexec.install source/"tools" if File.directory?(source/"tools")
    libexec.install source/"package.json"

    bin.install_symlink libexec/"bin/sortie.mjs" => "sortie"
    bin.install_symlink libexec/"bin/sortie-mcp.mjs" => "sortie-mcp"

    # Compatibility aliases for existing installs and scripts during the rename.
    bin.install_symlink libexec/"bin/happy.mjs" => "happy"
    bin.install_symlink libexec/"bin/happy-mcp.mjs" => "happy-mcp"
  end

  test do
    assert_match "sortie", shell_output("#{bin}/sortie --help")
  end
end
