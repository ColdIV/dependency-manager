-- Uses this as API: https://github.com/ColdIV/discord-bot-api
local obj = {}

obj.API_TOKEN = ''
obj.API_URL = ''

function obj:init(API_TOKEN, API_URL)
    if API_TOKEN == nil or API_URL == nil then
        return false
    end

    self.API_TOKEN = API_TOKEN
    self.API_URL = API_URL
    return true
end

function obj:send(message)
    if not http.checkURL(self.API_URL) then return false end
    http.post(self.API_URL, "token=" .. self.API_TOKEN .. "&message=" .. message)
    --@TODO: Check response for success message; return true / false accordingly.
    return true
end

return obj