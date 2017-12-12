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

local ip = "8.8.8.8"
local ip = "155.204.0.3"
local ip_int = iptonumber(ip)

local res, err = client:zrangebyscore("cidr:index", ip_int, "+inf",  "limit", "0", "1")
if #res == 0 then return end
local res, err = client:hget("cidr:" .. res[1], "network")
if err then return end
if ip_int  >= tonumber(res) then
    print(ip .. " in list")
end
