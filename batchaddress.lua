/////////////////////////////////////////////
/////Atomic Batch RDM addressing script/////
/////         andybabin@me.com        /////
//////////////////////////////////////////



ola_rdm_start = 'ola_rdm_set -u 1 --uid ' --this is the OLA command to do RDM setting, this defaults to universe 1 for what we're doing
uid_device_table = {} --clears out device table
box_table = {} --clears out box table
ola_dmx_out = 'ola_set_dmx -u 1 -d '


io.write('What database do you want?')
local db = io.read()

function dbselect()
	if db == "a" then
		filename = "superbowl2021_production.csv" --file name
		elseif db == "b" then
		filename = "superbowl2021_dev2.csv" --file name
		elseif db == "c" then
		filename = "superbowl2021_dev_rnd.csv" --file name

		else
		print("no idea")
	end
	return filename
end
filename = dbselect()
print(filename)

--filename = "superbowl2021_dev.csv" --file name
file = io.open (filename , a) --open file


 local node_array = {} --empty array for file

 for line in file:lines() do --writes each line to an item in an array
    table.insert (node_array, line);
 end





os.execute("clear")
print("Atomic RDM Batch Address")

dmx_out = {} --dmx out array for OLA
for i=1, 512 do
	dmx_out[i] = 0
end

dmx_string = table.concat(dmx_out, ",")

--os.execute(ola_dmx_out .. "255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0") --makes first to ch red

function os.capture(cmd, raw) --runs command and outputs
    local handle = assert(io.popen(cmd, 'r'))
    local output = assert(handle:read('*a'))

    handle:close()

    if raw then
        return output
    end

   return output
end



rdm_discover = os.capture("ola_rdm_discover -u 1") --discovers connected devices


 for i in string.gmatch(rdm_discover, "%S+") do --inserts uid's into table
   --print(i)
   table.insert(uid_device_table, i)
end

print("There are "..#uid_device_table .." decoders")



function split(str) --splits string (csv) at commas
    local array = {}
    local reg = string.format("([^%s]+)",",")
    for mem in string.gmatch(str,reg) do
        table.insert(array, mem)
    end
    return array
end



 ----compare node_array to uid_device_table, find first match, address
for i,v in pairs(node_array) do --looks for node input in array from CSV file

  for j,k in pairs (uid_device_table) do --cycles thorugh all discovered devices

	  if nil ~= string.find(v, k) then --
	  --v is whole node string
	  --k is individual node being found online

				decoded_table = split(v) --splits the string into individual CSV seperated things
				node_name = decoded_table[1]
				decoder_1 = decoded_table[2]
				decoder_2 = decoded_table[3]
				decoder_3 = decoded_table[4]
				decoder_4 = decoded_table[5]
				start_address = tonumber(decoded_table[6])
				decoder_1_sub = decoded_table[7]
				decoder_2_sub = decoded_table[8]
				decoder_3_sub = decoded_table[9]
				decoder_4_sub = decoded_table[10]

				if k == decoder_1 then --do an action based on the first decoder, this is so we don't address nodes 4 times (whoops)

					if (start_address ~= nil and start_address ~= 0) then --if there is something in the whole node address use it, otherwise goto sub addresses
						--print("Normal addressing")

						os.execute(ola_rdm_start .. decoder_1 .. ' dmx_start_address '.. start_address)
						os.execute(ola_rdm_start .. decoder_2 .. ' dmx_start_address '.. (start_address + 6))
						os.execute(ola_rdm_start .. decoder_3 .. ' dmx_start_address '.. (start_address + 12))
						os.execute(ola_rdm_start .. decoder_4 .. ' dmx_start_address '.. (start_address + 18))
						print("Addressed "..node_name.." in normal mode")
						--os.execute(ola_rdm_start .. decoder_1 .. ' device_label '.. "Atomic_"..node_name.."_1")
						--os.execute(ola_rdm_start .. decoder_2 .. ' device_label '.. "Atomic_"..node_name.."_2")
						--os.execute(ola_rdm_start .. decoder_3 .. ' device_label '.. "Atomic_"..node_name.."_3")
						--os.execute(ola_rdm_start .. decoder_4 .. ' device_label '.. "Atomic_"..node_name.."_4")
						else
						print("no start address")
					end

					if decoder_1_sub ~= nil then
						--print("Sub Addressing")

						os.execute(ola_rdm_start .. decoder_1 .. ' dmx_start_address '.. decoder_1_sub)
						os.execute(ola_rdm_start .. decoder_2 .. ' dmx_start_address '.. decoder_2_sub)
						os.execute(ola_rdm_start .. decoder_3 .. ' dmx_start_address '.. decoder_3_sub)
						os.execute(ola_rdm_start .. decoder_4 .. ' dmx_start_address '.. decoder_4_sub)
            print("Addressed "..node_name.." in sub mode")
						--os.execute(ola_rdm_start .. decoder_1 .. ' device_label '.. "Atomic_"..node_name.."_1")
						--os.execute(ola_rdm_start .. decoder_2 .. ' device_label '.. "Atomic_"..node_name.."_2")
						--os.execute(ola_rdm_start .. decoder_3 .. ' device_label '.. "Atomic_"..node_name.."_3")
						--os.execute(ola_rdm_start .. decoder_4 .. ' device_label '.. "Atomic_"..node_name.."_4")
					end
				end


		--print("node exists line " .. i)
		--print("node is v "..v)
		--print("node is k "..k)
		active_node = i --no idea where I use this
		--break
		else
		--print("not found")
		end
  end
end



--print(current_line)
--print(node_name)
--print(decoder_1)
--print(decoder_2)


--io.write('What is the node you seek? ')
--local current_node = io.read()

 function print_tables(table) --prints table for debug
    for key, value in pairs(table) do --prints table for debug
        print('\t', key, value)
    end
end
--print_tables(node_array)
