
require 'rbconfig'
require 'fileutils'
require 'rdoc/rdoc'
require 'mkmf'

LINALG_VERSION = "0.3.2"

# developer use only
module LinalgPackager
   def _archive(pkgdir, type)
      filename = "#{pkgdir}.#{type}"
      case type
      when :tgz
         system("tar zvcf #{filename} #{pkgdir}")
      when :zip
         system("zip -r #{filename} #{pkgdir}")
      else
         raise "unknown archive type"
      end
      system("md5sum #{filename} > #{filename}.md5")
   end

   def _release(pkgdir, ziptype)
      Dir.chdir("..") {
         FileUtils.rm_rf pkgdir
         FileUtils.cp_r "linalg", pkgdir
         FileUtils.rm_rf(Dir.glob("#{pkgdir}/**/CVS") +
                            Dir.glob("#{pkgdir}/**/.svn"))
         _archive(pkgdir, ziptype)
         FileUtils.rm_rf pkgdir
      }
   end

   def _release_bin(pkgdir, ziptype)
      distclean
      config
      make
      doc
      FileUtils.mv "ext/lapack/lapack.so", "."
      FileUtils.mv "ext/linalg/linalg.so", "."
      distclean(false)
      FileUtils.mv "lapack.so", "ext/lapack"
      FileUtils.mv "linalg.so", "ext/linalg"
      _release(pkgdir, ziptype)
      FileUtils.rm "ext/lapack/lapack.so"
      FileUtils.rm "ext/linalg/linalg.so"
      distclean
   end

   def release_src
      distclean
      _release("linalg-#{LINALG_VERSION}", :tgz)
   end

   def release_bin
      pkgdir = "linalg-#{LINALG_VERSION}-#{CONFIG["arch"]}-ruby#{CONFIG["MAJOR"]}#{CONFIG["MINOR"]}"
      if pkgdir =~ /mingw32|mswin32/
         pkgdir.sub!(/mingw32/, "mswin32")
         _release_bin(pkgdir, :zip)
      else
         _release_bin(pkgdir, :tgz)
      end
   end
end

module Main
   include LinalgPackager
   extend self

   module Ext
      def self.each
         [
            "ext/lapack",
            "ext/linalg",
         ].each { |dir|
            Dir.chdir(dir) { |path|
               yield path
            }
         }
      end
   end

   def doc
      rdoc_files = [
         'lib/linalg.rb',
         'lib/lapack.rb',
         'lib/linalg/exception.rb',
         'lib/linalg/iterators.rb',
         'lib/linalg/dmatrix/main.rb',
      ] + Dir['lib/linalg/dmatrix/*.rb'].reject { |f|
         f =~ %r!/alias.rb$! or f =~ %r!/main.rb$!
      } + [
         'ext/linalg/dmatrix.c',
         'lib/linalg/dmatrix/alias.rb',
         'README',
      ]
      
      FileUtils.rm_rf "doc"
      RDoc::RDoc.new.document(rdoc_files)
   end

   def distclean(rmdoc = true)
      Ext.each { |path|
         puts "distclean #{path}"
         system("#{$make} distclean")
      }
      FileUtils.rm_rf "doc" if rmdoc
      FileUtils.rm_f Dir.glob("*.gem")
      FileUtils.rm_f Dir.glob("*~")
      FileUtils.rm_f Dir.glob("**/*~")
   end

   def make
      Ext.each { |path|
         puts "make #{path}"
         unless system("#{$make}")
            raise "compilation failed"
         end
      }
   end

   def config
      Ext.each { |path|
         puts "config #{path}"
         unless system("#{$ruby} extconf.rb")
            raise "configuration failed"
         end
      }
   end

   alias_method :configure, :config
   alias_method :extconf, :config

   def clean
      Ext.each { |path|
         puts "clean #{path}"
         system("#{$make} clean")
      }
   end

   def test
      Dir.chdir("test") {
         puts "testing"
         system("#{$ruby} -w all.rb")
      }
   end

   def install
      sitelibdir = Config::CONFIG["sitelibdir"]
      sitearchdir = Config::CONFIG["sitearchdir"]

      spec = [
         ["ext/linalg/linalg.so", sitearchdir + "/linalg.so", 0755],
         ["ext/lapack/lapack.so", sitearchdir + "/lapack.so", 0755],
         ["lib/linalg.rb", sitelibdir + "/linalg.rb", 0644],
      ] + Dir.glob("lib/linalg/*.rb").map { |f|
         [f, sitelibdir + "/linalg/" + File.basename(f), 0644]
      } + Dir.glob("lib/linalg/dmatrix/*.rb").map { |f|
         [f, sitelibdir + "/linalg/dmatrix/" + File.basename(f), 0644]
      }

      File.open("InstalledFiles", "w") { |log|
         class << log
            def puts(*args)
               super(*args)
               STDOUT.puts(*args)
            end
         end
         spec.each { |f|
            FileUtils.mkdir_p File.dirname(f[1]), :mode => 0755
            FileUtils.install f[0], f[1], :mode => f[2]
            log.puts "install #{f[0]} --> #{f[1]}"
         }
      }

      puts
      puts "Installation was successful."
      puts "Installed files are recorded in InstalledFiles."
      puts "Documentation is in doc/."
   end

   def uninstall
      sitelibdir = Config::CONFIG["sitelibdir"]
      sitearchdir = Config::CONFIG["sitearchdir"]
      [
         sitearchdir + "/lapack.so",
         sitearchdir + "/linalg.so",
         sitelibdir + "/linalg.rb",
         sitelibdir + "/linalg/",
         "InstalledFiles",
      ].each { |f|
         FileUtils.rm_rf(f)
         puts "remove #{f}"
      }
   end

   def setup
      make
      doc
   end

   def auto
      unless FileTest.exist?("ext/lapack/lapack.so") and
            FileTest.exist?("ext/linalg/linalg.so")
         config
         make
         doc
      end
      install
   end

   action = ARGV.shift || "auto"
   
   send(action, *ARGV)
end

module LinalgGem
   def makegembin
      FileUtils.cp "ext/lapack/lapack.so", "lib"
      FileUtils.cp "ext/linalg/linalg.so", "lib"
      FileUtils.mv "doc", "doc-save"
      distclean
      FileUtils.mv "doc-save", "doc"
      _makegem
      FileUtils.rm_f Dir.glob("lib/*.so")
   end

   def makegem
      distclean
      _makegem
   end

   def _makegem
      require 'rubygems'

      spec = Gem::Specification.new { |s|
         s.name = 'linalg'
         s.version = LINALG_VERSION

         s.summary = <<EOS
Ruby Linear Algebra Library.  Advanced linear algebra and fast matrix classes based on classic Fortran routines.
EOS
         s.summary.strip!
         
         s.description = <<EOS
linalg is a linear algebra library for real and complex matrices. Current functionality includes: singular value decomposition, eigenvectors and eigenvalues of a general matrix, least squares, LU, QR, Schur, Cholesky, stand-alone LAPACK bindings.
EOS
         s.description.strip!

         s.files = Dir.glob("**/*").reject { |f|
            false or
               f =~ %r!CVS$! or
               f =~ %r!\.svn$! or
               f =~ %r!\.gem$!
         }
         
         s.require_path = 'lib'
         s.autorequire = 'linalg'

         s.has_rdoc = false  # requires generated .c files 
         s.test_suite_file = "test/all.rb"

         s.author = "James M. Lawrence"
         s.email = "quixoticsycophant@gmail.com"
         s.homepage = "http://linalg.rubyforge.org"
         s.rubyforge_project = "linalg"
      }

      Gem::Builder.new(spec).build
   end
end

