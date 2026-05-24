# typed: false
# frozen_string_literal: true

class Sortie < Formula
  desc "Mac companion CLI for Sortie"
  homepage "https://github.com/thebasedcapital/homebrew-sortie"
  url "https://github.com/thebasedcapital/homebrew-sortie/releases/download/v0.14.0-0-r18/sortie-cli-0.14.0-0-r18.tgz"
  version "0.14.0-0"
  sha256 "734d2643c473ed0ae790238dab4b11c9c6c10e403dffabf1cd011aed15585e94"
  license "MIT"
  revision 18

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
