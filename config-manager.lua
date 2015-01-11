--[ Start all your NICs here ]--
rednet.open("bottom")

--[ Load a whitelist for queries ]--
--dofile("/whitelist")

--[ Variables ]--
DNSIP = 127 --Set to 0 for autodiscovery--
FQDN = "storage.csd.gr" -- The current host FQDN --
copies = 3 -- Amount of copies to keep of each file -- 