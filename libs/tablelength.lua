-- src: https://stackoverflow.com/a/2705804/10495683
function tablelength (T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

return tablelength