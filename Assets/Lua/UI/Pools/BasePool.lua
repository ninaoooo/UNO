local BasePool = {}
BasePool.__index = BasePool

-- 1. 初始化并缓存N个对象
function BasePool:new(prefab,parent,count)
    local self = setmetatable({}, BasePool)
    self.prefab = prefab
    self.parent = parent
    self.count = count or 10
    self.pool = {}
    return self
end

function BasePool:warmup()
    for i=1, self.count do
        local obj = GameObject.Instantiate(self.prefab,self.parent)
        print("BasePool:warmup - prefab name: " .. self.prefab.name)
        obj:SetActive(false)
        table.insert(self.pool, obj)
    end
    print("BasePool:warmup - Warmed up pool with " .. #self.pool .. " objects.")
end

-- 2. 从池中取出一个对象
function BasePool:get()
    local obj
    if #self.pool >0 then
        print("BasePool:get - Get the pool location: " .. tostring(self.pool))
        obj = table.remove(self.pool)
    else
        obj = GameObject.Instantiate(self.prefab, self.parent)
    end
    obj:SetActive(true)
    return obj
end


-- 3. 清理对象状态
function BasePool:clean(obj)
    -- error("BasePool:clean should be overridden by subclass")
end

-- 4. 将对象放回池中
function BasePool:put(obj)
    self:clean(obj)
    obj:SetActive(false)
    obj.transform:SetParent(self.parent, false)
    table.insert(self.pool, obj)
end

-- 销毁池子中所有对象
function BasePool:destoryPool()
    for _, obj in ipairs(self.pool) do
        GameObject.Destroy(obj)
    end
    self.pool = {}
end

function BasePool:getPoolLength()
    return #self.pool
end
return BasePool