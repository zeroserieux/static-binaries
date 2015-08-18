require 'rake'

# Configuration
ZLIB_VERSION = '1.2.8'

# Variables
ZLIB_BUILD_DIR = File.join(ENV['OUTPUT_DIR'], 'zlib')
ZLIB_ARCHIVE = File.join(ZLIB_BUILD_DIR, "zlib-#{ZLIB_VERSION}.tar.gz")
ZLIB_SOURCE_DIR = File.join(ZLIB_BUILD_DIR, "zlib-#{ZLIB_VERSION}")

# The zlib build script is very simple - we need to set these variables
# explicitly.
ZLIB_ENV = BuildConfig::ENVIRONMENT.clone
ZLIB_ENV['CHOST'] = BuildConfig.cross_prefix
ZLIB_ENV['CC'] += ' ' + BuildConfig::STATIC_FLAG
ZLIB_ENV['CFLAGS'] = '-fPIC'


namespace :zlib do
  desc '[zlib] Create the build directory'
  directory ZLIB_BUILD_DIR => [ENV['OUTPUT_DIR']]

  desc '[zlib] Download archive'
  file ZLIB_ARCHIVE => [ZLIB_BUILD_DIR] do |t|
    sh "curl -sL -o #{t.name} http://zlib.net/zlib-#{ZLIB_VERSION}.tar.gz"
  end

  desc '[zlib] Decompress the archive'
  file ZLIB_SOURCE_DIR => [ZLIB_BUILD_DIR, ZLIB_ARCHIVE] do |t|
    sh "tar -C #{ZLIB_BUILD_DIR} -xzf #{ZLIB_ARCHIVE}"
  end

  desc '[zlib] Configure the build'
  ZLIB_CONFIGURE_MARKER = File.join(ZLIB_SOURCE_DIR, 'zlib.pc')
  file ZLIB_CONFIGURE_MARKER => [ZLIB_SOURCE_DIR] do |t|
    Dir.chdir(ZLIB_SOURCE_DIR) do
      ClimateControl.modify(ZLIB_ENV) do
        sh './configure --static'
      end
    end
  end

  desc '[zlib] Run the build'
  file File.join(ZLIB_SOURCE_DIR, 'libz.a') => [ZLIB_CONFIGURE_MARKER] do |t|
    ClimateControl.modify(ZLIB_ENV) do
      sh "make -C #{ZLIB_SOURCE_DIR}"
    end
  end

  task :zlib => [File.join(ZLIB_SOURCE_DIR, 'libz.a')]
end

# Clean settings
CLEAN.include(ZLIB_SOURCE_DIR)
CLOBBER.include(ZLIB_ARCHIVE)
