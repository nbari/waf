local redis = require 'redis'
local client = redis.connect('127.0.0.1', 6379)
local response = client:ping()
print(response)

function iptonumber(str)
    local num = 0
    for elem in str:gmatch("%d+") do
        num = num * 256 + assert(tonumber(elem))
    end
    return num
end

local ip = "8.8.8.8"
print(iptonumber(ip))

local res, err = client:zrangebyscore("cidr:index", iptonumber(ip), "+inf",  "limit", "0", "1")
if #res == 0 then return end
local partialfirst,partiallast=unpack(res)
