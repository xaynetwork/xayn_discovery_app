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
end

# Reads and sets properties in a file
def setProperties(path, hash, separator = "=")
  if File.file?(path)
    loadedProperties = loadProperties(path)
    hash = loadedProperties.merge(hash)
  end
  File.delete(path) if File.exist?(path)
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