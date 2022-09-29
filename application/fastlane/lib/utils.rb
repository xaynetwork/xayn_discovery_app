def checkIfComponentsInstalled(params)
    hash = {}
    params.each do |i|
        value = shell("which #{i} || echo ''").chomp
        if value.empty?
            UI.user_error! "#{i} not found, did you forget to install it?"
        else
            hash.store(i, value)
        end
    end
return hash
end
