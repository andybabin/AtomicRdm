-------------------------------------------------
-----Atomic Superbowl 2021 RDM Magic script------
-----       v0.2 andybabin@me.com          ------
-------------------------------------------------

ola_rdm_start = 'ola_rdm_set -u 1 --uid ' --this is the OLA command to do RDM setting, this defaults to universe 1 for what we're doing
uid_device_table = {} --clears out device table
box_table = {} --clears out box table
ola_dmx_out = 'ola_set_dmx -u 1 -d '

database = "superbowl2021_production.csv"

color_wait = 0.5




os.execute("clear")
--print(atomic_logo)
print("Atomic RDM Identify")

dmx_out = {} --dmx out array for OLA
for i=1, 512 do
	dmx_out[i] = 0
end

dmx_string = table.concat(dmx_out, ",")








os.execute(ola_dmx_out .. "255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red

function os.capture(cmd, raw) --runs command and returns output in raw format
    local handle = assert(io.popen(cmd, 'r'))
    local output = assert(handle:read('*a'))

    handle:close()

    if raw then
        return output
    end

   return output
end





rdm_discover = os.capture("ola_rdm_discover -u 1") --discovers connected devices on dmx universe 1 in OLA



for i in string.gmatch(rdm_discover, "%S+") do --inserts uid's into table, make sure there are 4
   --print(i)
   table.insert(uid_device_table, i)


end

   if #uid_device_table ~= 4 then
	io.write('There are not 4 decoders, are you sure you want to continue?')
	local answer = io.read()
			if answer == "y" then
			else
			print("exited")
			os.exit()
	end
	end


decoder_count = #uid_device_table --keeps count of number of discovered decoders

	io.write('node ID? ') --asks for nodeid as first column of CSV
	node_id = io.read() --stores nodeid for later file writing


function sleep(n)
  os.execute("sleep " .. tonumber(n))
end


function color_cycle() --does a red/green/blue cyle to test all ch of LED
	os.execute(ola_dmx_out .. "255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red
	sleep(color_wait)

	os.execute(ola_dmx_out .. "0,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red
	sleep(color_wait)

	os.execute(ola_dmx_out .. "0,0,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red
	sleep(color_wait)

	os.execute(ola_dmx_out .. "255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red
end

color_cycle() -- runs color cycle function




--[[
--add function to check for current node in database

function nodecheck() -- this never got implemented, it was to check for duplicates
	file = io.open (database , a) --open file
	 local node_array_check = {} --empty array for file

	 for line in file:lines() do --writes each line to an item in an array
		table.insert (node_array_check, line);
	 end

	 for i,v in pairs(node_array_check) do --looks for node input in array
	  if string.find(v, node_id) ~= node_id then
		print("node exists in line " .. i)
		os.exit()
		break
		else
		print("not found")
	  end
	end

	file:close()
end
--nodecheck()

function decoder_check() --also never got implimented
	file = io.open (database , a) --open file
	 local decoder_check_array = {} --empty array for file

	 for line in file:lines() do --writes each line to an item in an array
		table.insert (decoder_array_check, line);
	 end

	 for i,v in pairs(decoder_check_array) do --looks for node input in array
	  if string.find(v, uid_device_table[1]) ~= node_id then
		print("decoder exists in line " .. i)
		os.exit()
		break
		else
		print("not found")
	  end
	end

	file:close()
end
--decoder_check()
]]--



function print_tables(table) --prints table for debug
    for key, value in pairs(table) do --prints table for debug
        print('\t', key, value)
    end
end
--print_tables(uid_device_table)

i = 1 --resets i

while i <= decoder_count do --sets all discovered nodes to address 501 to get them out of the way and makes them 10ch mode
	os.execute(ola_rdm_start .. uid_device_table[i] .. ' dmx_personality 2') --makes 10 ch/16bit mode
	os.execute(ola_rdm_start .. uid_device_table[i] .. ' dmx_start_address '.. 501)

	i = i + 1
end




boxcount = 1
box_table = {0,0,0,0}

while boxcount <= 4 do --this function cycles through the 4 nodes and turns them on/identifies them. Then it asks for their order

	current = uid_device_table[boxcount] -- this is the first one discovered
	os.execute(ola_rdm_start .. current .. ' dmx_start_address '.. 1) --makes start address 1 to flash red
	--print(current)

	os.execute(ola_rdm_start .. current .. ' IDENTIFY_DEVICE true') --blink unknown

	io.write('Which box is blinking? ') --ask which is unknown

	box = io.read() --ask which box this is

	--print("box ask " ..box)

	--print("current uid= "..current)

	box = tonumber(box)

	box_table[box] = current


	--print("table "..box_table[boxcount])

	os.execute(ola_rdm_start .. current .. ' IDENTIFY_DEVICE false') --disable ID
	os.execute(ola_rdm_start .. current .. ' dmx_start_address '.. 501) --sets id'ed device out of the way


	--print(box)
	boxcount = boxcount + 1

end


--UNCOMMMENT THIS FOR PROPT FOR ADDRESSING, THIS IS NORMALLY HANDLED IN OTHER function
--[[
	--io.write('DMX Start? ')
	--start = io.read() ]]--
	start = 1

i = 1

while i <= 4 do --cycles through all 4 decoders and addresses them
	os.execute(ola_rdm_start .. box_table[i] .. ' dmx_personality 2') --Confirms we're on DMX personality 2
	os.execute(ola_rdm_start .. box_table[i] .. ' dmx_start_address '.. start) --Sets start
	--print('ola_rdm_set -u 1 --uid ' .. box_table[i] .. ' dmx_start_address ' .. start)
	start = start + 6
	i = i + 1
end


file = io.open(database, "a") --opens database in append mode

file:write("\n",node_id ..","..box_table[1]..","..box_table[2]..","..box_table[3]..","..box_table[4]..",,,,,")

file:close() --closes file

os.execute(ola_dmx_out .. "255,255,0,0,0,0,0,0,255,255,0,0,0,0,0,0,255,255,255,255,255,255") --makes first to ch red, seccond green, third blue, and 4th yellow
