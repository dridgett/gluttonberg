dir = File.join(Pathname(__FILE__).dirname.expand_path, "middleware")
require File.join(dir, "rewriter")
require File.join(dir, "locales")
require File.join(dir, "honeypot")

