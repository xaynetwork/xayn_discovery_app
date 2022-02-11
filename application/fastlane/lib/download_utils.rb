require "json"
require "open-uri"
require "fileutils"
require "digest"

### Tools to download files

def getLastModifiedForUrl(url, suffix)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start do |http|
    response = http.request_head("/#{suffix}")
    lastModified = response["Last-Modified"]
    return Time.parse(lastModified)
  end
end

def getLastModifiedForFile(path)
  lastModifiedLocal = nil
  if File.file?(path)
    lastModifiedLocal = File.mtime(path)
  end
  return lastModifiedLocal
end

def getChecksum256(filePath)
  if File.file?(filePath)
    Digest::SHA256.file(filePath).to_s
  else
    0.to_s
  end
end

def download(url, path)
  FileUtils.mkdir_p File.dirname(path)
  total = nil
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
  fileToWrite = File.join(pathToSave, suffix)
  lastModifiedServer = getLastModifiedForUrl(baseUri, suffix)
  lastModifiedLocal = getLastModifiedForFile(fileToWrite)
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
