-- Part of the massive rewrite I am making for the bin library. this library will sport hex, base32, base64, and base91 when it is done
-- For now feel free to take a look at this code and use it for your own needs
bit=require("bit")
function table.flip(t)
	local tt={}
	for i,v in pairs(t) do
		tt[v]=i
	end
	return tt
end
b91enc={
	'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '#', '$',
	'%', '&', '(', ')', '*', '+', ',', '.', '/', ':', ';', '<', '=',
	'>', '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '"'
}
b91enc[0]='A' -- algorithm expects a 0 as the first index, lua starts at 1... easy fix :)
b91dec=table.flip(b91enc)
function decode(d)
	local l,v,o,b,n = #d,-1,"",0,0
	for i in d:gmatch(".") do
		local c=b91dec[i]
		if not(c) then
			-- Continue
		else
			if v < 0 then
				v = c
			else
				v = v+c*91
				b = bit.bor(b, bit.lshift(v,n))
				if bit.band(v,8191) then
					n = n + 13
				else
					n = n + 14
				end
				while true do
					o=o..string.char(bit.band(b,255))
					b=bit.rshift(b,8)
					n=n-8
					if not (n>7) then
						break
					end
				end
				v=-1
			end
		end
	end
	if v + 1>0 then
		o=o..string.char(bit.band(bit.bor(b,bit.lshift(v,n)),255))
	end
	return o
end
function encode(d)
	local b,n,o,l=0,0,"",#d
	for i in d:gmatch(".") do
		b=bit.bor(b,bit.lshift(string.byte(i),n))
		n=n+8
		if n>13 then
			v=bit.band(b,8191)
			if v>88 then
				b=bit.rshift(b,13)
				n=n-13
			else
				v=bit.band(b,16383)
				b=bit.rshift(b,14)
				n=n-14
			end
			o=o..b91enc[v % 91] .. b91enc[math.floor(v / 91)]
		end
	end
	if n>0 then
		o=o..b91enc[b % 91]
		if n>7 or b>90 then
			o=o .. b91enc[math.floor(b / 91)]
		end
	end
	return o
end
enc=encode("Hungry for Apples!")
print(enc)
dec=decode(enc)
print(dec)
