def checkIfComponentsInstalled(params)
    hash = {}
    params.each do |i|
        value = shell("which #{i} || echo ''")
        puts value
        hash.store(i, value)
        if value.empty?
            UI.error "#{i} not found, did you forget to install it?"
        else
             hash.merge({i => value})
        end
    end
return hash
end
