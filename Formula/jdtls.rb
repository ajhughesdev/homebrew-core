class Jdtls < Formula
  include Language::Python::Shebang

  desc "Java language specific implementation of the Language Server Protocol"
  homepage "https://github.com/eclipse/eclipse.jdt.ls"
  url "https://download.eclipse.org/jdtls/milestones/1.24.0/jdt-language-server-1.24.0-202306011728.tar.gz"
  version "1.24.0"
  sha256 "ed73a4f6870a1df618894506a7c8da734c43e1c6325d2cf75cb934c0f9c2f968"
  license "EPL-2.0"
  version_scheme 1

  livecheck do
    url "https://download.eclipse.org/jdtls/milestones/"
    regex(%r{href=.*?/v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "c925ed9d3742f1fe685087b12e33854857699d9d344e8207e9038ca57ed3ca59"
  end

  depends_on "openjdk"
  depends_on "python@3.11"

  def install
    libexec.install %w[bin config_mac config_linux features plugins]
    rewrite_shebang detected_python_shebang, libexec/"bin/jdtls"
    (bin/"jdtls").write_env_script libexec/"bin/jdtls", Language::Java.overridable_java_home_env
  end

  test do
    require "open3"

    json = <<~JSON
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "rootUri": null,
          "capabilities": {}
        }
      }
    JSON

    Open3.popen3("#{bin}/jdtls", "-configuration", "#{testpath}/config", "-data",
        "#{testpath}/data") do |stdin, stdout, _e, w|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      sleep 3
      assert_match(/^Content-Length: \d+/i, stdout.readline)
      Process.kill("KILL", w.pid)
    end
  end
end
