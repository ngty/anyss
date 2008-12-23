# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{anyss}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ng Tze Yang"]
  s.date = %q{2008-12-24}
  s.description = %q{Anyss is a very basic wrapper for gnumeric's ssconvert binary.}
  s.email = ["ngty77@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = [".git/HEAD", ".git/config", ".git/description", ".git/hooks/applypatch-msg", ".git/hooks/commit-msg", ".git/hooks/post-commit", ".git/hooks/post-receive", ".git/hooks/post-update", ".git/hooks/pre-applypatch", ".git/hooks/pre-commit", ".git/hooks/pre-rebase", ".git/hooks/prepare-commit-msg", ".git/hooks/update", ".git/index", ".git/info/exclude", ".gstat", "History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "anyss.gemspec", "lib/anyss.rb", "lib/anyss/exceptions.rb", "lib/anyss/version.rb", "script/console", "script/destroy", "script/generate", "spec/anyss_spec.rb", "spec/data/sample.csv", "spec/data/sample.gnumeric", "spec/data/sample.ods", "spec/data/sample.xls", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ngty/anyss}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{anyss}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Anyss is a very basic wrapper for gnumeric's ssconvert binary.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<session>, [">= 2.4.0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<session>, [">= 2.4.0"])
      s.add_dependency(%q<newgem>, [">= 1.2.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<session>, [">= 2.4.0"])
    s.add_dependency(%q<newgem>, [">= 1.2.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
