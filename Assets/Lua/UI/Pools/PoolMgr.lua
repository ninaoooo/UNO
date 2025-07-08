local PoolMgr = {
    pools = {}
}

function PoolMgr:register(poolName, pool)
    if not self.pools[poolName] then
        self.pools[poolName] = pool
        print("PoolMgr:register - Get pool location : " .. tostring(self.pools[poolName]))
    else
        print("PoolMgr:register - Pool already exists with name: " .. poolName)
        
    end
end

function PoolMgr:getPool(poolName)
    if self.pools[poolName] then
        return self.pools[poolName]
    else
        print("PoolMgr:getPool - No pool found with name: " .. poolName)
        
        return nil
    end
end

function PoolMgr:clearAll()
    for _, pool in pairs(self.pools) do
        pool:destoryPool()
    end
end


function PoolMgr:printAllPoolNames()
    print("当前注册的对象池有：")
    for poolName, _ in pairs(self.pools) do
        print(" - " .. poolName)
    end
end


return PoolMgr
