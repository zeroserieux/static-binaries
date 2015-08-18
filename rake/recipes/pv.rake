require 'rake'

# Configuration
PV_VERSION = '1.6.0'

# Variables
PV_BUILD_DIR = File.join(ENV['OUTPUT_DIR'], 'pv')
PV_ARCHIVE = File.join(PV_BUILD_DIR, "pv-#{PV_VERSION}.tar.bz2")
PV_SOURCE_DIR = File.join(PV_BUILD_DIR, "pv-#{PV_VERSION}")

PV_ENV = BuildConfig::ENVIRONMENT.clone
PV_ENV['CFLAGS'] += ' -fPIC'


namespace :pv do
  desc '[pv] Create the build directory'
  directory PV_BUILD_DIR => [ENV['OUTPUT_DIR']]

  desc '[pv] Download archive'
  file PV_ARCHIVE => [PV_BUILD_DIR] do |t|
    sh "curl -sL -o #{t.name} https://www.ivarch.com/programs/sources/pv-#{PV_VERSION}.tar.bz2"
  end

  desc '[pv] Decompress the archive'
  file PV_SOURCE_DIR => [PV_BUILD_DIR, PV_ARCHIVE] do |t|
    sh "tar -C #{PV_BUILD_DIR} -xjf #{PV_ARCHIVE}"
  end

  desc '[pv] Configure the build'
  PV_CONFIGURE_MARKER = File.join(PV_SOURCE_DIR, 'config.status')
  file PV_CONFIGURE_MARKER => [PV_SOURCE_DIR] do |t|
    Dir.chdir(PV_SOURCE_DIR) do
      ClimateControl.modify(PV_ENV) do
        sh './configure --build=i686 --host=arm-linux-musleabihf'
      end
    end
  end

  desc '[pv] Run the build'
  file File.join(PV_SOURCE_DIR, 'libz.a') => [PV_CONFIGURE_MARKER] do |t|
    Dir.chdir(PV_SOURCE_DIR) do
      sh "sed -i '/^CC =/a LD = arm-linux-musleabihf-ld' Makefile"

      ClimateControl.modify(PV_ENV) do
        sh "make"
      end
    end
  end

  task :pv => [File.join(PV_SOURCE_DIR, 'libz.a')]
end

# Clean settings
CLEAN.include(PV_SOURCE_DIR)
CLOBBER.include(PV_ARCHIVE)
