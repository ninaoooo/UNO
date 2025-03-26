Quaternion = {}
Quaternion.__index = Quaternion

function Quaternion.Euler(x, y, z)
    local radX = math.rad(x)
    local radY = math.rad(y)
    local radZ = math.rad(z)

    local cy = math.cos(radZ * 0.5)
    local sy = math.sin(radZ * 0.5)
    local cp = math.cos(radY * 0.5)
    local sp = math.sin(radY * 0.5)
    local cr = math.cos(radX * 0.5)
    local sr = math.sin(radX * 0.5)

    local q = {}
    q.w = cr * cp * cy + sr * sp * sy
    q.x = sr * cp * cy - cr * sp * sy
    q.y = cr * sp * cy + sr * cp * sy
    q.z = cr * cp * sy - sr * sp * cy

    return q
end