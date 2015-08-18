require 'rbconfig'

module BuildConfig
  def self.host_os
    case RbConfig::CONFIG['host_os']
    when /mswin|windows/i
      :windows
    when /linux|arch/i
      :linux
    when /darwin/i
      :mac
    else
      :unknown
    end
  end

  def self.host_arch
    case RbConfig::CONFIG['arch']
    when /x86_64/i
      :x64
    when /x86/i
      :x86
    else
      :unknown
    end
  end

  def self.target_os
    case ENV['TARGET_OS']
    when 'linux'
      :linux
    when 'darwin'
      :darwin
    when 'android'
      :android

    # TODO:
    # when 'windows'
    else
      raise 'TARGET_OS not given or invalid'
    end
  end

  def self.target_arch
    case ENV['TARGET_ARCH']
    when 'x86'
      :x86
    when 'x64'
      :x64
    when 'arm'
      :arm
    else
      raise 'TARGET_ARCH not given or invalid'
    end
  end

  DARWIN_VERSION = 12

  def self.cross_prefix
    case target_os
    when :linux
      case target_arch
      when :x86
        raise 'Currently, static x86 is not supported'
      when :x64
        'x86_64-linux-musl'
      else
        raise 'No valid architecture provided'
      end
    when :android
      'arm-linux-musleabihf'
    when :darwin
      "x86_64-apple-darwin#{DARWIN_VERSION}"
    else
      raise 'Invalid target OS'
    end
  end

  ENVIRONMENT = {
    'AR'     => 'ar',
    'CC'     => 'gcc',
    'CXX'    => 'g++',
    'LD'     => 'ld',
    'RANLIB' => 'ranlib',
    'STRIP'  => 'strip',
  }

  if target_os == :darwin then
    ENVIRONMENT['CC'] = 'clang'
    ENVIRONMENT['CXX'] = 'clang++'
  end

  # Prefix all things in environment
  ENVIRONMENT.keys.each do |key|
    ENVIRONMENT[key] = cross_prefix + '-' + ENVIRONMENT[key]
  end

  # Set additional environment flags.
  if target_os == :darwin then
    ENVIRONMENT['OSXCROSS_NO_INCLUDE_PATH_WARNINGS'] = '1'
  end

  # Set up static flag.
  if target_os == :darwin then
    STATIC_FLAG = '-flto -O3 -mmacosx-version-min=10.6'
  else
    STATIC_FLAG = '-static'
  end

  ENVIRONMENT['CFLAGS'] = STATIC_FLAG
  ENVIRONMENT['CXXFLAGS'] = STATIC_FLAG
end
