# Returns a change log, based on the git history with no more than 50 lines
def gitChangeLog(version)
  Dir.chdir("../") do
    gitlog = sh "git log | head -n50"
    return "Version: #{version}\n\n#{gitlog}"
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
