local socket = require "socket"
local BYTE_LENGTH = 2	--用于表示包大小的字节数
local BYTE_RPC_ID = 2 	-- 用于表示RPCID的字节数
local S2CDefine = require "defs/S2CRpc"
local C2SDefine = require "defs/C2SRpc"
require "defs/S2CImp"
RpcMgr = {}
C2S = {}
EnumReadMode = {
	READ_LENGTH = 0,
	READ_DATA = 1
}
function RpcMgr:InitModule()
	for id, v in pairs(C2SDefine) do
		C2S[v[1]] = function(...)
			RpcMgr:SendDataToAddr(id, ...)
		end
	end

	local function defaultImplement(...)
		print(...)
	end
	setmetatable(C2S, {
		__index = function(t, k)
			print("C2S Not Implement: " .. k)
			return defaultImplement
		end
	})
	
	self.m_last = ""
	self.m_NextReadSize = BYTE_LENGTH
	self.m_Mode = EnumReadMode.READ_LENGTH
end

function RpcMgr:Connect(ip, port)
	if self:IsConnected() then
		print("Error Has Connected")
		return
	end
	self.m_fd = assert(socket.tcp())
	self.m_fd:settimeout(1)
	local result, err = self.m_fd:connect(ip, port)
	if not result then
		self.m_fd = nil
		print("Error connecting: " .. err)
		return
	end
	self.m_fd:settimeout(0)

	self.m_ip = ip
	self.m_port = port
end

function RpcMgr:IsConnected()
	return self.m_fd and true or false
end

function RpcMgr:DisConnect()
	if self.m_fd then
		self.m_fd:close()
		self.m_fd = nil
	end
end

function RpcMgr:SendDataToAddr(rpcId, ...)
	if not self.m_fd then
		print("Error no connected")
		return
	end
	local packedInfo = string.pack(C2SDefine[rpcId][2], ...)
	local data = string.pack("I2I2", #packedInfo + BYTE_RPC_ID, rpcId) .. packedInfo
	self.m_fd:send(data)
end

function RpcMgr:TryRecv(f)
	local result
	result, self.m_last = f(self.m_last)
	if result then
		return result, self.m_last
	end
	local r, err = self.m_fd:receive(self.m_NextReadSize)
	-- print(r)
	if not r then
		if err ~= "timeout" then
			print("Receive error: " .. err)
		end
		return nil, self.m_last
	end
	if r == "" then
		error "Server closed"
	end
	return f(self.m_last .. r)
end

-- 按包长度解析
function RpcMgr.UnpackPackage(bytes)
	local size = #bytes
	if size < BYTE_LENGTH then
		return nil, bytes
	end
	local len, nxt = string.unpack("I2",  bytes)
	RpcMgr.m_NextReadSize = len
	if size < len + 2 then
		return nil, bytes
	end
	RpcMgr.m_NextReadSize = BYTE_LENGTH
	return bytes:sub(nxt, nxt + len - 1), bytes:sub(nxt + len)
end

function RpcMgr:RecvOneRpc()
	if not self:IsConnected() then
		print("Error no connected")
		return
	end

	-- 尝试收一个包
	local result
	result, self.m_last = self:TryRecv(RpcMgr.UnpackPackage)
	if not result then
		return
	end

	-- 解析RPCID
	local rpcId, nxt = string.unpack("I2", result)
	if not S2CDefine[rpcId] then
		print("Not Found S2C RPCId " .. rpcId)
		return
	end

	-- 调用对应的处理函数
	local name, format = table.unpack(S2CDefine[rpcId])
	S2C[name](string.unpack(format, result, nxt))

	return true
end

-- 尝试收一个包 新方法理论性能更好
function RpcMgr:TryRecvOnePackage()
	local r, err = self.m_fd:receive(self.m_NextReadSize)
	if not r then
		if err ~= "timeout" then
			print("Receive error: " .. err)
		end
		return
	end
	if r == "" then
		error "Server closed"
		return
	end
	if self.m_Mode == EnumReadMode.READ_LENGTH then
		self.m_NextReadSize = string.unpack("I2",  r)
		self.m_Mode = EnumReadMode.READ_DATA
		return self:TryRecvOnePackage()
	else
		self.m_Mode = EnumReadMode.READ_LENGTH
		self.m_NextReadSize = BYTE_LENGTH
		return r
	end
end

function RpcMgr:RecvAllRpc()
	if not self:IsConnected() then
		return
	end

	-- 尝试收一个包 新方法理论性能更好
	while true do
		local result = self:TryRecvOnePackage()
		if not result then
			break
		end

		-- 解析RPCID
		local rpcId, nxt = string.unpack("I2", result)
		if not S2CDefine[rpcId] then
			print("Not Found S2C RPCId " .. rpcId)
			return
		end

		-- 调用对应的处理函数
		local name, format = table.unpack(S2CDefine[rpcId])
		S2C[name](string.unpack(format, result, nxt))
	end
end
local socket = require "socket"
local BYTE_LENGTH = 2	--用于表示包大小的字节数
local BYTE_RPC_ID = 2 	-- 用于表示RPCID的字节数
local S2CDefine = require "defs/S2CRpc"
local C2SDefine = require "defs/C2SRpc"
require "defs/S2CImp"
RpcMgr = {}
C2S = {}
EnumReadMode = {
	READ_LENGTH = 0,
	READ_DATA = 1
}
function RpcMgr:InitModule()
	for id, v in pairs(C2SDefine) do
		C2S[v[1]] = function(...)
			RpcMgr:SendDataToAddr(id, ...)
		end
	end

	local function defaultImplement(...)
		print(...)
	end
	setmetatable(C2S, {
		__index = function(t, k)
			print("C2S Not Implement: " .. k)
			return defaultImplement
		end
	})
	
	self.m_last = ""
	self.m_NextReadSize = BYTE_LENGTH
	self.m_Mode = EnumReadMode.READ_LENGTH
end

function RpcMgr:Connect(ip, port)
	if self:IsConnected() then
		print("Error Has Connected")
		return
	end
	self.m_fd = assert(socket.tcp())
	self.m_fd:settimeout(1)
	local result, err = self.m_fd:connect(ip, port)
	if not result then
		self.m_fd = nil
		print("Error connecting: " .. err)
		return
	end
	self.m_fd:settimeout(0)

	self.m_ip = ip
	self.m_port = port
end

function RpcMgr:IsConnected()
	return self.m_fd and true or false
end

function RpcMgr:DisConnect()
	if self.m_fd then
		self.m_fd:close()
		self.m_fd = nil
	end
end

function RpcMgr:SendDataToAddr(rpcId, ...)
	if not self.m_fd then
		print("Error no connected")
		return
	end
	local packedInfo = string.pack(C2SDefine[rpcId][2], ...)
	local data = string.pack("I2I2", #packedInfo + BYTE_RPC_ID, rpcId) .. packedInfo
	self.m_fd:send(data)
end

function RpcMgr:TryRecv(f)
	local result
	result, self.m_last = f(self.m_last)
	if result then
		return result, self.m_last
	end
	local r, err = self.m_fd:receive(self.m_NextReadSize)
	-- print(r)
	if not r then
		if err ~= "timeout" then
			print("Receive error: " .. err)
		end
		return nil, self.m_last
	end
	if r == "" then
		error "Server closed"
	end
	return f(self.m_last .. r)
end

-- 按包长度解析
function RpcMgr.UnpackPackage(bytes)
	local size = #bytes
	if size < BYTE_LENGTH then
		return nil, bytes
	end
	local len, nxt = string.unpack("I2",  bytes)
	RpcMgr.m_NextReadSize = len
	if size < len + 2 then
		return nil, bytes
	end
	RpcMgr.m_NextReadSize = BYTE_LENGTH
	return bytes:sub(nxt, nxt + len - 1), bytes:sub(nxt + len)
end

function RpcMgr:RecvOneRpc()
	if not self:IsConnected() then
		print("Error no connected")
		return
	end

	-- 尝试收一个包
	local result
	result, self.m_last = self:TryRecv(RpcMgr.UnpackPackage)
	if not result then
		return
	end

	-- 解析RPCID
	local rpcId, nxt = string.unpack("I2", result)
	if not S2CDefine[rpcId] then
		print("Not Found S2C RPCId " .. rpcId)
		return
	end

	-- 调用对应的处理函数
	local name, format = table.unpack(S2CDefine[rpcId])
	S2C[name](string.unpack(format, result, nxt))

	return true
end

-- 尝试收一个包 新方法理论性能更好
function RpcMgr:TryRecvOnePackage()
	local r, err = self.m_fd:receive(self.m_NextReadSize)
	if not r then
		if err ~= "timeout" then
			print("Receive error: " .. err)
		end
		return
	end
	if r == "" then
		error "Server closed"
		return
	end
	if self.m_Mode == EnumReadMode.READ_LENGTH then
		self.m_NextReadSize = string.unpack("I2",  r)
		self.m_Mode = EnumReadMode.READ_DATA
		return self:TryRecvOnePackage()
	else
		self.m_Mode = EnumReadMode.READ_LENGTH
		self.m_NextReadSize = BYTE_LENGTH
		return r
	end
end

function RpcMgr:RecvAllRpc()
	if not self:IsConnected() then
		return
	end

	-- 尝试收一个包 新方法理论性能更好
	while true do
		local result = self:TryRecvOnePackage()
		if not result then
			break
		end

		-- 解析RPCID
		local rpcId, nxt = string.unpack("I2", result)
		if not S2CDefine[rpcId] then
			print("Not Found S2C RPCId " .. rpcId)
			return
		end

		-- 调用对应的处理函数
		local name, format = table.unpack(S2CDefine[rpcId])
		S2C[name](string.unpack(format, result, nxt))
	end
end
