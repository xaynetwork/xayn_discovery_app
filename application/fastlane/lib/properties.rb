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

require "json"
require "open-uri"
require "fileutils"
require "digest"

def getLastDate(uri, suffix)
  uri = URI(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start do |http|
    response = http.request_head("/#{suffix}")
    lastModified = response["Last-Modified"]
    return Time.parse(lastModified)
  end
end

def download(url, path)
  FileUtils.mkdir_p File.dirname(path)
  total = nil
  puts url
  io = URI.open(url,
                :content_length_proc => lambda { |t|
                  if t && t > 0
                    total = t
                  end
                },
                :progress_proc => lambda { |s|
                  if total
                    progress = ((s.to_f * 100) / total.to_f).to_i
                    STDOUT.write "\r#{url} (#{s} / #{total} bytes) : #{progress}%  "
                  end
                })
  case io
  when StringIO then File.open(path, "w") { |f| f.write(io.read) }
  when Tempfile then io.close; FileUtils.mv(io.path, path)
  end
end

def downloadOnlyWhenNewer(baseUri, suffix, pathToSave)
  path = "#{baseUri}/#{suffix}"
  lastModifiedServer = getLastDate(baseUri, suffix)
  fileToWrite = File.join(pathToSave, suffix)
  lastModifiedLocal = nil
  if File.file?(fileToWrite)
    lastModifiedLocal = File.mtime(fileToWrite)
  end
  if lastModifiedLocal == nil || lastModifiedLocal < lastModifiedServer
    UI.success "Start downloading #{path} to #{fileToWrite}."
    download(path, fileToWrite)
    UI.success "Finished."
  else
    UI.success "Skipped #{path} because #{fileToWrite} already exists."
  end
end

def downloadOnlyWhenNotMatchingSha2(baseUri, suffix, pathToSave, checksum)
  fileToWrite = File.join(pathToSave, suffix)
  checksumFile = getChecksum256(fileToWrite)
  url = "#{baseUri}/#{suffix}"
  if checksum == checksumFile
    UI.success "File #{fileToWrite} from #{url} already exsists."
  else
    UI.success "File #{fileToWrite} (#{checksumFile}) != (#{checksum}) #{url}. Will download."
    download(url, fileToWrite)
    checksumFile = getChecksum256(fileToWrite)
    raise "Downloaded checksum does not match checksum in manifest!" if checksumFile != checksum
  end
end

def getChecksum256(filePath)
  if File.file?(filePath)
    Digest::SHA256.file(filePath).to_s
  else
    0.to_s
  end
end
