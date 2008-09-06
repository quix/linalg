#
# Copyright (c) 2004-2008 by James M. Lawrence
#
# See LICENSE
#

require 'mkmf'
require 'enumerator'

module Enumerable
   def map_with_index 
      arr = []
      each_with_index { |e, i|
         arr << yield(e, i)
      }
      arr
   end
end

class Integer
   def enum
      enum_for(:times)
   end
end

module GenerateHeader
   def self.write(dir, outname, version = nil)
      outname = File.expand_path(outname)
      Dir.chdir(dir) {
         Dir.glob('*.P') { |f| File.unlink(f) }
         if system("f2c -R -P -\!c *.f")
            File.open(outname, "w") { |outfile|
               macro = File.basename(outname.upcase.gsub(".","_"))
               outfile.puts "#ifndef #{macro}"
               outfile.puts "#define #{macro}"
               outfile.puts "/* version #{version} */ " if version
               outfile.puts "/* generated #{Time.now} */"
               outfile.puts
               Dir.glob('*.P') { |pname|
                  File.open(pname) { |pfile|
                     pfile.each { |line|
                        next unless line =~ %r!^extern!
                        
                        # I don't understand why f2c inserts these ftnlen params
                        while line.gsub!(%r!, ftnlen [a-z]+_len\)!, ")") ; end
                        
                        outfile.write line
                     }
                  }
               }
               
               outfile.puts
               outfile.puts "#endif"
            }
         end
      }
   end
end

module ScanHeader
   extend self

   def ctype_canonical_form(ctype)
      ctype.gsub(%r!\*!, " * ").gsub(%r!\s+!, " ").strip
   end
      
   def parse_prototype(s, argnames = true)
      func, args = s.strip.gsub(%r!\s+!, " ").split(%r![\(\)]!)
      ret, name =
         func.
         strip.
         match(%r!^(\w[*\s\w]*[*\s])(\w+)$!).
         captures
      desc = {}
      desc[:name] = name
      desc[:return] = ctype_canonical_form(ret)
      desc[:args] = []
      unless args == "" or args.strip == "void"
         args.split(",").each { |arg|
            arg.sub!(%r!\w+\s*$!, "") if argnames
            desc[:args].push(ctype_canonical_form(arg))
         }
      end
      desc
   end
   
   def scan_header_io(io, ppdefs = nil)
      s = io.read
      s.gsub!(%r!^\s*\#.*$!, "")
      s.gsub!(%r!//.*$!, "")
      s.gsub!(%r!/\*.*?\*/!m, "")
      if ppdefs
         s.gsub!(%r!\w+!) { |word|
            if ppdefs[word]
               ppdefs[word]
            else
               word
            end
         }
      end
      s.scan(%r!\w[*\w\s]*?\w+\s*\(.*?\)\s*\;!m) { |func|
         yield parse_prototype(func)
      }
   end
   
   def scan_header(header, ppdefs = nil, &block)
      File.open(header) { |file|
         scan_header_io(file, ppdefs, &block)
      }
   end
end

module FunctionDB
   def self.read
      db = {}

      cppdefs = {
         "extern" => "",  
         
         # these are in g2c.h
         "C_f" => "void",
         "Z_f" => "void",
      }
      
      ["include/LAPACK.h", "include/BLAS.h"].each { |filename|
         print "reading #{filename}..."
         ScanHeader.scan_header(filename, cppdefs) { |desc|
            db[desc[:name]] = desc
         }
         puts "ok"
      }
      
      db
   end
end

module Lapack_c
   extend self

   def write(db)
      {

         :s => /^s/,
         :d => /^d/,
         :c => /^c/,
         :z => /^z/,
         :x => /^[^sdcz]/,

      }.each_pair { |letter, regex|
         part = {}
         db.keys.grep(regex).each { |key|
            part[key] = db.delete(key)
         }

         write_file(part,
                    "rb_lapack_#{letter}",
                    "define_lapack_#{letter}")
      }
   end
   
   def write_file(db, filename, funcname)
      File.open("#{filename}.c", "w+") { |file|
         file.puts %{#include "rb_lapack.h"\n\n}
         db.keys.sort.each { |func|
            Lapack_c.write_function(db[func], file)
         }
         
         file.puts "void #{funcname}()\n{\n"
         
         db.keys.sort.each { |func|
            file.puts <<EOS
    rb_define_singleton_method(rb_cLapack,
                               "#{func.sub(%r!_$!, "")}",
                               #{Lapack_c.rbname(func)},
                               #{db[func][:args].size}) ;
EOS
         }

         file.puts "\n}"
      }
   end

   def rbname(name)
      "rb_" + name.sub(%r!_$!, "")
   end

   def write_function(desc, out)
      rbname = rbname(desc[:name])
      args = ["VALUE klass"] + desc[:args].map_with_index { |type, i|
         "VALUE v#{i}"
      }
      conv = desc[:args].map { |type|
         "to_" + case type
                 when %r!^(\w+)$!
                    $1
                 when %r!^(\w+)\s*\*$!
                    "#{$1}_ptr"
                 else
                    raise "unknown arg type in #{desc[:name]}: '#{type}'"
                 end.gsub(" ","_")
      }
      assign = desc[:args].map_with_index { |type, i|
         "#{type} p#{i} = (#{type})NUM2ULONG(rb_funcall(v#{i}, #{conv[i]}, 0))"
      }
      ftncall = desc[:name] + "(" + desc[:args].size.enum.inject("") { |acc, i|
         acc + "p#{i}, "
      }.chop.chop + ")"
      ret = if desc[:return] =~ %r!^void$!i
               "#{ftncall} ; return Qnil ;"
            else
               "return " +
                  case desc[:return]
                  when %r!(^real$|^doublereal$)!
                     "rb_float_new((double)"
                  when %r!(^int|^logical$)!
                     "LONG2NUM((long)"
                  else
                     raise "unknown type return type in #{desc[:name]}: #{desc[:return]}"
                  end +
                  "#{ftncall})"
            end
               
      out.puts <<EOS
VALUE #{rbname}(#{args.join(",")})
{
    #{assign.join(" ;\n    ")} ;
    #{ret} ;
}

EOS
   end
end

module PullCode
   def self.pull(sofile, *reps)
      `nm -D #{sofile}`.each { |line|
         line =~ %r!U (\w+)!
         next unless $1
         func = $1
         reps.each { |d|
            d = d.sub %r!/$!, ""
            [
               "#{d}/#{func}.c",
               d + "/" + func.sub(%r!_$!, "") + ".c",
            ].each { |fname|
               if FileTest.exist? fname
                  FileUtils.cp fname, "."
                  puts "-->copied #{fname}"
                  break
               end
            }
         }
      }
   end
end

module Main
   extend self
   
   def genheader(*args)
      GenerateHeader.write(*args)
   end

   def pull(*args)
      PullCode.pull(*args)
   end

   def write_c
      db = FunctionDB.read
      Lapack_c.write(db)
   end
   
   def config
      unless have_header("g2c.h") and
            have_library("g2c") and
            have_library("blas") and
            have_library("lapack")
         puts "A full LAPACK installation was not found."
         exit(-1)
      end

      $distcleanfiles = [
         "rb_lapack_s.c",
         "rb_lapack_d.c",
         "rb_lapack_c.c",
         "rb_lapack_z.c",
         "rb_lapack_x.c",
      ]

      $CFLAGS += ' -I.. -include g2c_typedefs.h'
   end

   def create
      create_makefile("lapack")
   end

   STDOUT.sync = true
   action = ARGV.shift

   if action
      send(action, *ARGV)
   else
      config
      write_c
      create
   end
end


