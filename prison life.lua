--[[
    ✨ AURA HUB v12 — REGISTER FIXED ✨
    Все переменные в таблице S. Функционал тот же.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local WS = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PG = LocalPlayer:WaitForChild("PlayerGui")
if PG:FindFirstChild("AlphaHub") then PG.AlphaHub:Destroy() end

-- ==================================================
-- ТАБЛИЦА СОСТОЯНИЯ (вместо 100+ local)
-- ==================================================
local S = {
    -- Проверки
    hasDrawing = false, hasFile = false, hasHook = false, hasFilterGC = false, hasGetConn = false,
    -- Walk / Jump
    walk = false, walkVal = 16, jump = false, jumpVal = 50,
    infJump = false, infJumpConn = nil, watchdogConn = nil,
    -- Spin
    spin = false, spinVal = 10, spinConn = nil, savedHum = nil,
    -- ESP
    espTeam = true, espBox = false, espName = false, espLine = false,
    espBoxConn = nil, espNameConn = nil, espLineConn = nil,
    ESP_BOXES = {}, ESP_NAMES = {}, ESP_LINES = {},
    -- Spider
    spider = false, spiderConn = nil, wallHit = false, climbSpd = 0.28, boost = 22,
    -- Anti-Taze
    antiTaze = false, antiTazeConns = {},
    -- Auto Keycard
    keycard = false, keycardConn = nil, keycardRange = 20,
    -- Item Giver
    getting = false, autoGun = false, autoGunThread = nil,
    guns = {["M4A1"] = false, ["Remington 870"] = false, ["AK-47"] = false, ["MP5"] = false},
    -- Silent Aim
    aim = false, aimTeam = true, aimWall = true, aimFOV = 100, aimRange = 300,
    aimPart = "Head", aimChance = 100,
    aimIgnoreFriends = false, aimIgnoreGuards = false, aimIgnoreCrims = false,
    aimIgnoreInnocent = false, aimIgnoreFF = false,
    aimHooked = false, oldCastRay = nil, friendCache = {}, currentTarget = nil,
    -- Hitbox
    hb = false, hbSize = 3, hbVisual = true, hbTeam = false,
    hbIgnoreFriends = false, hbIgnoreGuards = false, hbIgnoreCrims = false, hbIgnoreInnocent = false,
    hbConn = nil, savedHB = {},
    -- Aura
    arrest = false, arrestRange = 7.5, arrestIgnoreFriends = false, arrestConn = nil,
    melee = false, meleeRange = 4, meleeIgnoreFriends = false, meleeConn = nil,
    -- Camera
    fov = false, fovVal = 70, fovConn = nil,
    fullbright = false, fullbrightConn = nil, savedLight = {},
    vehicle = false, vehicleVal = 100, vehicleConn = nil,
    -- Weapon
    infAmmo = false, rapid = false, reload = false, weaponConn = nil,
    -- Config
    configs = {},
    -- UI refs
    pages = {}, sideButtons = {}, allCards = {}, favClones = {},
    currentTab = "Movement",
    -- Remotes
    remotes = {},
}

-- ==================================================
-- ПРОВЕРКИ
-- ==================================================
pcall(function()
    if Drawing and Drawing.new then
        local t = Drawing.new("Square"); t:Remove(); S.hasDrawing = true
    end
end)
pcall(function()
    if writefile and readfile and isfile then S.hasFile = true end
end)
pcall(function()
    if hookfunction and getgc then S.hasHook = true end
end)
pcall(function()
    if filtergc then
        local ok, f = pcall(filtergc, "function", {Name = "castRay"}, true)
        S.hasFilterGC = ok and f ~= nil
    end
end)
pcall(function()
    if getconnections then S.hasGetConn = true end
end)

local camera = WS.CurrentCamera
while not camera do RS.RenderStepped:Wait(); camera = WS.CurrentCamera end
local defaultFOV = camera.FieldOfView

pcall(function()
    local GR = ReplicatedStorage:FindFirstChild("GunRemotes")
    if GR then
        S.remotes.shoot = GR:FindFirstChild("ShootEvent")
        S.remotes.taze = GR:FindFirstChild("PlayerTased")
    end
    local R = ReplicatedStorage:FindFirstChild("Remotes")
    if R then S.remotes.arrest = R:FindFirstChild("ArrestPlayer") end
    S.remotes.melee = ReplicatedStorage:FindFirstChild("meleeEvent")
end)

-- ==================================================
-- ЦВЕТА
-- ==================================================
local BG = Color3.fromRGB(16, 16, 18)
local BG2 = Color3.fromRGB(22, 22, 26)
local BG3 = Color3.fromRGB(30, 30, 35)
local SIDEBAR = Color3.fromRGB(14, 14, 16)
local ACCENT = Color3.fromRGB(0, 180, 255)
local TEXT = Color3.fromRGB(245, 245, 250)
local TEXT2 = Color3.fromRGB(130, 130, 135)
local BORDER = Color3.fromRGB(35, 35, 40)

-- ==================================================
-- ХЕЛПЕРЫ
-- ==================================================
local function isFriends(userId)
    if S.friendCache[userId] ~= nil then return S.friendCache[userId] end
    local ok, res = pcall(function() return LocalPlayer:IsFriendsWith(userId) end)
    S.friendCache[userId] = ok and res or false
    return S.friendCache[userId]
end

local function isHostile(Char)
    local ok, v = pcall(function() return Char:GetAttribute("Hostile") end)
    return ok and v == true
end
local function isTrespassing(Char)
    local ok, v = pcall(function() return Char:GetAttribute("Trespassing") end)
    return ok and v == true
end

-- ==================================================
-- WATCHDOG
-- ==================================================
local function startWatchdog()
    if S.watchdogConn then S.watchdogConn:Disconnect() end
    S.watchdogConn = RS.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        if S.walk and h.WalkSpeed ~= S.walkVal then h.WalkSpeed = S.walkVal end
        if S.jump then
            if h.UseJumpPower then
                if h.JumpPower ~= S.jumpVal then h.JumpPower = S.jumpVal end
            else
                local th = S.jumpVal / 7.5
                if math.abs(h.JumpHeight - th) > 0.1 then h.JumpHeight = th end
            end
        end
    end)
end

-- ==================================================
-- WEAPON HACKS
-- ==================================================
local function getTools()
    local t = {}
    local c = LocalPlayer.Character
    if c then for _, x in ipairs(c:GetChildren()) do if x:IsA("Tool") then table.insert(t, x) end end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, x in ipairs(bp:GetChildren()) do if x:IsA("Tool") then table.insert(t, x) end end end
    return t
end

local function applyWeapon(tool)
    if not tool or not tool:IsA("Tool") then return end
    local gs = tool:FindFirstChild("GunStates")
    if gs then
        pcall(function()
            local env = getsenv(gs)
            if env then
                if S.infAmmo then env.MaxAmmo = math.huge; env.StoredAmmo = math.huge end
                if S.rapid then env.FireRate = 0.0001; env.AutoFire = true end
                if S.reload then env.ReloadTime = 0.0001 end
            end
        end)
    end
    for _, o in ipairs(tool:GetDescendants()) do
        pcall(function()
            if o:IsA("NumberValue") then
                local n = o.Name:lower()
                if S.infAmmo and (n:find("ammo") or n:find("clip")) then o.Value = 9999 end
                if S.rapid and n:find("firerate") then o.Value = 0.0001 end
                if S.reload and n:find("reload") then o.Value = 0.0001 end
            end
        end)
    end
end

local function startWeapon()
    if S.weaponConn then S.weaponConn:Disconnect() end
    if not (S.infAmmo or S.rapid or S.reload) then return end
    local function applyAll()
        for _, t in ipairs(getTools()) do applyWeapon(t) end
    end
    applyAll()
    S.weaponConn = RS.Heartbeat:Connect(applyAll)
end

-- ==================================================
-- ITEM GIVER
-- ==================================================
local function getGun(name)
    if S.getting then return end
    S.getting = true
    local c = LocalPlayer.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if not (c and r) or c:FindFirstChild("ForceField") then S.getting = false return end
    if LocalPlayer.Backpack:FindFirstChild(name) or c:FindFirstChild(name) then S.getting = false return end
    local g
    for _, v in ipairs(WS:GetDescendants()) do
        if v.Name == "TouchGiver" and v:GetAttribute("ToolName") == name then
            g = v:FindFirstChildWhichIsA("BasePart"); break
        end
    end
    if not g then S.getting = false return end
    local ocf = g.CFrame
    local oChar = r.CFrame
    local ug = ocf - Vector3.new(0, 15.5, 0)
    g.CanTouch = true
    g.CFrame = ug
    c:PivotTo(ug + Vector3.new(0, 5, 0))
    task.wait(0.25)
    pcall(function() firetouchinterest(g, r, 0) end)
    task.wait(0.3)
    pcall(function() firetouchinterest(g, r, 1) end)
    task.wait(0.05)
    g.CFrame = ocf
    c:PivotTo(oChar)
    task.wait(0.1)
    S.getting = false
end

local function startAutoGun()
    if not S.autoGun then return end
    task.spawn(function()
        while S.autoGun do
            task.wait(1)
            for n, e in pairs(S.guns) do if e then getGun(n) end end
        end
    end)
end

-- ==================================================
-- ARREST / MELEE AURA
-- ==================================================
local function arrestable(P)
    if not P.Character then return false end
    local h = P.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if P.Team and P.Team.Name == "Criminals" then return true end
    local d = h.DisplayName
    return d:find("🔗", 1, true) or d:find("💢", 1, true)
end

local function startArrest()
    if S.arrestConn then S.arrestConn:Disconnect() end
    if not S.arrest or not S.remotes.arrest then return end
    S.arrestConn = RS.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _, P in ipairs(Players:GetPlayers()) do
            if P == LocalPlayer or not P.Character then continue end
            if S.arrestIgnoreFriends and isFriends(P.UserId) then continue end
            if arrestable(P) then
                local hr = P.Character:FindFirstChild("HumanoidRootPart")
                if hr and (r.Position - hr.Position).Magnitude <= S.arrestRange then
                    pcall(function() S.remotes.arrest:InvokeServer(P) end)
                end
            end
        end
    end)
end

local function startMelee()
    if S.meleeConn then S.meleeConn:Disconnect() end
    if not S.melee or not S.remotes.melee then return end
    S.meleeConn = RS.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _, P in ipairs(Players:GetPlayers()) do
            if P == LocalPlayer or not P.Character then continue end
            if S.meleeIgnoreFriends and isFriends(P.UserId) then continue end
            local hr = P.Character:FindFirstChild("HumanoidRootPart")
            local h = P.Character:FindFirstChildOfClass("Humanoid")
            if hr and h and h.Health > 0 and (r.Position - hr.Position).Magnitude <= S.meleeRange then
                pcall(function() S.remotes.melee:FireServer(P) end)
            end
        end
    end)
end

-- ==================================================
-- ANTI-TAZE
-- ==================================================
local function startAntiTaze()
    if not S.hasGetConn or not S.remotes.taze then return end
    if S.antiTaze then
        pcall(function()
            for _, conn in pairs(getconnections(S.remotes.taze.OnClientEvent)) do
                pcall(function() conn:Disable() table.insert(S.antiTazeConns, conn) end)
            end
        end)
    else
        for _, conn in ipairs(S.antiTazeConns) do pcall(function() conn:Enable() end) end
        S.antiTazeConns = {}
    end
end

-- ==================================================
-- SILENT AIM
-- ==================================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function visible(part, org)
    if not part then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local res = WS:Raycast(org, part.Position - org, rayParams)
    return (not res) or res.Instance:IsDescendantOf(part.Parent)
end

local function canAim(P)
    local C = P.Character
    if not C then return false end
    local H = C:FindFirstChildOfClass("Humanoid")
    if not H or H.Health <= 0 then return false end
    if S.aimIgnoreFF and C:FindFirstChild("ForceField") then return false end
    if S.aimIgnoreFriends and isFriends(P.UserId) then return false end
    if S.aimTeam and LocalPlayer.Team and P.Team == LocalPlayer.Team then return false end
    local t = P.Team and P.Team.Name or ""
    if S.aimIgnoreGuards and t == "Guards" then return false end
    if S.aimIgnoreCrims and t == "Criminals" then return false end
    if S.aimIgnoreInnocent and t == "Inmates" and not isHostile(C) and not isTrespassing(C) then return false end
    return true
end

local function closestTarget()
    local best, bd = nil, S.aimFOV
    local ctr = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local org = camera.CFrame.Position
    for _, P in ipairs(Players:GetPlayers()) do
        if P == LocalPlayer then continue end
        if not canAim(P) then continue end
        local C = P.Character
        local part = C:FindFirstChild(S.aimPart) or C:FindFirstChild("Head")
        if not part then continue end
        if (org - part.Position).Magnitude > S.aimRange then continue end
        local pos, on = camera:WorldToViewportPoint(part.Position)
        if not on then continue end
        if (part.Position - org):Dot(camera.CFrame.LookVector) <= 0 then continue end
        if S.aimWall and not visible(part, org) then continue end
        local d = (Vector2.new(pos.X, pos.Y) - ctr).Magnitude
        if d < bd then bd = d; best = P end
    end
    return best
end

local function didHit()
    return math.random(1, 100) <= S.aimChance
end

local function missOffset(pp, org)
    local d = (pp - org).Magnitude
    local sc = math.clamp(d / 3, 3, 4)
    return Vector3.new(
        math.random(-sc * 10, sc * 10) / 10,
        math.random(-sc * 10, sc * 10) / 10,
        math.random(-sc * 10, sc * 10) / 10
    )
end

local function installAim()
    if S.aimHooked or not S.hasHook then return end
    local cr
    if S.hasFilterGC then pcall(function() cr = filtergc("function", {Name = "castRay"}, true) end) end
    if not cr then
        pcall(function()
            for _, f in next, getgc(true) do
                if type(f) == "function" then
                    local i = debug.getinfo(f, "nS")
                    if i and i.name == "castRay" then cr = f; break end
                end
            end
        end)
    end
    if not cr then return end
    S.aimHooked = true
    pcall(function()
        S.oldCastRay = hookfunction(cr, function(...)
            local a = {...}
            if S.aim and S.currentTarget and S.currentTarget.Character then
                local p = S.currentTarget.Character:FindFirstChild(S.aimPart)
                if p then
                    if didHit() then
                        a[2] = p.Position
                    else
                        local mp = S.currentTarget.Character:FindFirstChild("LeftLeg") or S.currentTarget.Character:FindFirstChild("RightLeg")
                        if mp and typeof(a[1]) == "Vector3" then
                            a[2] = mp.Position + missOffset(mp.Position, a[1])
                        end
                    end
                end
            end
            return S.oldCastRay(table.unpack(a))
        end)
    end)
end

RS.Heartbeat:Connect(function()
    if S.aim then S.currentTarget = closestTarget() end
end)

-- ==================================================
-- SPIN
-- ==================================================
local function startSpin()
    if S.spinConn then S.spinConn:Disconnect() end
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not S.spin then
        if h and S.savedHum then
            h.AutoRotate = S.savedHum.AutoRotate
            h.CameraOffset = S.savedHum.CameraOffset
            S.savedHum = nil
        end
        return
    end
    if h then
        S.savedHum = {AutoRotate = h.AutoRotate, CameraOffset = h.CameraOffset}
        h.AutoRotate = false
    end
    S.spinConn = RS.Stepped:Connect(function(_, dt)
        local ch = LocalPlayer.Character
        if not ch then return end
        local hu = ch:FindFirstChildOfClass("Humanoid")
        local rp = ch:FindFirstChild("HumanoidRootPart")
        if not rp then return end
        if hu and hu.AutoRotate then hu.AutoRotate = false end
        rp.CFrame = rp.CFrame * CFrame.Angles(0, math.rad(S.spinVal), 0)
    end)
end

-- ==================================================
-- ESP
-- ==================================================
local function mkBox(t)
    if not S.hasDrawing or t == LocalPlayer or S.ESP_BOXES[t] then return end
    local b = Drawing.new("Square")
    b.Thickness = 1.5; b.Color = ACCENT; b.Filled = false; b.Visible = false; b.Transparency = 1
    S.ESP_BOXES[t] = b
end
local function rmBox(t) if S.ESP_BOXES[t] then pcall(function() S.ESP_BOXES[t]:Remove() end) end S.ESP_BOXES[t] = nil end

local function startBox()
    if S.espBoxConn then S.espBoxConn:Disconnect() end
    if not S.espBox or not S.hasDrawing then for t in pairs(S.ESP_BOXES) do rmBox(t) end return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then mkBox(p) end end
    S.espBoxConn = RS.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local b = S.ESP_BOXES[p]; if not b then mkBox(p) continue end
            local c = p.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            local hd = c and c:FindFirstChild("Head")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LocalPlayer.Team and p.Team == LocalPlayer.Team)
            if show and hr and hd and h and h.Health > 0 then
                local hs, ho = camera:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
                local fs, fo = camera:WorldToViewportPoint(hr.Position - Vector3.new(0, 3, 0))
                if ho and fo then
                    local hh = math.abs(hs.Y - fs.Y); local ww = hh / 2
                    b.Size = Vector2.new(ww, hh); b.Position = Vector2.new(hs.X - ww/2, hs.Y); b.Visible = true
                else b.Visible = false end
            else b.Visible = false end
        end
    end)
end

local function mkName(t)
    if not S.hasDrawing or t == LocalPlayer or S.ESP_NAMES[t] then return end
    local n = Drawing.new("Text")
    n.Size = 14; n.Center = true; n.Outline = true; n.Color = Color3.fromRGB(255,255,255)
    n.OutlineColor = Color3.fromRGB(0,0,0); n.Visible = false; n.Font = 2; n.Text = t.Name
    S.ESP_NAMES[t] = n
end
local function rmName(t) if S.ESP_NAMES[t] then pcall(function() S.ESP_NAMES[t]:Remove() end) end S.ESP_NAMES[t] = nil end

local function startName()
    if S.espNameConn then S.espNameConn:Disconnect() end
    if not S.espName or not S.hasDrawing then for t in pairs(S.ESP_NAMES) do rmName(t) end return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then mkName(p) end end
    S.espNameConn = RS.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local n = S.ESP_NAMES[p]; if not n then mkName(p) continue end
            local c = p.Character
            local hd = c and c:FindFirstChild("Head")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LocalPlayer.Team and p.Team == LocalPlayer.Team)
            if show and hd and h and h.Health > 0 then
                local hs, ho = camera:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
                if ho then
                    n.Position = Vector2.new(hs.X, hs.Y - 18)
                    n.Text = string.format("%s [%d]", p.Name, math.floor(h.Health))
                    n.Visible = true
                else n.Visible = false end
            else n.Visible = false end
        end
    end)
end

local function mkLine(t)
    if not S.hasDrawing or t == LocalPlayer or S.ESP_LINES[t] then return end
    local l = Drawing.new("Line")
    l.Thickness = 1; l.Color = Color3.fromRGB(170, 100, 255); l.Visible = false
    S.ESP_LINES[t] = l
end
local function rmLine(t) if S.ESP_LINES[t] then pcall(function() S.ESP_LINES[t]:Remove() end) end S.ESP_LINES[t] = nil end

local function startLine()
    if S.espLineConn then S.espLineConn:Disconnect() end
    if not S.espLine or not S.hasDrawing then for t in pairs(S.ESP_LINES) do rmLine(t) end return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then mkLine(p) end end
    S.espLineConn = RS.RenderStepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local l = S.ESP_LINES[p]; if not l then mkLine(p) continue end
            local c = p.Character
            local hd = c and c:FindFirstChild("Head")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LocalPlayer.Team and p.Team == LocalPlayer.Team)
            if show and hd and h and h.Health > 0 then
                local hs, ho = camera:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
                if ho then
                    l.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    l.To = Vector2.new(hs.X, hs.Y); l.Visible = true
                else l.Visible = false end
            else l.Visible = false end
        end
    end)
end

-- ==================================================
-- SPIDER
-- ==================================================
local function startSpider()
    if S.spiderConn then S.spiderConn:Disconnect() end
    if not S.spider then S.wallHit = false return end
    S.spiderConn = RS.PreRender:Connect(function()
        local c = LocalPlayer.Character
        if not c then S.wallHit = false return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not rp or not h or h.Health <= 0 then S.wallHit = false return end
        if h.MoveDirection.Magnitude <= 0.1 then S.wallHit = false return end
        local rp2 = RaycastParams.new()
        rp2.FilterDescendantsInstances = {c}; rp2.FilterType = Enum.RaycastFilterType.Exclude
        local dir = rp.CFrame.LookVector * 2.5
        local hit = WS:Raycast(rp.Position, dir, rp2) or WS:Raycast(rp.Position - rp.CFrame.RightVector * 1.1, dir, rp2) or WS:Raycast(rp.Position + rp.CFrame.RightVector * 1.1, dir, rp2)
        if hit then
            rp.CFrame = rp.CFrame + Vector3.new(0, S.climbSpd, 0) + (rp.CFrame.LookVector * 0.05)
            if rp.AssemblyLinearVelocity.Y < 0 then rp.AssemblyLinearVelocity = Vector3.new(rp.AssemblyLinearVelocity.X, 2, rp.AssemblyLinearVelocity.Z) end
            S.wallHit = true
        else
            if S.wallHit then
                S.wallHit = false
                local fwd = rp.CFrame.LookVector
                rp.AssemblyLinearVelocity = Vector3.new(fwd.X * S.boost * 0.68, S.boost, fwd.Z * S.boost * 0.68)
                rp.CFrame = rp.CFrame + Vector3.new(0, 1.5, 0) + (fwd * 0.5)
            end
        end
    end)
end

-- ==================================================
-- AUTO KEYCARD
-- ==================================================
local function hasKeycard()
    local c = LocalPlayer.Character
    if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("keycard") then return true end end end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("keycard") then return true end end end
    return false
end

local function isCriminal()
    local n = LocalPlayer.Team and LocalPlayer.Team.Name or ""
    local l = n:lower()
    return l:find("prisoner") or l:find("inmate") or l:find("criminal") or l:find("convict")
end

local function startKeycard()
    if S.keycardConn then S.keycardConn:Disconnect() end
    if not S.keycard then return end
    S.keycardConn = RS.Heartbeat:Connect(function()
        if not isCriminal() or hasKeycard() then return end
        local c = LocalPlayer.Character
        local rp = c and c:FindFirstChild("HumanoidRootPart")
        if not rp then return end
        for _, o in ipairs(WS:GetDescendants()) do
            if o:IsA("Tool") or o:IsA("BasePart") or o:IsA("Model") then
                local n = o.Name:lower()
                if n:find("keycard") or n:find("key card") or n:find("key_card") then
                    local p = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position - rp.Position).Magnitude < S.keycardRange then
                        rp.CFrame = CFrame.new(p.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end)
end

-- ==================================================
-- HITBOX
-- ==================================================
local function hbParts(c)
    if not c then return {} end
    local t = {}
    for _, n in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "Torso"}) do
        local p = c:FindFirstChild(n); if p then table.insert(t, p) end
    end
    return t
end

local function hbApply(P)
    local c = P.Character; if not c then return end
    for _, p in ipairs(hbParts(c)) do
        if not S.savedHB[p] then
            S.savedHB[p] = {Size = p.Size, Transparency = p.Transparency, CanCollide = p.CanCollide, Material = p.Material, Color = p.Color}
        end
        p.Size = S.savedHB[p].Size * S.hbSize
        p.CanCollide = false
        if S.hbVisual then p.Transparency = 0.5; p.Material = Enum.Material.Neon; p.Color = Color3.fromRGB(255, 100, 100) end
    end
end

local function hbRemove(P)
    local c = P.Character; if not c then return end
    for _, p in ipairs(hbParts(c)) do
        local sv = S.savedHB[p]
        if sv then
            p.Size = sv.Size; p.Transparency = sv.Transparency; p.CanCollide = sv.CanCollide
            p.Material = sv.Material; p.Color = sv.Color; S.savedHB[p] = nil
        end
    end
end

local function hbShould(P)
    local C = P.Character
    if not C then return false end
    local H = C:FindFirstChildOfClass("Humanoid")
    if not H or H.Health <= 0 then return false end
    if S.hbIgnoreFriends and isFriends(P.UserId) then return false end
    if S.hbTeam and LocalPlayer.Team and P.Team == LocalPlayer.Team then return false end
    local t = P.Team and P.Team.Name or ""
    if S.hbIgnoreGuards and t == "Guards" then return false end
    if S.hbIgnoreCrims and t == "Criminals" then return false end
    if S.hbIgnoreInnocent and t == "Inmates" and not isHostile(C) and not isTrespassing(C) then return false end
    return true
end

local function hbVisualUpdate(P)
    local c = P.Character
    if not c or not c.Parent then return end
    if S.hb and hbShould(P) then
        if not c:FindFirstChild("HitboxHighlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "HitboxHighlight"; hl.FillColor = Color3.fromRGB(255, 80, 80); hl.FillTransparency = 0.7
            hl.OutlineColor = Color3.fromRGB(255, 150, 150); hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = c
        end
    else
        local ex = c:FindFirstChild("HitboxHighlight"); if ex then ex:Destroy() end
    end
end

local function startHB()
    if S.hbConn then S.hbConn:Disconnect() end
    if not S.hb then
        for _, p in ipairs(Players:GetPlayers()) do
            hbRemove(p)
            local c = p.Character; if c and c:FindFirstChild("HitboxHighlight") then c.HitboxHighlight:Destroy() end
        end
        S.savedHB = {}
        return
    end
    S.hbConn = RS.Heartbeat:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if hbShould(p) then hbApply(p) else hbRemove(p) end
            hbVisualUpdate(p)
        end
    end)
end

-- ==================================================
-- FOV / FULLBRIGHT / VEHICLE
-- ==================================================
local function startFOV()
    if S.fovConn then S.fovConn:Disconnect() end
    if not S.fov then
        if WS.CurrentCamera then WS.CurrentCamera.FieldOfView = defaultFOV end
        return
    end
    if WS.CurrentCamera then WS.CurrentCamera.FieldOfView = S.fovVal end
    S.fovConn = RS.Heartbeat:Connect(function()
        if not S.fov then return end
        if WS.CurrentCamera and WS.CurrentCamera.FieldOfView ~= S.fovVal then
            WS.CurrentCamera.FieldOfView = S.fovVal
        end
    end)
end

local function startFB()
    if S.fullbrightConn then S.fullbrightConn:Disconnect() end
    if not S.fullbright then
        for k, v in pairs(S.savedLight) do pcall(function() Lighting[k] = v end) end
        S.savedLight = {}
        return
    end
    S.savedLight = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows,
    }
    S.fullbrightConn = RS.Heartbeat:Connect(function()
        if not S.fullbright then return end
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3; Lighting.ClockTime = 14
        Lighting.FogEnd = 100000; Lighting.FogStart = 100000; Lighting.GlobalShadows = false
    end)
end

local function startVehicle()
    if S.vehicleConn then S.vehicleConn:Disconnect() end
    if not S.vehicle then return end
    S.vehicleConn = RS.Heartbeat:Connect(function()
        local c = LocalPlayer.Character; if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
        local seat = h.SeatPart
        if seat then
            local v = seat:FindFirstAncestorOfClass("Model") or seat.Parent
            if v then
                for _, o in ipairs(v:GetDescendants()) do
                    if o:IsA("VehicleSeat") or o:IsA("Seat") then
                        pcall(function() o.MaxSpeed = S.vehicleVal; o.Torque = S.vehicleVal * 100 end)
                    end
                end
            end
        end
    end)
end

-- ==================================================
-- CONFIG
-- ==================================================
local function getCfg()
    return {
        walk = S.walk, walkVal = S.walkVal, jump = S.jump, jumpVal = S.jumpVal,
        infJump = S.infJump, spin = S.spin, spinVal = S.spinVal,
        espTeam = S.espTeam, espBox = S.espBox, espName = S.espName, espLine = S.espLine,
        spider = S.spider, climbSpd = S.climbSpd, boost = S.boost,
        antiTaze = S.antiTaze, keycard = S.keycard, keycardRange = S.keycardRange,
        autoGun = S.autoGun, guns = S.guns,
        aim = S.aim, aimTeam = S.aimTeam, aimWall = S.aimWall, aimFOV = S.aimFOV,
        aimRange = S.aimRange, aimPart = S.aimPart, aimChance = S.aimChance,
        aimIgnoreFriends = S.aimIgnoreFriends, aimIgnoreGuards = S.aimIgnoreGuards,
        aimIgnoreCrims = S.aimIgnoreCrims, aimIgnoreInnocent = S.aimIgnoreInnocent,
        aimIgnoreFF = S.aimIgnoreFF,
        hb = S.hb, hbSize = S.hbSize, hbVisual = S.hbVisual, hbTeam = S.hbTeam,
        hbIgnoreFriends = S.hbIgnoreFriends, hbIgnoreGuards = S.hbIgnoreGuards,
        hbIgnoreCrims = S.hbIgnoreCrims, hbIgnoreInnocent = S.hbIgnoreInnocent,
        arrest = S.arrest, arrestRange = S.arrestRange, arrestIgnoreFriends = S.arrestIgnoreFriends,
        melee = S.melee, meleeRange = S.meleeRange, meleeIgnoreFriends = S.meleeIgnoreFriends,
        fov = S.fov, fovVal = S.fovVal, fullbright = S.fullbright,
        vehicle = S.vehicle, vehicleVal = S.vehicleVal,
        infAmmo = S.infAmmo, rapid = S.rapid, reload = S.reload,
    }
end

local function applyCfg(d)
    if not d then return end
    S.walk = d.walk or false; S.walkVal = d.walkVal or 16
    S.jump = d.jump or false; S.jumpVal = d.jumpVal or 50
    S.infJump = d.infJump or false; S.spin = d.spin or false; S.spinVal = d.spinVal or 10
    S.espTeam = d.espTeam ~= false; S.espBox = d.espBox or false; S.espName = d.espName or false; S.espLine = d.espLine or false
    S.spider = d.spider or false; S.climbSpd = d.climbSpd or 0.28; S.boost = d.boost or 22
    S.antiTaze = d.antiTaze or false; S.keycard = d.keycard or false; S.keycardRange = d.keycardRange or 20
    S.autoGun = d.autoGun or false; S.guns = d.guns or S.guns
    S.aim = d.aim or false; S.aimTeam = d.aimTeam ~= false; S.aimWall = d.aimWall ~= false
    S.aimFOV = d.aimFOV or 100; S.aimRange = d.aimRange or 300; S.aimPart = d.aimPart or "Head"; S.aimChance = d.aimChance or 100
    S.aimIgnoreFriends = d.aimIgnoreFriends or false; S.aimIgnoreGuards = d.aimIgnoreGuards or false
    S.aimIgnoreCrims = d.aimIgnoreCrims or false; S.aimIgnoreInnocent = d.aimIgnoreInnocent or false; S.aimIgnoreFF = d.aimIgnoreFF or false
    S.hb = d.hb or false; S.hbSize = d.hbSize or 3; S.hbVisual = d.hbVisual ~= false
    S.hbTeam = d.hbTeam or false; S.hbIgnoreFriends = d.hbIgnoreFriends or false
    S.hbIgnoreGuards = d.hbIgnoreGuards or false; S.hbIgnoreCrims = d.hbIgnoreCrims or false; S.hbIgnoreInnocent = d.hbIgnoreInnocent or false
    S.arrest = d.arrest or false; S.arrestRange = d.arrestRange or 7.5; S.arrestIgnoreFriends = d.arrestIgnoreFriends or false
    S.melee = d.melee or false; S.meleeRange = d.meleeRange or 4; S.meleeIgnoreFriends = d.meleeIgnoreFriends or false
    S.fov = d.fov or false; S.fovVal = d.fovVal or 70; S.fullbright = d.fullbright or false
    S.vehicle = d.vehicle or false; S.vehicleVal = d.vehicleVal or 100
    S.infAmmo = d.infAmmo or false; S.rapid = d.rapid or false; S.reload = d.reload or false

    startSpin(); startSpider(); startBox(); startName(); startLine()
    startAntiTaze(); startKeycard(); startHB(); startArrest(); startMelee(); startAutoGun()
    startFOV(); startFB(); startVehicle(); startWeapon()
    if S.aim then installAim() end
end

local function saveCfg()
    if not S.hasFile then return end
    pcall(function() writefile("AuraHub_Settings.json", HttpService:JSONEncode(getCfg())) end)
    pcall(function() writefile("AuraHub_Configs.json", HttpService:JSONEncode(S.configs)) end)
end

local function loadCfg()
    if not S.hasFile then return end
    if isfile("AuraHub_Settings.json") then
        pcall(function() applyCfg(HttpService:JSONDecode(readfile("AuraHub_Settings.json"))) end)
    end
    if isfile("AuraHub_Configs.json") then
        pcall(function() S.configs = HttpService:JSONDecode(readfile("AuraHub_Configs.json")) end)
    end
end

-- ==================================================
-- UI
-- ==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlphaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PG

local MainFrame = Instance.new("Frame")
MainFrame.Name = "AlphaHubMain"
MainFrame.Size = UDim2.new(0, 680, 0, 410)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -205)
MainFrame.BackgroundColor3 = BG; MainFrame.BorderSizePixel = 0; MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 8); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = BORDER; MainStroke.Thickness = 1.2; MainStroke.Parent = MainFrame

local drag, dStart, sPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        MainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 75, 1, 0); Sidebar.BackgroundColor3 = SIDEBAR; Sidebar.BorderSizePixel = 0; Sidebar.ZIndex = 6; Sidebar.Parent = MainFrame
local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(0, 8); SC.Parent = Sidebar
local SCover = Instance.new("Frame"); SCover.Size = UDim2.new(0, 15, 1, 0); SCover.Position = UDim2.new(1, -15, 0, 0)
SCover.BackgroundColor3 = SIDEBAR; SCover.BorderSizePixel = 0; SCover.ZIndex = 6; SCover.Parent = Sidebar

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -10, 0, 45); HeaderTitle.Position = UDim2.new(0, 5, 0, 10)
HeaderTitle.BackgroundTransparency = 1; HeaderTitle.Text = "Alpha Hub"; HeaderTitle.TextColor3 = TEXT
HeaderTitle.Font = Enum.Font.GothamBold; HeaderTitle.TextSize = 12; HeaderTitle.TextWrapped = true
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center; HeaderTitle.ZIndex = 7; HeaderTitle.Parent = Sidebar

local SideBtnFrame = Instance.new("ScrollingFrame")
SideBtnFrame.Size = UDim2.new(1, 0, 1, -60); SideBtnFrame.Position = UDim2.new(0, 0, 0, 55)
SideBtnFrame.BackgroundTransparency = 1; SideBtnFrame.ScrollBarThickness = 0; SideBtnFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
SideBtnFrame.ZIndex = 7; SideBtnFrame.Parent = Sidebar
local SL = Instance.new("UIListLayout"); SL.Padding = UDim.new(0, 6); SL.HorizontalAlignment = Enum.HorizontalAlignment.Center; SL.Parent = SideBtnFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -38, 0, 12); CloseBtn.BackgroundColor3 = BG2
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = TEXT; CloseBtn.TextSize = 12; CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 20; CloseBtn.Parent = MainFrame
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 6); CC.Parent = CloseBtn
local CS = Instance.new("UIStroke"); CS.Color = BORDER; CS.Thickness = 1; CS.Parent = CloseBtn

local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(0, 200, 0, 28); TopLabel.Position = UDim2.new(0, 95, 0, 12)
TopLabel.BackgroundTransparency = 1; TopLabel.Text = "Movement"; TopLabel.TextColor3 = TEXT
TopLabel.Font = Enum.Font.GothamBold; TopLabel.TextSize = 15; TopLabel.TextXAlignment = Enum.TextXAlignment.Left
TopLabel.ZIndex = 6; TopLabel.Parent = MainFrame

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -105, 1, -60); PagesContainer.Position = UDim2.new(0, 95, 0, 48)
PagesContainer.BackgroundTransparency = 1; PagesContainer.ZIndex = 6; PagesContainer.Parent = MainFrame

local Tooltip = Instance.new("Frame")
Tooltip.Size = UDim2.new(0, 90, 0, 22); Tooltip.BackgroundColor3 = Color3.fromRGB(24, 24, 28); Tooltip.BorderSizePixel = 0
Tooltip.ZIndex = 30; Tooltip.Visible = false; Tooltip.Parent = ScreenGui
Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 4)
local TStroke = Instance.new("UIStroke"); TStroke.Color = BORDER; TStroke.Parent = Tooltip
local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, 0, 1, 0); TooltipText.BackgroundTransparency = 1; TooltipText.TextColor3 = TEXT
TooltipText.TextSize = 10; TooltipText.Font = Enum.Font.GothamSemibold; TooltipText.ZIndex = 30; TooltipText.Parent = Tooltip

local Tablet = Instance.new("Frame")
Tablet.Size = UDim2.new(0, 140, 0, 36); Tablet.Position = UDim2.new(0.5, -70, 0, 15); Tablet.BackgroundColor3 = Color3.fromRGB(0,0,0)
Tablet.BackgroundTransparency = 0.3; Tablet.ZIndex = 25; Tablet.Visible = false; Tablet.Parent = ScreenGui
Instance.new("UICorner", Tablet).CornerRadius = UDim.new(0, 18)
local TabStroke = Instance.new("UIStroke"); TabStroke.Color = Color3.fromRGB(80, 80, 80); TabStroke.Parent = Tablet
local TabIcon = Instance.new("TextLabel")
TabIcon.Size = UDim2.new(0, 24, 1, 0); TabIcon.Position = UDim2.new(0, 12, 0, 0); TabIcon.BackgroundTransparency = 1
TabIcon.Text = "⌇"; TabIcon.TextColor3 = TEXT; TabIcon.TextSize = 16; TabIcon.Font = Enum.Font.GothamBold
TabIcon.ZIndex = 25; TabIcon.Parent = Tablet
local TabText = Instance.new("TextLabel")
TabText.Size = UDim2.new(1, -45, 1, 0); TabText.Position = UDim2.new(0, 36, 0, 0); TabText.BackgroundTransparency = 1
TabText.Text = "Alpha Hub"; TabText.TextColor3 = TEXT; TabText.TextSize = 13; TabText.Font = Enum.Font.GothamBold
TabText.TextXAlignment = Enum.TextXAlignment.Left; TabText.ZIndex = 25; TabText.Parent = Tablet
local TabClick = Instance.new("TextButton")
TabClick.Size = UDim2.new(1, 0, 1, 0); TabClick.BackgroundTransparency = 1; TabClick.Text = ""
TabClick.ZIndex = 26; TabClick.Parent = Tablet

local tDrag, tStart, tSPos
TabClick.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        tDrag = true; tStart = i.Position; tSPos = Tablet.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if tDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tStart
        Tablet.Position = UDim2.new(tSPos.X.Scale, tSPos.X.Offset + d.X, tSPos.Y.Scale, tSPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if tDrag then
            tDrag = false
            local d = i.Position - tStart
            if d.Magnitude < 5 then Tablet.Visible = false; MainFrame.Visible = true end
        end
    end
end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; Tablet.Visible = true end)

local function arrangeGrid(pd)
    if not pd or not pd.Cards or not pd.Frame then return end
    local cards = {}
    for _, c in ipairs(pd.Cards) do if c and c.Parent == pd.Frame then table.insert(cards, c) end end
    local cw, px, py, sx, sy = 180, 10, 10, 5, 5
    local cols = {0, 0, 0}
    for _, cf in ipairs(cards) do
        local mc, mh = 1, cols[1]
        for c = 2, 3 do if cols[c] < mh then mh = cols[c]; mc = c end end
        cf.Position = UDim2.new(0, sx + (mc - 1) * (cw + px), 0, sy + mh)
        cols[mc] = mh + cf.AbsoluteSize.Y + py
    end
    local mh = cols[1]
    for c = 2, 3 do if cols[c] > mh then mh = cols[c] end end
    pd.Frame.CanvasSize = UDim2.new(0, 0, 0, sy + mh + 20)
end

local function updateVis()
    TopLabel.Text = S.currentTab
    for n, pd in pairs(S.pages) do
        if pd and pd.Frame then
            pd.Frame.Visible = (n == S.currentTab)
            if n == S.currentTab then
                for _, c in ipairs(pd.Cards) do if c then c.Visible = true end end
                arrangeGrid(pd)
            end
        end
    end
    for n, b in pairs(S.sideButtons) do
        local im = b:FindFirstChildOfClass("ImageLabel")
        local st = b:FindFirstChildOfClass("UIStroke")
        if n == S.currentTab then
            b.BackgroundColor3 = BG3
            if st then st.Color = ACCENT end
            if im then im.ImageColor3 = ACCENT end
        else
            b.BackgroundColor3 = BG2
            if st then st.Color = BORDER end
            if im then im.ImageColor3 = TEXT2 end
        end
    end
end

local icons = {
    ["Movement"] = "rbxassetid://10723345709",
    ["Player"] = "rbxassetid://10723395906",
    ["Combat"] = "rbxassetid://10723345709",
    ["Prison Life"] = "rbxassetid://10734950349",
    ["Favorite"] = "rbxassetid://10723345709",
    ["Config"] = "rbxassetid://10723345709",
    ["Players"] = "rbxassetid://10734963570",
    ["Settings"] = "rbxassetid://10723345709",
}

local function mkPage(name)
    local pf = Instance.new("ScrollingFrame")
    pf.Size = UDim2.new(1, 0, 1, 0); pf.BackgroundTransparency = 1; pf.ScrollBarThickness = 4
    pf.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50); pf.Visible = false; pf.ZIndex = 6; pf.Parent = PagesContainer
    S.pages[name] = {Frame = pf, Cards = {}}
    return S.pages[name]
end

local function syncFav()
    local fp = S.pages["Favorite"]
    if not fp then return end
    for _, cf in ipairs(S.favClones) do cf:Destroy() end
    S.favClones = {}
    fp.Cards = {}
    for _, ci in ipairs(S.allCards) do
        if ci.starActive then
            local cl = ci.frame:Clone()
            cl.Visible = true; cl.Parent = fp.Frame
            local h = cl:FindFirstChild("HeaderFrame")
            if h then
                local sc = h:FindFirstChild("StarContainer")
                if sc then
                    local sb = sc:FindFirstChild("StarButton")
                    if sb then
                        sb.MouseButton1Click:Connect(function()
                            ci.starActive = false; ci.refreshStarUI(); syncFav()
                            local op = S.pages[ci.origPage]; if op then arrangeGrid(op) end
                        end)
                    end
                end
                local cb = h:FindFirstChild("CollapseButton")
                if cb then
                    local ct = cl:FindFirstChild("ContentContainer")
                    cb.MouseButton1Click:Connect(function()
                        ci.isCollapsed = not ci.isCollapsed
                        if ci.isCollapsed then
                            if ct then ct.Visible = false; ct.Active = false end
                            cl.Size = UDim2.new(0, 180, 0, 36); cb.Text = "▼"
                        else
                            cl.Size = UDim2.new(0, 180, 0, 165)
                            if ct then ct.Visible = true; ct.Active = true end
                            cb.Text = "▲"
                        end
                        arrangeGrid(fp)
                    end)
                end
            end
            table.insert(fp.Cards, cl); table.insert(S.favClones, cl)
        end
    end
    if S.currentTab == "Favorite" then arrangeGrid(fp) end
end

local function mkCard(pd, title, origTab)
    local cf = Instance.new("Frame")
    cf.Name = title .. "Card"
    cf.Size = UDim2.new(0, 180, 0, 165)
    cf.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    cf.BorderSizePixel = 0; cf.ClipsDescendants = true; cf.ZIndex = 7; cf.Parent = pd.Frame
    table.insert(pd.Cards, cf)
    local cr = {frame = cf, name = title, origPage = origTab, currentHome = pd,
        dropdowns = {}, sliders = {}, toggles = {}, starActive = false, isCollapsed = false}
    table.insert(S.allCards, cr)
    Instance.new("UICorner", cf).CornerRadius = UDim.new(0, 6)
    local cstr = Instance.new("UIStroke"); cstr.Thickness = 1; cstr.Color = Color3.fromRGB(30, 30, 35)
    cstr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; cstr.Parent = cf

    local hf = Instance.new("Frame"); hf.Name = "HeaderFrame"
    hf.Size = UDim2.new(1, 0, 0, 36); hf.BackgroundTransparency = 1; hf.ZIndex = 7; hf.Parent = cf

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -75, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0); tl.BackgroundTransparency = 1
    tl.Text = title; tl.TextColor3 = Color3.fromRGB(245, 245, 250); tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10; tl.TextWrapped = true; tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 7; tl.Parent = hf

    local sc = Instance.new("Frame")
    sc.Name = "StarContainer"; sc.Size = UDim2.new(0, 16, 0, 16); sc.Position = UDim2.new(1, -64, 0, 10)
    sc.BackgroundColor3 = Color3.fromRGB(24, 24, 28); sc.BorderSizePixel = 0; sc.ZIndex = 7; sc.Parent = hf
    Instance.new("UICorner", sc).CornerRadius = UDim.new(0, 4)
    local ss = Instance.new("UIStroke"); ss.Thickness = 1; ss.Color = Color3.fromRGB(45, 45, 50); ss.Parent = sc
    local sb = Instance.new("TextButton")
    sb.Name = "StarButton"; sb.Size = UDim2.new(1, 0, 1, 0); sb.BackgroundTransparency = 1
    sb.Text = "★"; sb.Font = Enum.Font.GothamBold; sb.TextSize = 10; sb.TextColor3 = Color3.fromRGB(80, 80, 85)
    sb.ZIndex = 8; sb.Parent = sc

    local ts = Instance.new("TextButton")
    ts.Name = "ToggleSlider"; ts.Size = UDim2.new(0, 24, 0, 14); ts.Position = UDim2.new(1, -44, 0, 11)
    ts.BackgroundColor3 = Color3.fromRGB(30, 30, 35); ts.Text = ""; ts.AutoButtonColor = false
    ts.ZIndex = 8; ts.Parent = hf
    Instance.new("UICorner", ts).CornerRadius = UDim.new(1, 0)
    local tst = Instance.new("UIStroke"); tst.Thickness = 1; tst.Color = Color3.fromRGB(45, 45, 50); tst.Parent = ts
    local tc = Instance.new("Frame")
    tc.Name = "Circle"; tc.Size = UDim2.new(0, 8, 0, 8); tc.Position = UDim2.new(0, 2, 0.5, -4)
    tc.BackgroundColor3 = Color3.fromRGB(130, 130, 135); tc.BorderSizePixel = 0; tc.ZIndex = 8; tc.Parent = ts
    Instance.new("UICorner", tc).CornerRadius = UDim.new(1, 0)

    local cb = Instance.new("TextButton")
    cb.Name = "CollapseButton"; cb.Size = UDim2.new(0, 18, 0, 18); cb.Position = UDim2.new(1, -18, 0, 9)
    cb.BackgroundTransparency = 1; cb.Text = "▲"; cb.Font = Enum.Font.GothamBold
    cb.TextSize = 8; cb.TextColor3 = Color3.fromRGB(200, 200, 205); cb.ZIndex = 8; cb.Parent = hf

    local cc = Instance.new("Frame")
    cc.Name = "ContentContainer"; cc.Size = UDim2.new(1, -20, 1, -44); cc.Position = UDim2.new(0, 10, 0, 38)
    cc.BackgroundTransparency = 1; cc.ZIndex = 7; cc.Parent = cf
    local ll = Instance.new("UIListLayout"); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0, 6); ll.Parent = cc

    local function refreshStar()
        if cr.starActive then
            sb.TextColor3 = Color3.fromRGB(255, 255, 255); ss.Color = Color3.fromRGB(255, 255, 255)
        else
            sb.TextColor3 = Color3.fromRGB(80, 80, 85); ss.Color = Color3.fromRGB(45, 45, 50)
        end
    end
    cr.refreshStarUI = refreshStar
    sb.MouseButton1Click:Connect(function()
        cr.starActive = not cr.starActive; refreshStar(); syncFav()
    end)

    local function setCollapse(c)
        cr.isCollapsed = c
        if c then
            cc.Visible = false; cc.Active = false
            cf.Size = UDim2.new(0, 180, 0, 36); cb.Text = "▼"
        else
            cf.Size = UDim2.new(0, 180, 0, 165); cc.Visible = true; cc.Active = true
            cb.Text = "▲"
        end
    end

    cb.MouseButton1Click:Connect(function()
        cr.isCollapsed = not cr.isCollapsed
        cc.Visible = false; cc.Active = false
        cf.Size = UDim2.new(0, 180, 0, cr.isCollapsed and 36 or 165)
        if not cr.isCollapsed then cc.Visible = true; cc.Active = true; cb.Text = "▲" else cb.Text = "▼" end
        arrangeGrid(cr.currentHome)
    end)

    local active = false
    local toggleCb = nil
    local function setToggle(a)
        active = a
        if active then
            ts.BackgroundColor3 = Color3.fromRGB(240, 240, 245); tst.Color = Color3.fromRGB(255, 255, 255)
            tc.Position = UDim2.new(1, -10, 0.5, -4); tc.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        else
            ts.BackgroundColor3 = Color3.fromRGB(30, 30, 35); tst.Color = Color3.fromRGB(45, 45, 50)
            tc.Position = UDim2.new(0, 2, 0.5, -4); tc.BackgroundColor3 = Color3.fromRGB(130, 130, 135)
        end
        if toggleCb then pcall(toggleCb, active) end
    end
    ts.MouseButton1Click:Connect(function() setToggle(not active) end)

    local ex = {}
    function ex:SetToggleCallback(f) toggleCb = f end
    cr.setToggleState = setToggle

    function ex:AddDropdown(id, text, options, default, callback)
        local df = Instance.new("Frame"); df.Size = UDim2.new(1, 0, 0, 32)
        df.BackgroundTransparency = 1; df.ZIndex = 9; df.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 10); l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = Color3.fromRGB(130, 130, 135); l.Font = Enum.Font.GothamMedium; l.TextSize = 9
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 9; l.Parent = df
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 18); b.Position = UDim2.new(0, 0, 0, 14); b.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        b.Font = Enum.Font.GothamMedium; b.Text = " " .. default; b.TextColor3 = Color3.fromRGB(210, 210, 215)
        b.TextSize = 10; b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
        b.ZIndex = 10; b.Parent = df
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        local ar = Instance.new("TextLabel")
        ar.Size = UDim2.new(0, 16, 1, 0); ar.Position = UDim2.new(1, -16, 0, 0); ar.BackgroundTransparency = 1
        ar.Text = "▼"; ar.TextColor3 = Color3.fromRGB(100, 100, 105); ar.TextSize = 6; ar.ZIndex = 10; ar.Parent = b
        local lf = Instance.new("Frame")
        lf.Name = "ListFrame"; lf.Size = UDim2.new(1, 0, 0, 0); lf.Position = UDim2.new(0, 0, 1, 2)
        lf.BackgroundColor3 = Color3.fromRGB(20, 20, 24); lf.BorderSizePixel = 0; lf.ClipsDescendants = true
        lf.ZIndex = 15; lf.Parent = b
        Instance.new("UICorner", lf).CornerRadius = UDim.new(0, 4)
        local ls = Instance.new("UIStroke"); ls.Thickness = 1; ls.Color = Color3.fromRGB(40, 40, 45); ls.Parent = lf
        local dll = Instance.new("UIListLayout"); dll.SortOrder = Enum.SortOrder.LayoutOrder; dll.Parent = lf
        local cval = default
        local open = false
        local function toggle()
            open = not open
            if open then
                cf.ClipsDescendants = false; ar.Text = "▲"
                lf.Size = UDim2.new(1, 0, 0, #options * 16)
            else
                ar.Text = "▼"; lf.Size = UDim2.new(1, 0, 0, 0); cf.ClipsDescendants = true
            end
        end
        b.MouseButton1Click:Connect(toggle)
        local function populate(items)
            for _, ch in pairs(lf:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            if type(items) == "table" then
                for _, opt in ipairs(items) do
                    local ob = Instance.new("TextButton")
                    ob.Size = UDim2.new(1, 0, 0, 16); ob.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
                    ob.BackgroundTransparency = 1; ob.Font = Enum.Font.GothamMedium; ob.Text = " " .. opt
                    ob.TextColor3 = Color3.fromRGB(180, 180, 185); ob.TextSize = 9
                    ob.TextXAlignment = Enum.TextXAlignment.Left; ob.BorderSizePixel = 0; ob.ZIndex = 16; ob.Parent = lf
                    ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0; ob.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end)
                    ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
                    ob.MouseButton1Click:Connect(function()
                        cval = opt; b.Text = " " .. opt; toggle(); pcall(callback, opt)
                    end)
                end
            end
        end
        populate(options)
        cr.dropdowns[id] = {
            Set = function(v) cval = v; b.Text = " " .. v; pcall(callback, v) end,
            Get = function() return cval end,
            Refresh = function(items) populate(items) end
        }
        return cr.dropdowns[id]
    end

    local activeSliderID = nil
    function ex:AddSlider(id, text, mn, mx, df, callback)
        local sf = Instance.new("Frame"); sf.Size = UDim2.new(1, 0, 0, 26)
        sf.BackgroundTransparency = 1; sf.ZIndex = 8; sf.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 0, 10); l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = Color3.fromRGB(130, 130, 135); l.Font = Enum.Font.GothamMedium; l.TextSize = 9
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 8; l.Parent = sf
        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0.4, 0, 0, 10); vl.Position = UDim2.new(0.6, 0, 0, 0); vl.BackgroundTransparency = 1
        vl.Text = string.format("%.2f", df); vl.TextColor3 = Color3.fromRGB(240, 240, 245)
        vl.Font = Enum.Font.GothamBold; vl.TextSize = 9; vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.ZIndex = 8; vl.Parent = sf
        local sb = Instance.new("TextButton")
        sb.Size = UDim2.new(1, 0, 0, 4); sb.Position = UDim2.new(0, 0, 0, 16); sb.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        sb.Text = ""; sb.AutoButtonColor = false; sb.BorderSizePixel = 0; sb.ZIndex = 8; sb.Parent = sf
        Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
        local fl = Instance.new("Frame")
        fl.Size = UDim2.new(0, 0, 1, 0); fl.BackgroundColor3 = Color3.fromRGB(240, 240, 245); fl.BorderSizePixel = 0
        fl.ZIndex = 8; fl.Parent = sb
        Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
        local tg = Instance.new("Frame")
        tg.Size = UDim2.new(0, 10, 0, 10); tg.Position = UDim2.new(0, 0, 0.5, -5); tg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tg.BorderSizePixel = 0; tg.ZIndex = 9; tg.Parent = sb
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)
        local cval = df
        local function updateV(v)
            local pct = math.clamp((v - mn) / (mx - mn), 0, 1)
            fl.Size = UDim2.new(pct, 0, 1, 0); tg.Position = UDim2.new(pct, -5, 0.5, -5)
            vl.Text = string.format("%.2f", v)
        end
        local function updateI(inp)
            local off = math.clamp((inp.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
            cval = mn + (mx - mn) * off; updateV(cval); pcall(callback, cval)
        end
        sb.InputBegan:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and activeSliderID == nil then
                activeSliderID = id; updateI(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if activeSliderID == id and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateI(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and activeSliderID == id then
                activeSliderID = nil
            end
        end)
        updateV(df)
        cr.sliders[id] = {
            Set = function(v) cval = math.clamp(v, mn, mx); updateV(cval); pcall(callback, cval) end,
            Get = function() return cval end
        }
    end

    function ex:AddButton(text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 22); b.BackgroundColor3 = BG3; b.Text = text
        b.TextColor3 = TEXT; b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.Parent = cc
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        local bs = Instance.new("UIStroke"); bs.Color = BORDER; bs.Thickness = 1; bs.Parent = b
        b.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    cr.toggles.Main = {Set = setToggle, Get = function() return active end}
    cr.toggles.Collapse = {Set = setCollapse, Get = function() return cr.isCollapsed end}
    cr.toggles.Star = {Set = function(v) cr.starActive = v; refreshStar(); syncFav() end, Get = function() return cr.starActive end}
    return ex
end

-- ==================================================
-- СОЗДАНИЕ ВКЛАДОК
-- ==================================================
local tabsList = {"Movement", "Player", "Combat", "Prison Life", "Players", "Favorite", "Config", "Settings"}
local tabsOrder = {}
for i, v in ipairs(tabsList) do tabsOrder[v] = i end

for _, name in ipairs(tabsList) do
    mkPage(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 38, 0, 32); b.BackgroundColor3 = BG2; b.BorderSizePixel = 0; b.Text = ""
    b.LayoutOrder = tabsOrder[name]; b.Parent = SideBtnFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local bs = Instance.new("UIStroke"); bs.Color = BORDER; bs.Thickness = 1; bs.Parent = b
    S.sideButtons[name] = b
    local im = Instance.new("ImageLabel")
    im.Size = UDim2.new(0, 18, 0, 18); im.Position = UDim2.new(0.5, -9, 0.5, -9); im.BackgroundTransparency = 1
    im.Image = icons[name] or "rbxassetid://10723345709"; im.ImageColor3 = TEXT2; im.Parent = b
    b.MouseEnter:Connect(function()
        b.Position = UDim2.new(0, 0, 0, -2); TooltipText.Text = name; Tooltip.Visible = true
        local tx = b.AbsolutePosition.X + b.AbsoluteSize.X + 8
        local ty = b.AbsolutePosition.Y + (b.AbsoluteSize.Y / 2) - (Tooltip.AbsoluteSize.Y / 2)
        Tooltip.Position = UDim2.new(0, tx, 0, ty)
    end)
    b.MouseLeave:Connect(function() b.Position = UDim2.new(0, 0, 0, 0); Tooltip.Visible = false end)
    b.MouseButton1Click:Connect(function() S.currentTab = name; updateVis() end)
end

-- ==================================================
-- КАРТОЧКИ
-- ==================================================
local wsCard = mkCard(S.pages["Movement"], "Walk Speed", "Movement")
wsCard:AddSlider(1, "Speed Value", 1, 500, 16, function(v)
    S.walkVal = v
    if S.walk then local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end end
end)
wsCard:SetToggleCallback(function(s)
    S.walk = s
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s and S.walkVal or 16 end
    startWatchdog(); saveCfg()
end)

local jpCard = mkCard(S.pages["Movement"], "Jump Power", "Movement")
jpCard:AddSlider(2, "Power Value", 1, 500, 50, function(v)
    S.jumpVal = v
    if S.jump then local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end end
end)
jpCard:SetToggleCallback(function(s)
    S.jump = s
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = s and S.jumpVal or 50 end
    startWatchdog(); saveCfg()
end)

local spCard = mkCard(S.pages["Movement"], "Spider", "Movement")
spCard:AddSlider(3, "Climb Speed", 1, 20, 3, function(v) S.climbSpd = v / 10 end)
spCard:SetToggleCallback(function(s) S.spider = s; startSpider(); saveCfg() end)

local ijCard = mkCard(S.pages["Movement"], "Infinite Jump", "Movement")
ijCard:SetToggleCallback(function(s)
    S.infJump = s
    if s and not S.infJumpConn then
        S.infJumpConn = UIS.JumpRequest:Connect(function()
            if not S.infJump then return end
            local c = LocalPlayer.Character; if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    saveCfg()
end)

local vCard = mkCard(S.pages["Movement"], "Vehicle Speed", "Movement")
vCard:AddSlider(4, "Speed", 50, 500, 100, function(v) S.vehicleVal = v end)
vCard:SetToggleCallback(function(s) S.vehicle = s; startVehicle(); saveCfg() end)

-- PLAYER
local ebCard = mkCard(S.pages["Player"], "ESP Boxes", "Player")
ebCard:SetToggleCallback(function(s) S.espBox = s; startBox(); saveCfg() end)

local enCard = mkCard(S.pages["Player"], "ESP Names", "Player")
enCard:SetToggleCallback(function(s) S.espName = s; startName(); saveCfg() end)

local elCard = mkCard(S.pages["Player"], "ESP Lines", "Player")
elCard:SetToggleCallback(function(s) S.espLine = s; startLine(); saveCfg() end)

local etCard = mkCard(S.pages["Player"], "ESP Team Check", "Player")
etCard:SetToggleCallback(function(s) S.espTeam = s; saveCfg() end)

local fcCard = mkCard(S.pages["Player"], "FOV Changer", "Player")
fcCard:AddSlider(5, "FOV", 30, 120, 70, function(v)
    S.fovVal = v
    if S.fov and WS.CurrentCamera then WS.CurrentCamera.FieldOfView = v end
end)
fcCard:SetToggleCallback(function(s) S.fov = s; startFOV(); saveCfg() end)

local fbCard = mkCard(S.pages["Player"], "Fullbright", "Player")
fbCard:SetToggleCallback(function(s) S.fullbright = s; startFB(); saveCfg() end)

local spnCard = mkCard(S.pages["Player"], "Spin", "Player")
spnCard:AddSlider(6, "Spin Rate", 1, 50, 10, function(v) S.spinVal = v end)
spnCard:SetToggleCallback(function(s) S.spin = s; startSpin(); saveCfg() end)

-- COMBAT
local saCard = mkCard(S.pages["Combat"], "Silent Aim", "Combat")
saCard:AddSlider(7, "FOV", 30, 360, 100, function(v) S.aimFOV = v end)
saCard:AddDropdown(1, "Aim Part", {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, "Head", function(v) S.aimPart = v end)
saCard:AddSlider(8, "Hit Chance", 1, 100, 100, function(v) S.aimChance = v end)
saCard:SetToggleCallback(function(s) S.aim = s; if s then installAim() end; saveCfg() end)

local stCard = mkCard(S.pages["Combat"], "Silent Team Check", "Combat")
stCard:SetToggleCallback(function(s) S.aimTeam = s; saveCfg() end)

local swCard = mkCard(S.pages["Combat"], "Silent Wall Check", "Combat")
swCard:SetToggleCallback(function(s) S.aimWall = s; saveCfg() end)

local sfCard = mkCard(S.pages["Combat"], "Silent Ignore Friends", "Combat")
sfCard:SetToggleCallback(function(s) S.aimIgnoreFriends = s; saveCfg() end)

local hbCard = mkCard(S.pages["Combat"], "Hitbox Expander", "Combat")
hbCard:AddSlider(9, "Size x", 1, 10, 3, function(v) S.hbSize = v end)
hbCard:SetToggleCallback(function(s) S.hb = s; startHB(); saveCfg() end)

local htCard = mkCard(S.pages["Combat"], "Hitbox Team Check", "Combat")
htCard:SetToggleCallback(function(s) S.hbTeam = s; saveCfg() end)

local hfCard = mkCard(S.pages["Combat"], "Hitbox Ignore Friends", "Combat")
hfCard:SetToggleCallback(function(s) S.hbIgnoreFriends = s; saveCfg() end)

local hvCard = mkCard(S.pages["Combat"], "Hitbox Visual", "Combat")
hvCard:SetToggleCallback(function(s) S.hbVisual = s; if S.hb then startHB() end; saveCfg() end)

local iaCard = mkCard(S.pages["Combat"], "Infinite Ammo", "Combat")
iaCard:SetToggleCallback(function(s) S.infAmmo = s; startWeapon(); saveCfg() end)

local rfCard = mkCard(S.pages["Combat"], "Rapid Fire", "Combat")
rfCard:SetToggleCallback(function(s) S.rapid = s; startWeapon(); saveCfg() end)

local irCard = mkCard(S.pages["Combat"], "Instant Reload", "Combat")
irCard:SetToggleCallback(function(s) S.reload = s; startWeapon(); saveCfg() end)

-- PRISON LIFE
local akCard = mkCard(S.pages["Prison Life"], "Auto Keycard", "Prison Life")
akCard:AddSlider(10, "Range", 10, 100, 20, function(v) S.keycardRange = v end)
akCard:SetToggleCallback(function(s) S.keycard = s; startKeycard(); saveCfg() end)

local aaCard = mkCard(S.pages["Prison Life"], "Arrest Aura", "Prison Life")
aaCard:AddSlider(11, "Range", 1, 15, 7.5, function(v) S.arrestRange = v end)
aaCard:SetToggleCallback(function(s) S.arrest = s; startArrest(); saveCfg() end)

local maCard = mkCard(S.pages["Prison Life"], "Melee Aura", "Prison Life")
maCard:AddSlider(12, "Range", 1, 9, 4, function(v) S.meleeRange = v end)
maCard:SetToggleCallback(function(s) S.melee = s; startMelee(); saveCfg() end)

local atCard = mkCard(S.pages["Prison Life"], "Anti-Taze", "Prison Life")
atCard:SetToggleCallback(function(s) S.antiTaze = s; startAntiTaze(); saveCfg() end)

local agCard = mkCard(S.pages["Prison Life"], "Auto Get Gun", "Prison Life")
agCard:SetToggleCallback(function(s) S.autoGun = s; startAutoGun(); saveCfg() end)

local igCard = mkCard(S.pages["Prison Life"], "Item Giver", "Prison Life")
igCard:AddButton("Получить M4A1", function() getGun("M4A1") end)
igCard:AddButton("Получить Remington 870", function() getGun("Remington 870") end)
igCard:AddButton("Получить AK-47", function() getGun("AK-47") end)
igCard:AddButton("Получить MP5", function() getGun("MP5") end)

local tpCard = mkCard(S.pages["Prison Life"], "Teleports", "Prison Life")
local tpList = {
    ["Оружейная"] = Vector3.new(826.20, 101.46, 2294.85),
    ["Кафетерий"] = Vector3.new(924.52, 101.48, 2227.59),
    ["База преступников"] = Vector3.new(-975.03, 109.82, 2057.95),
    ["Секретная комната"] = Vector3.new(701.45, 101.45, 2354.30),
    ["Двор"] = Vector3.new(795.78, 99.65, 2541.00),
    ["Внутри тюрьмы"] = Vector3.new(915.29, 101.49, 2388.00),
}
for name, pos in pairs(tpList) do
    tpCard:AddButton("📍 " .. name, function()
        local c = LocalPlayer.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
    end)
end

-- PLAYERS
local plCard = mkCard(S.pages["Players"], "Teleport to Player", "Players")
local plList = {"No Players"}
local plDrop
plDrop = plCard:AddDropdown(2, "Select Player", plList, "No Players", function(v) S.currentTarget = v end)
plCard:AddButton("🔄 Refresh List", function()
    local lst = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(lst, p.Name) end
    end
    if #lst == 0 then lst = {"No Players"} end
    plDrop.Refresh(lst)
end)
plCard:AddButton("📍 Teleport", function()
    if S.currentTarget and S.currentTarget ~= "No Players" then
        local t = Players:FindFirstChild(S.currentTarget)
        if t and t.Character then
            local hr = t.Character:FindFirstChild("HumanoidRootPart")
            local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hr and mr then mr.CFrame = CFrame.new(hr.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

-- CONFIG
local cfgCard = mkCard(S.pages["Config"], "Configuration", "Config")
cfgCard:AddButton("💾 Save Default Config", function()
    S.configs.Default = HttpService:JSONEncode(getCfg())
    saveCfg()
end)
cfgCard:AddButton("📂 Load Default Config", function()
    if S.configs.Default then
        local ok, d = pcall(function() return HttpService:JSONDecode(S.configs.Default) end)
        if ok then applyCfg(d) end
    end
end)

-- SETTINGS
local setCard = mkCard(S.pages["Settings"], "Settings", "Settings")
setCard:AddButton("🔄 Reset UI", function() MainFrame.Position = UDim2.new(0.5, -340, 0.5, -205) end)

-- ==================================================
-- СТАРТ
-- ==================================================
loadCfg()

task.spawn(function()
    task.wait(0.3)
    for _, tn in ipairs(tabsList) do
        if S.pages[tn] then arrangeGrid(S.pages[tn]) end
    end
    updateVis()
end)

local function onChar(char)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.3)
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if S.walk then h.WalkSpeed = S.walkVal end
    if S.jump then
        if h.UseJumpPower then h.JumpPower = S.jumpVal
        else h.JumpHeight = S.jumpVal / 7.5 end
    end
    if S.spin then startSpin() end
    if S.spider then startSpider() end
    if S.espBox then startBox() end
    if S.espName then startName() end
    if S.espLine then startLine() end
    if S.antiTaze then startAntiTaze() end
    if S.keycard then startKeycard() end
    if S.arrest then startArrest() end
    if S.melee then startMelee() end
    if S.autoGun then startAutoGun() end
    if S.hb then startHB() end
    if S.fov then startFOV() end
    if S.fullbright then startFB() end
    if S.vehicle then startVehicle() end
    if S.infAmmo or S.rapid or S.reload then startWeapon() end
end

LocalPlayer.CharacterAdded:Connect(onChar)
if LocalPlayer.Character then task.spawn(onChar, LocalPlayer.Character) end

startWatchdog()

task.spawn(function()
    while true do
        task.wait(10)
        saveCfg()
    end
end)

print("✨ Aura Hub v12 — REGISTER FIXED загружено!")