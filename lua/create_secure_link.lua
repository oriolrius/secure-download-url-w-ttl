#!/usr/bin/lua
-- author: oriol@joor.net - license: MIT license

local lib = require( "lib")

local customer_id, expire_date, path_n_file = arg[1], arg[2], arg[3]

if not ( customer_id and expire_date and path_n_file ) then
    print("")
    print( "      " .. arg[0] .. " <customer_id> <expiration_date> <relative_path/filename>")
    print("")
    print( "Create URLs with expiration date.")
    print("")
    print("  customer_id: any string identifying the customer who wants the URL")
    print("  expiration_date: when URL has to expire, format: YYYY-MM-DDTHH:MM")
    print("  relative_path/filename: relative path to file to transfer, base path is: " .. lib.base_dir )
    
    os.exit(0)
end

local signature = lib.get_signature( lib.secret, customer_id, expire_date, path_n_file)

url = lib.base_url .. signature .. "/" .. customer_id .. "/" .. expire_date .. "/" .. path_n_file

print(url)
