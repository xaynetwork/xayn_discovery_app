class String
  def truncate(max)
    max = max - 1
    length > max ? "#{self[0...max]}…" : self
  end
end

# Returns a change log, based on the git history with no more than 50 lines
def gitChangeLog(version)
  Dir.chdir("../") do
    gitlog = sh "git log | head -n50"
    return "Version: #{version}\n\n#{gitlog}"
  end
end

PURE_SEMANTIC_VERSION = /^\d.\d{1,3}.\d{1,3}$/
JIRA_TICKETS = /([A-Z]{2}-[0-9]{1,4})/

def gitShortChangeLog(version, maxSize = -1, addDate = true)
  Dir.chdir("../") do
    log = sh 'git log  --pretty="%(describe:tags=true) %as %s" --first-parent --since="1 week ago"'
    issues = log.scan(JIRA_TICKETS) | []
    lines = log.split("\n")

    newLog = ""
    lastVersion = version
    lastDate = ""
    lastLine = ""
    for l in lines
      # %(describe:tags=true) %as %s => tag date title
      line = l.scan(/(.*?) (.*?) (.*)/)[0]
      if PURE_SEMANTIC_VERSION.match?(line[0]) && lastVersion != line[0]
        lastVersion = line[0]
        newLog += "\n#{lastVersion}\n"
      end
      if addDate
        if lastDate != line[1]
          lastDate = line[1]
          newLog += "\n#{lastDate}\n"
        end
      end
      if lastLine != line[2]
        lastLine = line[2]
        newLog += "- #{lastLine.truncate(50)}\n"
      end
    end

    issueString = issues.reduce("") { |a, i| "#{a} #{i[0]}" }
    completeLog = "Issues (last 7 days): #{issueString}\n\n#{version}\n#{newLog}"
    return maxSize > 0 ? completeLog.truncate(maxSize) : completeLog
  end
end

# Returns the version tag
def gitVersionName()
  return `git describe --tags | tr -d '\n'`
end

# Returns a consecutive number based on the amount of commits in this repo
def gitVersionNumber()
  return `git rev-list --count HEAD | tr -d '\n'`
end
