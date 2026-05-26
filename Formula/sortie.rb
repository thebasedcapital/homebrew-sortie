# typed: false
# frozen_string_literal: true

class Sortie < Formula
  desc "Mac companion CLI for Sortie"
  homepage "https://github.com/thebasedcapital/homebrew-sortie"
  url "https://github.com/thebasedcapital/homebrew-sortie/releases/download/v0.14.0-0-r27/sortie-cli-0.14.0-0-r27.tgz"
  version "0.14.0-0"
  sha256 "1c226c43c3735ccd03d63d09af06a3a91eebc390be4cdbae434c2c03b8e9f592"
  license "MIT"
  revision 27

  depends_on "node@22"

  def install
    source = buildpath/"package"
    source = buildpath unless (source/"bin/sortie.mjs").exist?

    libexec.install source/"dist"
    libexec.install source/"bin"
    libexec.install source/"scripts"
    libexec.install source/"tools" if File.directory?(source/"tools")
    libexec.install source/"package.json"

    node_path = Formula["node@22"].opt_bin
    npm = node_path/"npm"

    cd libexec do
      system npm, "install", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund"
    end
    rm_r libexec/"tools/archives"

    (bin/"sortie").write <<~EOS
      #!/bin/bash
      export PATH="#{node_path}:$PATH"
      export HAPPY_SERVER_URL="${HAPPY_SERVER_URL:-https://sortie-server.fly.dev}"
      exec "#{libexec}/bin/sortie.mjs" "$@"
    EOS
    (bin/"sortie-mcp").write <<~EOS
      #!/bin/bash
      export PATH="#{node_path}:$PATH"
      export HAPPY_SERVER_URL="${HAPPY_SERVER_URL:-https://sortie-server.fly.dev}"
      exec "#{libexec}/bin/sortie-mcp.mjs" "$@"
    EOS

    # Compatibility aliases for existing installs and scripts during the rename.
    (bin/"happy").write <<~EOS
      #!/bin/bash
      export PATH="#{node_path}:$PATH"
      export HAPPY_SERVER_URL="${HAPPY_SERVER_URL:-https://sortie-server.fly.dev}"
      exec "#{libexec}/bin/happy.mjs" "$@"
    EOS
    (bin/"happy-mcp").write <<~EOS
      #!/bin/bash
      export PATH="#{node_path}:$PATH"
      export HAPPY_SERVER_URL="${HAPPY_SERVER_URL:-https://sortie-server.fly.dev}"
      exec "#{libexec}/bin/happy-mcp.mjs" "$@"
    EOS
  end

  test do
    assert_match "sortie", shell_output("#{bin}/sortie --help")
  end
end
