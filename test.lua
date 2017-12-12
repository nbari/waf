local redis = require 'redis'
local client = redis.connect('127.0.0.1', 6379)
local response = client:ping()
if not response then
    print("can't connect to redis")
end

function iptonumber(str)
    local num = 0
    for elem in str:gmatch("%d+") do
        num = num * 256 + assert(tonumber(elem))
    end
    return num
end

-- test ip's
local ip = "8.8.8.8"
local ip = "155.204.0.3"
local ip = "31.184.238.3"
local ip_int = iptonumber(ip)

local res, err = client:zrangebyscore("cidr:ipv4", ip_int, "+inf",  "limit", "0", "1")
if #res == 0 then return end
if ip_int  >= tonumber(res[1]) then
    print(ip .. " in list")
    return
end
print(ip .. " not found")
