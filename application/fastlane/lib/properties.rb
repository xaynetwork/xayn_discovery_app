require "base64"

# Checks for a map of {envKey : propertyKey} if either of those is set and then tries to read it from the user
def askAndSetProperties(propertiesPath, hash, defaults)
  resultingProps = {}
  loadedProperties = loadProperties(propertiesPath)
  hash.each do |envKey, propertyKey|
    prop = ENV[envKey]
    propertyIsAlreadtSet = loadedProperties.key?(propertyKey)

    if propertyIsAlreadtSet && !prop
      puts("Already set #{propertyKey} in #{propertiesPath} and no alternative #{envKey} provided.")
      next
    end

    if defaults.key?(envKey)
      prop = defaults[envKey]
    end

    if !prop
      prop = UI.input("Please input #{envKey} (for #{propertiesPath} : #{propertyKey}) : ")
    end

    resultingProps[propertyKey] = prop
  end

  setProperties(propertiesPath, resultingProps)
  return resultingProps
end

# Reads and sets properties in a file
def setProperties(path, hash, separator = "=")
  if File.file?(path)
    loadedProperties = loadProperties(path)
    hash = loadedProperties.merge(hash)
  end
  File.delete(path) if File.exist?(path)
  dir = File.dirname(path)
  Dir.mkdir(dir) unless Dir.exists?(dir)
  File.open(path, "w") do |fo|
    hash.each do |key, value|
      fo.write("#{key}#{separator}#{value}\n")
    end
  end
end

def loadProperties(propertiesFilename, separator = "=")
  properties = {}
  if File.file?(propertiesFilename)
    File.open(propertiesFilename, "r") do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        if (line[0] != ?# and line[0] != ?=)
          i = line.index(separator)
          if (i)
            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
          else
            properties[line] = ""
          end
        end
      end
    end
  end
  properties
end

def askMultilineAndSetFile(fileName, envKey)
  cachedProps = loadProperties(".env")

  if ENV.key?(envKey)
    prop = ENV[envKey] != cachedProps[envKey] ? ENV[envKey] : Base64.decode64(ENV[envKey])
  end

  if !prop
    UI.message "Enter #{envKey} File, and end the input with an extra new line."
    prop = multi_gets
  end
  UI.user_error!("No valid value for #{envKey} provided") if !prop || prop == ""
  setProperties(".env", {
    envKey => Base64.strict_encode64(prop),
  })
  File.write(fileName, prop)
end

def multi_gets(all_text = "")
  UI.user_error!("Can not input because the console is not interactive!\nDid you forgot to provide some Env variable on the CI?") unless UI.interactive?
  UI.message "Stop the input by pressing <TAB> and then <ENTER>"
  return STDIN.readline(sep = "\t\n").sub(/.*\K\t\n/, "")
end
