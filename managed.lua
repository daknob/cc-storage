--[ Storage Management System ]--
--[    		 DaKnOb			 ]--

function autoDiscoverDNSIP()
	rednet.broadcast("SMS/DNS-FETCH", "dnsdi")
	receipts = 0
	failed = 0
	while true do
		if(failed == 4 and receipts >= 2)then
			print("[FATAL ERROR]")
			print("Cannot autoconfigure DNS")
			exit(2)
		end
		if(failed == 4) then
			failed = 0
			receipts = receipts + 1
			rednet.broadcast("SMS/DNS-FETCH", "dnsdi")
		end
		sender, message, protocol = rednet.receive(1)
		if(tonumber(message) == 0 or tonumber(message) == nil or message == nil) then
			failed = failed + 1
		end
		if (protocol == "dnsdi") then
			got = tonumber(message)
			if(got > 0 and got < 65536)then
				return got
			end
		end
	end
end

function dnsResolve(hostname)
	rednet.send(DNSIP, hostname, "dns")
	rcpt = 0
	fail = 0
	while true do 
		while true do
			if(fail == 4 and rcpt == 4) then
				print("[FATAL ERROR]")
				print("Could not query DNS")
				exit(3)
			end
			if(fail == 4) then
				fail = 0
				rcpt = rcpt + 1
				rednet.send(DNSIP, hostname, "dns")
			end
			sender, message, protocol = rednet.receive(1)
			if(message == nil or sender == nil or protocol == nil) then
				fail = fail + 1
			end
			if(tonumber(sender) ~= tonumber(DNSIP)) then
				fail = fail + 1
				break --continue
			end
			if(protocol ~= "dns") then
				fail = fail + 1
				break --continue
			end
			if(message == "") then
				fail = fail + 1
				break
			end
			
			return message
			
		end
	end
end

print("Initializing storage manager...")
print("Loading worker nodes...")
dofile("/store-clients")
print("Loading configuration...")
dofile("/config-manager")
print("Checking DNS...")
if( DNSIP == 0 ) then
	DNSIP = autoDiscoverDNSIP()
end
print("Loaded DNS Server ", DNSIP, "!")
print("Testing DNS...")
toldFQDN = dnsResolve("self")
if(toldFQDN ~= FQDN) then
	print("FQDN MISMATH! Hardcoded: ", FQDN, " DNS: ", toldFQDN)
end
print("Done!")
print("Resolving DNS records for all workers...")
workers = {}
for k,v in pairs(clients) do
	workers.insert(dnsResolve(v))
end
for k,v in pairs(workers) do
	if(tonumber(v) == 0) then
		print("FAILED TO RESOLVE WORKER #", k, ". Ignoring.")
		workers.remove(k)
	end
end
if(#workers < 1) then
	print("[FATAL ERROR] No workers!")
	exit(4)
end
