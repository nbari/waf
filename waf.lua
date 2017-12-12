local redis_host               = "localhost"
local redis_port               = 6379
local redis_connection_timeout = 300
local redis_pattern            = "ip:"
local cache_ttl                = 3 -- seconds
local ip                       = ngx.var.remote_addr
local ip_blacklist             = ngx.shared.ip_blacklist
local last_update_time         = ip_blacklist:get("last_update_time");

-- block if ip found in the local nginx dict
if ip_blacklist:get(ip) then
    ngx.log(ngx.DEBUG, "Banned IP detected and refused access: " .. ip);
    return ngx.exit(429);
end

-- only update ip_blacklist from Redis once every cache_ttl seconds:
if last_update_time == nil or last_update_time < ( ngx.now() - cache_ttl ) then
    local redis = require "redis";
    local red = redis:new();

    red:set_timeout(redis_connect_timeout);

    local ok, err = red:connect(redis_host, redis_port);
    if not ok then
        ngx.log(ngx.DEBUG, "Redis connection error while retrieving ip_blacklist: " .. err);
    else
        local res, err = red:get(redis_pattern .. ip);
        if err then
            ngx.log(ngx.DEBUG, "Redis read error while retrieving ip_blacklist: " .. err);
            return
        end
        if res ~= ngx.null then
            local ttl, err = red:ttl(redis_pattern .. ip);
            if not ttl then
                ngx.log(ngx.DEBUG, "Redis connection error while retrieving ttl" .. err);
                return
            end
            -- add IP to the ip_blacklist dict inheriting the TTL form redis
            ip_blacklist:set(ip, true, ttl);
            ip_blacklist:set("last_update_time", ngx.now());
        end
    end
end