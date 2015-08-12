-- author: oriol@joor.net - license: MIT license
local lib = {}

lib.secret = "This is just a long string to set a seed"
lib.base_url = "http://downloads.local:55080/"
lib.base_dir = "/tmp/downloads/"

function lib.date_to_ts(date)
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+)"
  local runyear, runmonth, runday, runhour, runminute = date:match(pattern)

  if not ( runyear and runmonth and runday and runhour and runminute ) then
    lib.return_not_found('Invalid expire date format')
  end

  return os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute })
end

function lib.valid_ts(expire)
  local now = os.time()
  
  if now<expire then
    return true
  else
    return false
  end
end

function lib.get_file_descriptor(path_n_file)
  local f = io.open(path_n_file,'rb')
  if not f then
    lib.return_not_found('File NOT found.')
  end

  return f
end

function lib.get_file_content(f)
  local content = f:read("*all")
  f:close()
  
  return content
end


-- thanks to: http://lua-users.org/wiki/BaseSixtyFour
-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function lib.enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function lib.dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

function lib.get_signature( secret, ci, ed, pnf)
    local sha1 = require 'sha1'
    
    str = ci .. ed .. pnf
    return lib.enc(sha1.hmac( secret, str))
      :gsub("[+/=]", {["+"] = "-", ["/"] = "_", ["="] = ","})
      :sub(1,12)
end


function lib.return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

return lib
