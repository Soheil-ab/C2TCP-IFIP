require "formula"

class Alglib3 < Formula
  homepage "http://www.alglib.net"
  url "http://www.alglib.net/translator/re/alglib-3.8.2.cpp.zip"
  sha1 "d9707fb66611de2ce6a4ce95efc82117445b37a6"

  depends_on "qt"
  depends_on "pkg-config" => :build

  def install
    File.open("#{buildpath}/alglib.pro", "w") do |f|
      f.puts("TEMPLATE = subdirs")
      f.puts("SUBDIRS = \\")
      f.puts("    src")
    end

    File.open("#{buildpath}/src/src.pro", "w") do |f|
      f.puts("isEmpty(PREFIX) {")
      f.puts("  PREFIX = /usr/local")
      f.puts("}")
      f.puts("CONFIG      += warn_on release static_and_shared")
      f.puts("QT      -= gui core")
      f.puts("LIBS    -= -lQtGui -lQtCore")
      f.puts("TARGET       = alglib")
      f.puts("VERSION      = 3.8.2")
      f.puts("TEMPLATE     = lib")
      f.puts("target.path = $$PREFIX/lib")
      f.puts("DEPENDPATH += .")
      f.puts("INCLUDEPATH += .")
      f.puts("OBJECTS_DIR  = ../_tmp")
      f.puts("DESTDIR = ../")
      f.puts("HEADERS += *.h")
      f.puts("SOURCES += *.cpp")
      f.puts("header_files.files = $$HEADERS")
      f.puts("header_files.path = $$PREFIX/include/alglib")
      f.puts("INSTALLS += target")
      f.puts("INSTALLS += header_files")
      f.puts("CONFIG += create_pc create_prl no_install_prl")
      f.puts("QMAKE_PKGCONFIG_LIBDIR = $$PREFIX/lib/")
      f.puts("QMAKE_PKGCONFIG_INCDIR = $$PREFIX/include/alglib")
      f.puts("QMAKE_PKGCONFIG_CFLAGS = -I$$PREFIX/include/")
      f.puts("QMAKE_PKGCONFIG_DESTDIR = pkgconfig")
    end

    system "qmake", "alglib.pro", "PREFIX=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath / "test.cpp").write <<-EOS.undent
      #include <stdlib.h>
      #include <stdio.h>
      #include <time.h>
      #include "dataanalysis.h"
      int main(int argc, char **argv)
      {
          multilayerperceptron net;
          mlpcreate0(2, 1, net);
          mlprandomize(net);
          return 0;
      }
    EOS
    system ENV.cxx, "-o", "test", "test.cpp", "-L#{lib}", "-lalglib", "-I#{include}/alglib"
    system "./test"
  end
end