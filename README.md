# AtomicRdm
Requires OLA installed https://www.openlighting.org/ and universe one configured to an apporopriate RDM node. Both mac homebrew and ports have OLA packages.

**nodeid.lua**
Run this script first. this will look for 4 RDM devices on the universe, and then prompt you for thier decoder name. From there it will cycle through lighting up the 4 nodes and ask for their ID order. This then writes the Decoder name and the RDM UID's to the last line of a CSV file.

**batchaddress.lua** 
This script prompts for a database/csv, and will then address all found nodes based on CSV. If the first address column is populated it will address in sequential order, otherwise it will look for the discreete decoder addresses. 
