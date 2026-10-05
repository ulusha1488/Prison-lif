--[[
    ✨ ALPHA HUB PRISON LIFE ✨
    Exclusive for Prison Life
]]

local PLACE_ID = 155615604
if game.PlaceId ~= PLACE_ID then
    game.Players.LocalPlayer:Kick("❌ ALPHA HUB\n\nТолько для Prison Life!")
    return
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local T = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local WS = game:GetService("Workspace")
local Lig = game:GetService("Lighting")
local RSvc = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

if PG:FindFirstChild("AlphaPL") then PG.AlphaPL:Destroy() end

-- ===== STATE =====
local S = {
    hasDraw = false, hasFile = false, hasHook = false, hasFGC = false, hasGC = false,
    walk = false, walkV = 16, jump = false, jumpV = 50, infJump = false, jumpC = nil, wdC = nil,
    spin = false, spinV = 10, spinC = nil, savedHum = nil,
    espTeam = true, espBox = false, espName = false, espLine = false,
    boxC = nil, nameC = nil, lineC = nil, BOXES = {}, NAMES = {}, LINES = {},
    spider = false, spiderC = nil, wallHit = false, climbV = 0.28, boostV = 22,
    antiTaze = false, tazeC = {},
    keycard = false, keyC = nil, keyR = 20,
    getting = false, autoGun = false,
    guns = {["M4A1"]=false, ["Remington 870"]=false, ["AK-47"]=false, ["MP5"]=false},
    aim = false, aimTeam = true, aimWall = true, aimFOV = 100, aimR = 300, aimPart = "Head", aimCh = 100,
    aimIgnoreFr = false, aimHooked = false, oldCR = nil, frCache = {}, target = nil,
    hb = false, hbV = 3, hbVis = true, hbTeam = false, hbIgnoreFr = false,
    hbC = nil, savedHB = {},
    arrest = false, arrestR = 7.5, arrestIgnoreFr = false, arrestC = nil,
    melee = false, meleeR = 4, meleeIgnoreFr = false, meleeC = nil,
    fov = false, fovV = 70, fovC = nil,
    fb = false, fbC = nil, savedL = {},
    veh = false, vehV = 100, vehC = nil,
    ammo = false, rapid = false, reload = false, wpC = nil,
    configs = {}, cfgName = "",
    pages = {}, tabs = {}, cards = {}, favs = {}, curTab = "Movement",
    remotes = {},
}

pcall(function() if Drawing and Drawing.new then local t=Drawing.new("Square"); t:Remove(); S.hasDraw=true end end)
pcall(function() if writefile and readfile and isfile then S.hasFile=true end end)
pcall(function() if hookfunction and getgc then S.hasHook=true end end)
pcall(function() if filtergc then local ok,f=pcall(filtergc,"function",{Name="castRay"},true); S.hasFGC=ok and f~=nil end end)
pcall(function() if getconnections then S.hasGC=true end end)

local cam = WS.CurrentCamera
while not cam do RS.RenderStepped:Wait(); cam=WS.CurrentCamera end
local defFOV = cam.FieldOfView

pcall(function()
    local GR = RSvc:FindFirstChild("GunRemotes")
    if GR then S.remotes.shoot=GR:FindFirstChild("ShootEvent"); S.remotes.taze=GR:FindFirstChild("PlayerTased") end
    local R = RSvc:FindFirstChild("Remotes")
    if R then S.remotes.arrest=R:FindFirstChild("ArrestPlayer") end
    S.remotes.melee = RSvc:FindFirstChild("meleeEvent")
end)

-- ===== COLORS =====
local BG = Color3.fromRGB(13,13,17)
local BG2 = Color3.fromRGB(20,20,26)
local BG3 = Color3.fromRGB(28,28,38)
local SIDEBAR = Color3.fromRGB(10,10,13)
local AC = Color3.fromRGB(0,200,255)
local AC2 = Color3.fromRGB(130,90,255)
local GREEN = Color3.fromRGB(80,220,130)
local RED = Color3.fromRGB(255,90,110)
local TXT = Color3.fromRGB(245,245,255)
local TXT2 = Color3.fromRGB(140,145,165)
local BRD = Color3.fromRGB(40,42,55)

local function isFr(uid)
    if S.frCache[uid]~=nil then return S.frCache[uid] end
    local ok,res = pcall(function() return LP:IsFriendsWith(uid) end)
    S.frCache[uid] = ok and res or false
    return S.frCache[uid]
end

local function tw(o,time,props)
    local a=T:Create(o,TweenInfo.new(time,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
    a:Play(); return a
end

-- ===== WATCHDOG =====
local function startWD()
    if S.wdC then S.wdC:Disconnect() end
    S.wdC = RS.Heartbeat:Connect(function()
        local c=LP.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
        if S.walk and h.WalkSpeed~=S.walkV then h.WalkSpeed=S.walkV end
        if S.jump then
            if h.UseJumpPower then
                if h.JumpPower~=S.jumpV then h.JumpPower=S.jumpV end
            else
                local th=S.jumpV/7.5
                if math.abs(h.JumpHeight-th)>0.1 then h.JumpHeight=th end
            end
        end
    end)
end

-- ===== WEAPON =====
local function getTools()
    local t={}; local c=LP.Character
    if c then for _,x in ipairs(c:GetChildren()) do if x:IsA("Tool") then table.insert(t,x) end end end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,x in ipairs(bp:GetChildren()) do if x:IsA("Tool") then table.insert(t,x) end end end
    return t
end

local function applyW(tool)
    if not tool or not tool:IsA("Tool") then return end
    local gs=tool:FindFirstChild("GunStates")
    if gs then
        pcall(function()
            local env=getsenv(gs)
            if env then
                if S.ammo then env.MaxAmmo=math.huge; env.StoredAmmo=math.huge end
                if S.rapid then env.FireRate=0.0001; env.AutoFire=true end
                if S.reload then env.ReloadTime=0.0001 end
            end
        end)
    end
    for _,o in ipairs(tool:GetDescendants()) do
        pcall(function()
            if o:IsA("NumberValue") then
                local n=o.Name:lower()
                if S.ammo and (n:find("ammo") or n:find("clip")) then o.Value=9999 end
                if S.rapid and n:find("firerate") then o.Value=0.0001 end
                if S.reload and n:find("reload") then o.Value=0.0001 end
            end
        end)
    end
end

local function startWP()
    if S.wpC then S.wpC:Disconnect() end
    if not (S.ammo or S.rapid or S.reload) then return end
    local function applyAll() for _,t in ipairs(getTools()) do applyW(t) end end
    applyAll()
    S.wpC = RS.Heartbeat:Connect(applyAll)
end

-- ===== ITEM GIVER =====
local function getGun(name)
    if S.getting then return end
    S.getting=true
    local c=LP.Character
    local r=c and c:FindFirstChild("HumanoidRootPart")
    if not (c and r) or c:FindFirstChild("ForceField") then S.getting=false return end
    if LP.Backpack:FindFirstChild(name) or c:FindFirstChild(name) then S.getting=false return end
    local g
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name=="TouchGiver" and v:GetAttribute("ToolName")==name then
            g=v:FindFirstChildWhichIsA("BasePart"); break
        end
    end
    if not g then S.getting=false return end
    local ocf=g.CFrame; local oc=r.CFrame
    local ug=ocf-Vector3.new(0,15.5,0)
    g.CanTouch=true; g.CFrame=ug
    c:PivotTo(ug+Vector3.new(0,5,0))
    task.wait(0.25)
    pcall(function() firetouchinterest(g,r,0) end)
    task.wait(0.3)
    pcall(function() firetouchinterest(g,r,1) end)
    task.wait(0.05)
    g.CFrame=ocf; c:PivotTo(oc)
    task.wait(0.1)
    S.getting=false
end

local function startAG()
    if not S.autoGun then return end
    task.spawn(function()
        while S.autoGun do
            task.wait(1)
            for n,e in pairs(S.guns) do if e then getGun(n) end end
        end
    end)
end

-- ===== AURA =====
local function arrestable(P)
    if not P.Character then return false end
    local h=P.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then return false end
    if P.Team and P.Team.Name=="Criminals" then return true end
    local d=h.DisplayName
    return d:find("🔗",1,true) or d:find("💢",1,true)
end

local function startArrest()
    if S.arrestC then S.arrestC:Disconnect() end
    if not S.arrest or not S.remotes.arrest then return end
    S.arrestC=RS.Heartbeat:Connect(function()
        local c=LP.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _,P in ipairs(Players:GetPlayers()) do
            if P==LP or not P.Character then continue end
            if S.arrestIgnoreFr and isFr(P.UserId) then continue end
            if arrestable(P) then
                local hr=P.Character:FindFirstChild("HumanoidRootPart")
                if hr and (r.Position-hr.Position).Magnitude<=S.arrestR then
                    pcall(function() S.remotes.arrest:InvokeServer(P) end)
                end
            end
        end
    end)
end

local function startMelee()
    if S.meleeC then S.meleeC:Disconnect() end
    if not S.melee or not S.remotes.melee then return end
    S.meleeC=RS.Heartbeat:Connect(function()
        local c=LP.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for _,P in ipairs(Players:GetPlayers()) do
            if P==LP or not P.Character then continue end
            if S.meleeIgnoreFr and isFr(P.UserId) then continue end
            local hr=P.Character:FindFirstChild("HumanoidRootPart")
            local h=P.Character:FindFirstChildOfClass("Humanoid")
            if hr and h and h.Health>0 and (r.Position-hr.Position).Magnitude<=S.meleeR then
                pcall(function() S.remotes.melee:FireServer(P) end)
            end
        end
    end)
end

local function startAT()
    if not S.hasGC or not S.remotes.taze then return end
    if S.antiTaze then
        pcall(function()
            for _,cn in pairs(getconnections(S.remotes.taze.OnClientEvent)) do
                pcall(function() cn:Disable(); table.insert(S.tazeC,cn) end)
            end
        end)
    else
        for _,cn in ipairs(S.tazeC) do pcall(function() cn:Enable() end) end
        S.tazeC={}
    end
end

-- ===== SILENT AIM =====
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
rp.IgnoreWater = true

local function vis(part,org)
    if not part then return false end
    rp.FilterDescendantsInstances={LP.Character}
    local res=WS:Raycast(org,part.Position-org,rp)
    return (not res) or res.Instance:IsDescendantOf(part.Parent)
end

local function canAim(P)
    local C=P.Character; if not C then return false end
    local H=C:FindFirstChildOfClass("Humanoid")
    if not H or H.Health<=0 then return false end
    if S.aimIgnoreFr and isFr(P.UserId) then return false end
    if S.aimTeam and LP.Team and P.Team==LP.Team then return false end
    return true
end

local function closest()
    local best,bd=nil,S.aimFOV
    local ctr=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local org=cam.CFrame.Position
    for _,P in ipairs(Players:GetPlayers()) do
        if P==LP then continue end
        if not canAim(P) then continue end
        local C=P.Character
        local part=C:FindFirstChild(S.aimPart) or C:FindFirstChild("Head")
        if not part then continue end
        if (org-part.Position).Magnitude>S.aimR then continue end
        local pos,on=cam:WorldToViewportPoint(part.Position)
        if not on then continue end
        if (part.Position-org):Dot(cam.CFrame.LookVector)<=0 then continue end
        if S.aimWall and not vis(part,org) then continue end
        local d=(Vector2.new(pos.X,pos.Y)-ctr).Magnitude
        if d<bd then bd=d; best=P end
    end
    return best
end

local function didHit() return math.random(1,100)<=S.aimCh end

local function missOff(pp,org)
    local d=(pp-org).Magnitude
    local sc=math.clamp(d/3,3,4)
    return Vector3.new(math.random(-sc*10,sc*10)/10,math.random(-sc*10,sc*10)/10,math.random(-sc*10,sc*10)/10)
end

local function installAim()
    if S.aimHooked or not S.hasHook then return end
    local cr
    if S.hasFGC then pcall(function() cr=filtergc("function",{Name="castRay"},true) end) end
    if not cr then
        pcall(function()
            for _,f in next,getgc(true) do
                if type(f)=="function" then
                    local i=debug.getinfo(f,"nS")
                    if i and i.name=="castRay" then cr=f; break end
                end
            end
        end)
    end
    if not cr then return end
    S.aimHooked=true
    pcall(function()
        S.oldCR=hookfunction(cr,function(...)
            local a={...}
            if S.aim and S.target and S.target.Character then
                local p=S.target.Character:FindFirstChild(S.aimPart)
                if p then
                    if didHit() then a[2]=p.Position
                    else
                        local mp=S.target.Character:FindFirstChild("LeftLeg") or S.target.Character:FindFirstChild("RightLeg")
                        if mp and typeof(a[1])=="Vector3" then a[2]=mp.Position+missOff(mp.Position,a[1]) end
                    end
                end
            end
            return S.oldCR(table.unpack(a))
        end)
    end)
end

RS.Heartbeat:Connect(function() if S.aim then S.target=closest() end end)

-- ===== SPIN =====
local function startSpin()
    if S.spinC then S.spinC:Disconnect() end
    local c=LP.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not S.spin then
        if h and S.savedHum then
            h.AutoRotate=S.savedHum.AutoRotate; h.CameraOffset=S.savedHum.CameraOffset
            S.savedHum=nil
        end
        return
    end
    if h then
        S.savedHum={AutoRotate=h.AutoRotate,CameraOffset=h.CameraOffset}
        h.AutoRotate=false
    end
    S.spinC=RS.Stepped:Connect(function()
        local ch=LP.Character; if not ch then return end
        local hu=ch:FindFirstChildOfClass("Humanoid")
        local rp=ch:FindFirstChild("HumanoidRootPart")
        if not rp then return end
        if hu and hu.AutoRotate then hu.AutoRotate=false end
        rp.CFrame=rp.CFrame*CFrame.Angles(0,math.rad(S.spinV),0)
    end)
end

-- ===== ESP =====
local function mkBox(t)
    if not S.hasDraw or t==LP or S.BOXES[t] then return end
    local b=Drawing.new("Square")
    b.Thickness=1.5; b.Color=AC; b.Filled=false; b.Visible=false; b.Transparency=1
    S.BOXES[t]=b
end
local function rmBox(t) if S.BOXES[t] then pcall(function() S.BOXES[t]:Remove() end) end S.BOXES[t]=nil end

local function startBox()
    if S.boxC then S.boxC:Disconnect() end
    if not S.espBox or not S.hasDraw then for t in pairs(S.BOXES) do rmBox(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkBox(p) end end
    S.boxC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local b=S.BOXES[p]; if not b then mkBox(p) continue end
            local c=p.Character
            local hr=c and c:FindFirstChild("HumanoidRootPart")
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LP.Team and p.Team==LP.Team)
            if show and hr and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                local fs,fo=cam:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
                if ho and fo then
                    local hh=math.abs(hs.Y-fs.Y); local ww=hh/2
                    b.Size=Vector2.new(ww,hh); b.Position=Vector2.new(hs.X-ww/2,hs.Y); b.Visible=true
                else b.Visible=false end
            else b.Visible=false end
        end
    end)
end

local function mkName(t)
    if not S.hasDraw or t==LP or S.NAMES[t] then return end
    local n=Drawing.new("Text")
    n.Size=14; n.Center=true; n.Outline=true; n.Color=Color3.fromRGB(255,255,255)
    n.OutlineColor=Color3.fromRGB(0,0,0); n.Visible=false; n.Font=2; n.Text=t.Name
    S.NAMES[t]=n
end
local function rmName(t) if S.NAMES[t] then pcall(function() S.NAMES[t]:Remove() end) end S.NAMES[t]=nil end

local function startName()
    if S.nameC then S.nameC:Disconnect() end
    if not S.espName or not S.hasDraw then for t in pairs(S.NAMES) do rmName(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkName(p) end end
    S.nameC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local n=S.NAMES[p]; if not n then mkName(p) continue end
            local c=p.Character
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LP.Team and p.Team==LP.Team)
            if show and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                if ho then
                    n.Position=Vector2.new(hs.X,hs.Y-18)
                    n.Text=string.format("%s [%d]",p.Name,math.floor(h.Health))
                    n.Visible=true
                else n.Visible=false end
            else n.Visible=false end
        end
    end)
end

local function mkLine(t)
    if not S.hasDraw or t==LP or S.LINES[t] then return end
    local l=Drawing.new("Line")
    l.Thickness=1; l.Color=AC2; l.Visible=false
    S.LINES[t]=l
end
local function rmLine(t) if S.LINES[t] then pcall(function() S.LINES[t]:Remove() end) end S.LINES[t]=nil end

local function startLine()
    if S.lineC then S.lineC:Disconnect() end
    if not S.espLine or not S.hasDraw then for t in pairs(S.LINES) do rmLine(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkLine(p) end end
    S.lineC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local l=S.LINES[p]; if not l then mkLine(p) continue end
            local c=p.Character
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.espTeam and LP.Team and p.Team==LP.Team)
            if show and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                if ho then
                    l.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
                    l.To=Vector2.new(hs.X,hs.Y); l.Visible=true
                else l.Visible=false end
            else l.Visible=false end
        end
    end)
end

-- ===== SPIDER =====
local function startSpider()
    if S.spiderC then S.spiderC:Disconnect() end
    if not S.spider then S.wallHit=false return end
    S.spiderC=RS.PreRender:Connect(function()
        local c=LP.Character; if not c then S.wallHit=false return end
        local rp=c:FindFirstChild("HumanoidRootPart")
        local h=c:FindFirstChildOfClass("Humanoid")
        if not rp or not h or h.Health<=0 then S.wallHit=false return end
        if h.MoveDirection.Magnitude<=0.1 then S.wallHit=false return end
        local rp2=RaycastParams.new()
        rp2.FilterDescendantsInstances={c}; rp2.FilterType=Enum.RaycastFilterType.Exclude
        local dir=rp.CFrame.LookVector*2.5
        local hit=WS:Raycast(rp.Position,dir,rp2) or WS:Raycast(rp.Position-rp.CFrame.RightVector*1.1,dir,rp2) or WS:Raycast(rp.Position+rp.CFrame.RightVector*1.1,dir,rp2)
        if hit then
            rp.CFrame=rp.CFrame+Vector3.new(0,S.climbV,0)+(rp.CFrame.LookVector*0.05)
            if rp.AssemblyLinearVelocity.Y<0 then rp.AssemblyLinearVelocity=Vector3.new(rp.AssemblyLinearVelocity.X,2,rp.AssemblyLinearVelocity.Z) end
            S.wallHit=true
        else
            if S.wallHit then
                S.wallHit=false
                local fwd=rp.CFrame.LookVector
                rp.AssemblyLinearVelocity=Vector3.new(fwd.X*S.boostV*0.68,S.boostV,fwd.Z*S.boostV*0.68)
                rp.CFrame=rp.CFrame+Vector3.new(0,1.5,0)+(fwd*0.5)
            end
        end
    end)
end

-- ===== KEYCARD =====
local function hasKey()
    local c=LP.Character
    if c then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("keycard") then return true end end end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("keycard") then return true end end end
    return false
end
local function isCrim()
    local n=LP.Team and LP.Team.Name or ""
    local l=n:lower()
    return l:find("prisoner") or l:find("inmate") or l:find("criminal") or l:find("convict")
end

local function startKey()
    if S.keyC then S.keyC:Disconnect() end
    if not S.keycard then return end
    S.keyC=RS.Heartbeat:Connect(function()
        if not isCrim() or hasKey() then return end
        local c=LP.Character
        local rp=c and c:FindFirstChild("HumanoidRootPart")
        if not rp then return end
        for _,o in ipairs(WS:GetDescendants()) do
            if o:IsA("Tool") or o:IsA("BasePart") or o:IsA("Model") then
                local n=o.Name:lower()
                if n:find("keycard") or n:find("key card") or n:find("key_card") then
                    local p=o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position-rp.Position).Magnitude<S.keyR then
                        rp.CFrame=CFrame.new(p.Position+Vector3.new(0,3,0))
                    end
                end
            end
        end
    end)
end

-- ===== HITBOX =====
local function hbParts(c)
    if not c then return {} end
    local t={}
    for _,n in ipairs({"Head","HumanoidRootPart","UpperTorso","Torso"}) do
        local p=c:FindFirstChild(n); if p then table.insert(t,p) end
    end
    return t
end

local function hbApply(P)
    local c=P.Character; if not c then return end
    for _,p in ipairs(hbParts(c)) do
        if not S.savedHB[p] then
            S.savedHB[p]={Size=p.Size,Transparency=p.Transparency,CanCollide=p.CanCollide,Material=p.Material,Color=p.Color}
        end
        p.Size=S.savedHB[p].Size*S.hbV
        p.CanCollide=false
        if S.hbVis then p.Transparency=0.5; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(255,100,100) end
    end
end

local function hbRemove(P)
    local c=P.Character; if not c then return end
    for _,p in ipairs(hbParts(c)) do
        local sv=S.savedHB[p]
        if sv then
            p.Size=sv.Size; p.Transparency=sv.Transparency; p.CanCollide=sv.CanCollide
            p.Material=sv.Material; p.Color=sv.Color; S.savedHB[p]=nil
        end
    end
end

local function hbShould(P)
    local C=P.Character; if not C then return false end
    local H=C:FindFirstChildOfClass("Humanoid")
    if not H or H.Health<=0 then return false end
    if S.hbIgnoreFr and isFr(P.UserId) then return false end
    if S.hbTeam and LP.Team and P.Team==LP.Team then return false end
    return true
end

local function hbVis(P)
    local c=P.Character
    if not c or not c.Parent then return end
    if S.hb and hbShould(P) then
        if not c:FindFirstChild("HitboxHighlight") then
            local hl=Instance.new("Highlight")
            hl.Name="HitboxHighlight"; hl.FillColor=Color3.fromRGB(255,80,80); hl.FillTransparency=0.7
            hl.OutlineColor=Color3.fromRGB(255,150,150); hl.OutlineTransparency=0
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=c
        end
    else
        local ex=c:FindFirstChild("HitboxHighlight"); if ex then ex:Destroy() end
    end
end

local function startHB()
    if S.hbC then S.hbC:Disconnect() end
    if not S.hb then
        for _,p in ipairs(Players:GetPlayers()) do
            hbRemove(p)
            local c=p.Character; if c and c:FindFirstChild("HitboxHighlight") then c.HitboxHighlight:Destroy() end
        end
        S.savedHB={}
        return
    end
    S.hbC=RS.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            if hbShould(p) then hbApply(p) else hbRemove(p) end
            hbVis(p)
        end
    end)
end

-- ===== FOV / FB / VEH =====
local function startFOV()
    if S.fovC then S.fovC:Disconnect() end
    if not S.fov then if WS.CurrentCamera then WS.CurrentCamera.FieldOfView=defFOV end return end
    if WS.CurrentCamera then WS.CurrentCamera.FieldOfView=S.fovV end
    S.fovC=RS.Heartbeat:Connect(function()
        if not S.fov then return end
        if WS.CurrentCamera and WS.CurrentCamera.FieldOfView~=S.fovV then WS.CurrentCamera.FieldOfView=S.fovV end
    end)
end

local function startFB()
    if S.fbC then S.fbC:Disconnect() end
    if not S.fb then
        for k,v in pairs(S.savedL) do pcall(function() Lig[k]=v end) end
        S.savedL={}; return
    end
    S.savedL={Ambient=Lig.Ambient,OutdoorAmbient=Lig.OutdoorAmbient,Brightness=Lig.Brightness,
        ClockTime=Lig.ClockTime,FogEnd=Lig.FogEnd,FogStart=Lig.FogStart,GlobalShadows=Lig.GlobalShadows}
    S.fbC=RS.Heartbeat:Connect(function()
        if not S.fb then return end
        Lig.Ambient=Color3.fromRGB(200,200,200); Lig.OutdoorAmbient=Color3.fromRGB(200,200,200)
        Lig.Brightness=3; Lig.ClockTime=14; Lig.FogEnd=100000; Lig.FogStart=100000; Lig.GlobalShadows=false
    end)
end

local function startVeh()
    if S.vehC then S.vehC:Disconnect() end
    if not S.veh then return end
    S.vehC=RS.Heartbeat:Connect(function()
        local c=LP.Character; if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid"); if not h then return end
        local seat=h.SeatPart
        if seat then
            local v=seat:FindFirstAncestorOfClass("Model") or seat.Parent
            if v then
                for _,o in ipairs(v:GetDescendants()) do
                    if o:IsA("VehicleSeat") or o:IsA("Seat") then
                        pcall(function() o.MaxSpeed=S.vehV; o.Torque=S.vehV*100 end)
                    end
                end
            end
        end
    end)
end

-- ===== CONFIG =====
local function getCfg()
    return {walk=S.walk,walkV=S.walkV,jump=S.jump,jumpV=S.jumpV,infJump=S.infJump,
        spin=S.spin,spinV=S.spinV,espTeam=S.espTeam,espBox=S.espBox,espName=S.espName,espLine=S.espLine,
        spider=S.spider,climbV=S.climbV,boostV=S.boostV,antiTaze=S.antiTaze,keycard=S.keycard,keyR=S.keyR,
        autoGun=S.autoGun,guns=S.guns,aim=S.aim,aimTeam=S.aimTeam,aimWall=S.aimWall,aimFOV=S.aimFOV,
        aimR=S.aimR,aimPart=S.aimPart,aimCh=S.aimCh,aimIgnoreFr=S.aimIgnoreFr,
        hb=S.hb,hbV=S.hbV,hbVis=S.hbVis,hbTeam=S.hbTeam,hbIgnoreFr=S.hbIgnoreFr,
        arrest=S.arrest,arrestR=S.arrestR,arrestIgnoreFr=S.arrestIgnoreFr,
        melee=S.melee,meleeR=S.meleeR,meleeIgnoreFr=S.meleeIgnoreFr,
        fov=S.fov,fovV=S.fovV,fb=S.fb,veh=S.veh,vehV=S.vehV,
        ammo=S.ammo,rapid=S.rapid,reload=S.reload}
end

local function applyCfg(d)
    if not d then return end
    S.walk=d.walk or false; S.walkV=d.walkV or 16
    S.jump=d.jump or false; S.jumpV=d.jumpV or 50
    S.infJump=d.infJump or false; S.spin=d.spin or false; S.spinV=d.spinV or 10
    S.espTeam=d.espTeam~=false; S.espBox=d.espBox or false; S.espName=d.espName or false; S.espLine=d.espLine or false
    S.spider=d.spider or false; S.climbV=d.climbV or 0.28; S.boostV=d.boostV or 22
    S.antiTaze=d.antiTaze or false; S.keycard=d.keycard or false; S.keyR=d.keyR or 20
    S.autoGun=d.autoGun or false; S.guns=d.guns or S.guns
    S.aim=d.aim or false; S.aimTeam=d.aimTeam~=false; S.aimWall=d.aimWall~=false
    S.aimFOV=d.aimFOV or 100; S.aimR=d.aimR or 300; S.aimPart=d.aimPart or "Head"; S.aimCh=d.aimCh or 100
    S.aimIgnoreFr=d.aimIgnoreFr or false
    S.hb=d.hb or false; S.hbV=d.hbV or 3; S.hbVis=d.hbVis~=false
    S.hbTeam=d.hbTeam or false; S.hbIgnoreFr=d.hbIgnoreFr or false
    S.arrest=d.arrest or false; S.arrestR=d.arrestR or 7.5; S.arrestIgnoreFr=d.arrestIgnoreFr or false
    S.melee=d.melee or false; S.meleeR=d.meleeR or 4; S.meleeIgnoreFr=d.meleeIgnoreFr or false
    S.fov=d.fov or false; S.fovV=d.fovV or 70; S.fb=d.fb or false
    S.veh=d.veh or false; S.vehV=d.vehV or 100
    S.ammo=d.ammo or false; S.rapid=d.rapid or false; S.reload=d.reload or false
end

local function saveCur()
    if not S.hasFile then return end
    pcall(function() writefile("AlphaPL_Settings.json",HS:JSONEncode(getCfg())) end)
end
local function loadCur()
    if not S.hasFile then return end
    if isfile("AlphaPL_Settings.json") then
        pcall(function() applyCfg(HS:JSONDecode(readfile("AlphaPL_Settings.json"))) end)
    end
end
local function saveAll()
    if not S.hasFile then return end
    pcall(function() writefile("AlphaPL_Configs.json",HS:JSONEncode(S.configs)) end)
end
local function loadAll()
    if not S.hasFile then return end
    if isfile("AlphaPL_Configs.json") then
        pcall(function() S.configs=HS:JSONDecode(readfile("AlphaPL_Configs.json")) end)
    end
end

-- ==================================================
-- UI
-- ==================================================
local SG = Instance.new("ScreenGui")
SG.Name = "AlphaPL"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = PG

-- === ГЛАВНОЕ ОКНО ===
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 700, 0, 440)
Main.Position = UDim2.new(0.5, -350, 0.5, -220)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = SG
local Mc = Instance.new("UICorner"); Mc.CornerRadius = UDim.new(0, 10); Mc.Parent = Main
local MS = Instance.new("UIStroke"); MS.Color = AC; MS.Thickness = 1.5; MS.Transparency = 0.3; MS.Parent = Main
local MG = Instance.new("UIGradient", Main)
MG.Rotation = 135
MG.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24,20,42)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(16,16,24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,18)),
}
local MGlow = Instance.new("ImageLabel", Main)
MGlow.AnchorPoint = Vector2.new(0.5,0.5)
MGlow.Position = UDim2.new(0.5,0,0.5,0)
MGlow.Size = UDim2.new(1,50,1,50)
MGlow.BackgroundTransparency = 1
MGlow.Image = "rbxassetid://5554236805"
MGlow.ImageColor3 = AC
MGlow.ImageTransparency = 0.75
MGlow.ScaleType = Enum.ScaleType.Slice
MGlow.SliceCenter = Rect.new(23,23,277,277)
MGlow.ZIndex = -1

local drag, dS, sP
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dS = i.Position; sP = Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dS
        Main.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- === SIDEBAR ===
local SB = Instance.new("Frame")
SB.Size = UDim2.new(0, 80, 1, 0)
SB.BackgroundColor3 = SIDEBAR
SB.BorderSizePixel = 0
SB.ZIndex = 6
SB.Parent = Main
local SBc = Instance.new("UICorner"); SBc.CornerRadius = UDim.new(0, 10); SBc.Parent = SB
local SBcov = Instance.new("Frame")
SBcov.Size = UDim2.new(0, 15, 1, 0); SBcov.Position = UDim2.new(1, -15, 0, 0)
SBcov.BackgroundColor3 = SIDEBAR; SBcov.BorderSizePixel = 0; SBcov.ZIndex = 6; SBcov.Parent = SB

local LogoSq = Instance.new("Frame")
LogoSq.Size = UDim2.new(0, 40, 0, 40); LogoSq.Position = UDim2.new(0, 20, 0, 12)
LogoSq.BackgroundColor3 = AC; LogoSq.BorderSizePixel = 0; LogoSq.ZIndex = 7; LogoSq.Parent = SB
Instance.new("UICorner", LogoSq).CornerRadius = UDim.new(0, 10)
local LG = Instance.new("UIGradient", LogoSq)
LG.Rotation = 45
LG.Color = ColorSequence.new(AC, AC2)
local LIcon = Instance.new("TextLabel")
LIcon.Size = UDim2.new(1,0,1,0); LIcon.BackgroundTransparency = 1
LIcon.Text = "⚡"; LIcon.TextColor3 = Color3.fromRGB(255,255,255); LIcon.Font = Enum.Font.GothamBold
LIcon.TextSize = 22; LIcon.ZIndex = 7; LIcon.Parent = LogoSq

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1,-10,0,16); LogoTitle.Position = UDim2.new(0,5,0,58)
LogoTitle.BackgroundTransparency = 1; LogoTitle.Text = "ALPHA HUB"
LogoTitle.TextColor3 = TXT; LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextSize = 10; LogoTitle.TextXAlignment = Enum.TextXAlignment.Center
LogoTitle.ZIndex = 7; LogoTitle.Parent = SB

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1,-10,0,12); LogoSub.Position = UDim2.new(0,5,0,74)
LogoSub.BackgroundTransparency = 1; LogoSub.Text = "Prison Life"
LogoSub.TextColor3 = AC2; LogoSub.Font = Enum.Font.Gotham
LogoSub.TextSize = 9; LogoSub.TextXAlignment = Enum.TextXAlignment.Center
LogoSub.ZIndex = 7; LogoSub.Parent = SB

local TabsFrame = Instance.new("ScrollingFrame")
TabsFrame.Size = UDim2.new(1,0,1,-95); TabsFrame.Position = UDim2.new(0,0,0,92)
TabsFrame.BackgroundTransparency = 1; TabsFrame.ScrollBarThickness = 0
TabsFrame.CanvasSize = UDim2.new(0,0,0,500); TabsFrame.ZIndex = 7; TabsFrame.Parent = SB
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0,6); TL.HorizontalAlignment = Enum.HorizontalAlignment.Center; TL.Parent = TabsFrame

local CloseB = Instance.new("TextButton")
CloseB.Size = UDim2.new(0, 28, 0, 28); CloseB.Position = UDim2.new(1, -38, 0, 12)
CloseB.BackgroundColor3 = Color3.fromRGB(40,20,30); CloseB.Text = "✕"
CloseB.TextColor3 = RED; CloseB.Font = Enum.Font.GothamBold; CloseB.TextSize = 14
CloseB.AutoButtonColor = false; CloseB.ZIndex = 20; CloseB.Parent = Main
Instance.new("UICorner", CloseB).CornerRadius = UDim.new(0, 8)
local CStr = Instance.new("UIStroke"); CStr.Color = RED; CStr.Thickness = 1; CStr.Transparency = 0.6; CStr.Parent = CloseB

local MinB = Instance.new("TextButton")
MinB.Size = UDim2.new(0, 28, 0, 28); MinB.Position = UDim2.new(1, -72, 0, 12)
MinB.BackgroundColor3 = BG3; MinB.Text = "—"
MinB.TextColor3 = TXT2; MinB.Font = Enum.Font.GothamBold; MinB.TextSize = 15
MinB.AutoButtonColor = false; MinB.ZIndex = 20; MinB.Parent = Main
Instance.new("UICorner", MinB).CornerRadius = UDim.new(0, 8)

local CurTabLbl = Instance.new("TextLabel")
CurTabLbl.Size = UDim2.new(0, 300, 0, 30); CurTabLbl.Position = UDim2.new(0, 100, 0, 14)
CurTabLbl.BackgroundTransparency = 1; CurTabLbl.Text = "Movement"
CurTabLbl.TextColor3 = TXT; CurTabLbl.Font = Enum.Font.GothamBold
CurTabLbl.TextSize = 18; CurTabLbl.TextXAlignment = Enum.TextXAlignment.Left
CurTabLbl.ZIndex = 6; CurTabLbl.Parent = Main

local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(0, 50, 0, 2); AccentBar.Position = UDim2.new(0, 100, 0, 46)
AccentBar.BackgroundColor3 = AC; AccentBar.BorderSizePixel = 0; AccentBar.ZIndex = 6; AccentBar.Parent = Main
Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(1,0)
local ABG = Instance.new("UIGradient", AccentBar)
ABG.Color = ColorSequence.new(AC, AC2)

local PagesC = Instance.new("Frame")
PagesC.Size = UDim2.new(1, -105, 1, -60); PagesC.Position = UDim2.new(0, 95, 0, 55)
PagesC.BackgroundTransparency = 1; PagesC.ZIndex = 6; PagesC.Parent = Main

-- === ТАБЛЕТКА (твоя) ===
local Tab = Instance.new("Frame")
Tab.Size = UDim2.new(0, 140, 0, 36)
Tab.Position = UDim2.new(0.5, -70, 0.5, -18)
Tab.BackgroundColor3 = Color3.fromRGB(0,0,0)
Tab.BackgroundTransparency = 0.3
Tab.ZIndex = 25; Tab.Visible = false; Tab.Parent = SG
Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 18)
local TabS = Instance.new("UIStroke"); TabS.Color = Color3.fromRGB(80,80,80); TabS.Thickness = 1; TabS.Parent = Tab
local TabIcon = Instance.new("TextLabel")
TabIcon.Size = UDim2.new(0,24,1,0); TabIcon.Position = UDim2.new(0,12,0,0)
TabIcon.BackgroundTransparency = 1; TabIcon.Text = "⌇"; TabIcon.TextColor3 = TXT
TabIcon.TextSize = 16; TabIcon.Font = Enum.Font.GothamBold; TabIcon.ZIndex = 25; TabIcon.Parent = Tab
local TabTxt = Instance.new("TextLabel")
TabTxt.Size = UDim2.new(1,-45,1,0); TabTxt.Position = UDim2.new(0,36,0,0)
TabTxt.BackgroundTransparency = 1; TabTxt.Text = "Alpha Hub"
TabTxt.TextColor3 = TXT; TabTxt.TextSize = 13; TabTxt.Font = Enum.Font.GothamBold
TabTxt.TextXAlignment = Enum.TextXAlignment.Left; TabTxt.ZIndex = 25; TabTxt.Parent = Tab
local TabCl = Instance.new("TextButton")
TabCl.Size = UDim2.new(1,0,1,0); TabCl.BackgroundTransparency = 1; TabCl.Text = ""
TabCl.ZIndex = 26; TabCl.Parent = Tab

local tD, tS, tSP
TabCl.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        tD = true; tS = i.Position; tSP = Tab.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if tD and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - tS
        Tab.Position = UDim2.new(tSP.X.Scale, tSP.X.Offset + d.X, tSP.Y.Scale, tSP.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if tD then
            tD = false
            local d = i.Position - tS
            if d.Magnitude < 5 then Tab.Visible = false; Main.Visible = true end
        end
    end
end)
CloseB.MouseButton1Click:Connect(function() Main.Visible = false; Tab.Visible = true end)
MinB.MouseButton1Click:Connect(function() Main.Visible = false; Tab.Visible = true end)

-- ==================================================
-- СИСТЕМА КАРТОЧЕК
-- ==================================================
local function arr(pd)
    if not pd or not pd.Cards then return end
    local cards = {}
    for _, c in ipairs(pd.Cards) do if c and c.Parent == pd.Frame then table.insert(cards, c) end end
    local cw, px, py, sx, sy = 190, 10, 10, 5, 5
    local cols = {0,0,0}
    for _, cf in ipairs(cards) do
        local mc, mh = 1, cols[1]
        for c = 2, 3 do if cols[c] < mh then mh = cols[c]; mc = c end end
        cf.Position = UDim2.new(0, sx + (mc-1) * (cw+px), 0, sy + mh)
        cols[mc] = mh + cf.AbsoluteSize.Y + py
    end
    local mh = cols[1]
    for c = 2,3 do if cols[c] > mh then mh = cols[c] end end
    pd.Frame.CanvasSize = UDim2.new(0, 0, 0, sy + mh + 20)
end

local function updVis()
    CurTabLbl.Text = S.curTab
    for n, pd in pairs(S.pages) do
        if pd and pd.Frame then
            pd.Frame.Visible = (n == S.curTab)
            if n == S.curTab then
                for _, c in ipairs(pd.Cards) do if c then c.Visible = true end end
                arr(pd)
            end
        end
    end
    for n, b in pairs(S.tabs) do
        local im = b:FindFirstChildOfClass("ImageLabel")
        local st = b:FindFirstChildOfClass("UIStroke")
        if n == S.curTab then
            b.BackgroundColor3 = BG3
            if st then st.Color = AC end
            if im then im.ImageColor3 = AC end
        else
            b.BackgroundColor3 = BG2
            if st then st.Color = BRD end
            if im then im.ImageColor3 = TXT2 end
        end
    end
end

local icons = {
    ["Movement"] = "rbxassetid://10723345709",
    ["Player"] = "rbxassetid://10723395906",
    ["Combat"] = "rbxassetid://10723345709",
    ["PL Functions"] = "rbxassetid://10734950349",
    ["Players"] = "rbxassetid://10734963570",
    ["Configs"] = "rbxassetid://10723345709",
    ["Settings"] = "rbxassetid://10723345709",
}

local function mkPage(name)
    local pf = Instance.new("ScrollingFrame")
    pf.Size = UDim2.new(1,0,1,0); pf.BackgroundTransparency = 1
    pf.ScrollBarThickness = 4; pf.ScrollBarImageColor3 = Color3.fromRGB(45,45,50)
    pf.Visible = false; pf.ZIndex = 6; pf.Parent = PagesC
    S.pages[name] = {Frame = pf, Cards = {}}
    return S.pages[name]
end

-- ==================================================
-- КАРТОЧКА
-- ==================================================
local function mkCard(pd, title, opts)
    opts = opts or {}
    local hasContent = opts.content ~= false
    local cf = Instance.new("Frame")
    cf.Name = title .. "Card"
    cf.Size = UDim2.new(0, 190, 0, hasContent and 120 or 36)
    cf.AutomaticSize = hasContent and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    cf.BackgroundColor3 = Color3.fromRGB(16,16,22)
    cf.BorderSizePixel = 0; cf.ClipsDescendants = true; cf.ZIndex = 7; cf.Parent = pd.Frame
    table.insert(pd.Cards, cf)
    local cr = {frame = cf, name = title, origPage = opts.origPage, currentHome = pd,
        dropdowns = {}, sliders = {}, toggles = {}, starActive = false, isCollapsed = false}
    table.insert(S.cards, cr)
    Instance.new("UICorner", cf).CornerRadius = UDim.new(0, 8)
    local cstr = Instance.new("UIStroke"); cstr.Thickness = 1; cstr.Color = BRD
    cstr.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; cstr.Parent = cf

    local hf = Instance.new("Frame"); hf.Name = "HeaderFrame"
    hf.Size = UDim2.new(1,0,0,36); hf.BackgroundTransparency = 1; hf.ZIndex = 7; hf.Parent = cf

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -75, 1, 0); tl.Position = UDim2.new(0, 12, 0, 0)
    tl.BackgroundTransparency = 1; tl.Text = title
    tl.TextColor3 = TXT; tl.Font = Enum.Font.GothamBold
    tl.TextSize = 11; tl.TextWrapped = true; tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 7; tl.Parent = hf

    if opts.hasStar ~= false then
        local sc = Instance.new("Frame")
        sc.Name = "StarContainer"; sc.Size = UDim2.new(0, 18, 0, 18)
        sc.Position = UDim2.new(1, -68, 0, 9)
        sc.BackgroundColor3 = Color3.fromRGB(24,24,28); sc.BorderSizePixel = 0
        sc.ZIndex = 7; sc.Parent = hf
        Instance.new("UICorner", sc).CornerRadius = UDim.new(0, 4)
        local ss = Instance.new("UIStroke"); ss.Thickness = 1; ss.Color = Color3.fromRGB(45,45,50); ss.Parent = sc
        local sb = Instance.new("TextButton")
        sb.Name = "StarButton"; sb.Size = UDim2.new(1,0,1,0); sb.BackgroundTransparency = 1
        sb.Text = "★"; sb.Font = Enum.Font.GothamBold; sb.TextSize = 11
        sb.TextColor3 = Color3.fromRGB(80,80,85); sb.ZIndex = 8; sb.Parent = sc
        local function refreshStar()
            if cr.starActive then
                tw(sb, 0.2, {TextColor3 = Color3.fromRGB(255,255,255)})
                tw(ss, 0.2, {Color = Color3.fromRGB(255,255,255)})
            else
                tw(sb, 0.2, {TextColor3 = Color3.fromRGB(80,80,85)})
                tw(ss, 0.2, {Color = Color3.fromRGB(45,45,50)})
            end
        end
        cr.refreshStarUI = refreshStar
        sb.MouseButton1Click:Connect(function()
            cr.starActive = not cr.starActive; refreshStar()
        end)
    end

    if opts.hasToggle ~= false then
        local ts = Instance.new("TextButton")
        ts.Name = "ToggleSlider"; ts.Size = UDim2.new(0, 28, 0, 16)
        ts.Position = UDim2.new(1, -46, 0, 10)
        ts.BackgroundColor3 = Color3.fromRGB(30,30,35); ts.Text = ""
        ts.AutoButtonColor = false; ts.ZIndex = 8; ts.Parent = hf
        Instance.new("UICorner", ts).CornerRadius = UDim.new(1, 0)
        local tst = Instance.new("UIStroke"); tst.Thickness = 1; tst.Color = Color3.fromRGB(45,45,50); tst.Parent = ts
        local tc = Instance.new("Frame")
        tc.Name = "Circle"; tc.Size = UDim2.new(0, 10, 0, 10)
        tc.Position = UDim2.new(0, 3, 0.5, -5)
        tc.BackgroundColor3 = Color3.fromRGB(130,130,135); tc.BorderSizePixel = 0
        tc.ZIndex = 8; tc.Parent = ts
        Instance.new("UICorner", tc).CornerRadius = UDim.new(1, 0)

        local active = false
        local toggleCb = nil
        local function setToggle(a, fire)
            active = a
            if active then
                tw(ts, 0.2, {BackgroundColor3 = Color3.fromRGB(240,240,245)})
                tw(tst, 0.2, {Color = Color3.fromRGB(255,255,255)})
                tw(tc, 0.2, {Position = UDim2.new(1,-13,0.5,-5), BackgroundColor3 = Color3.fromRGB(15,15,18)})
            else
                tw(ts, 0.2, {BackgroundColor3 = Color3.fromRGB(30,30,35)})
                tw(tst, 0.2, {Color = Color3.fromRGB(45,45,50)})
                tw(tc, 0.2, {Position = UDim2.new(0,3,0.5,-5), BackgroundColor3 = Color3.fromRGB(130,130,135)})
            end
            if fire ~= false and toggleCb then pcall(toggleCb, active) end
        end
        ts.MouseButton1Click:Connect(function() setToggle(not active); saveCur() end)
        cr.setToggleState = setToggle
        cr.getToggleState = function() return active end
        cr.toggles.Main = {Set = setToggle, Get = function() return active end}
    end

    local cb = Instance.new("TextButton")
    cb.Name = "CollapseButton"; cb.Size = UDim2.new(0, 20, 0, 20)
    cb.Position = UDim2.new(1, -22, 0, 8)
    cb.BackgroundTransparency = 1; cb.Text = "▲"
    cb.Font = Enum.Font.GothamBold; cb.TextSize = 10
    cb.TextColor3 = Color3.fromRGB(200,200,205); cb.ZIndex = 8; cb.Parent = hf

    local cc
    if hasContent then
        cc = Instance.new("Frame")
        cc.Name = "ContentContainer"; cc.Size = UDim2.new(1, -24, 0, 0)
        cc.Position = UDim2.new(0, 12, 0, 40)
        cc.AutomaticSize = Enum.AutomaticSize.Y
        cc.BackgroundTransparency = 1; cc.ZIndex = 7; cc.Parent = cf
        local ll = Instance.new("UIListLayout")
        ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0, 8); ll.Parent = cc
    else
        cc = Instance.new("Frame")
        cc.Name = "ContentContainer"; cc.Size = UDim2.new(0,0,0,0)
        cc.Visible = false; cc.Parent = cf
    end

    local baseSize = hasContent and 120 or 36
    cb.MouseButton1Click:Connect(function()
        cr.isCollapsed = not cr.isCollapsed
        if cr.isCollapsed then
            cr.savedHeight = cf.Size
            tw(cf, 0.2, {Size = UDim2.new(0, 190, 0, 36)})
            tw(cc, 0.15, {Size = UDim2.new(0,0,0,0)}).Completed:Connect(function()
                cc.Visible = false
            end)
            cb.Text = "▼"
        else
            cc.Visible = true
            tw(cf, 0.2, {Size = cr.savedHeight or UDim2.new(0, 190, 0, 120)})
            cb.Text = "▲"
        end
        task.wait(0.05); arr(cr.currentHome)
    end)

    local ex = {}
    function ex:SetToggleCallback(f) cr.toggleCallback = f
        if cr.toggles.Main then
            cr.toggles.Main.Set = function(v)
                local ts2 = hf:FindFirstChild("ToggleSlider")
                if ts2 then
                    local a = v
                    if a then
                        tw(ts2, 0.2, {BackgroundColor3 = Color3.fromRGB(240,240,245)})
                        local c2 = ts2:FindFirstChild("Circle")
                        if c2 then tw(c2, 0.2, {Position = UDim2.new(1,-13,0.5,-5), BackgroundColor3 = Color3.fromRGB(15,15,18)}) end
                    else
                        tw(ts2, 0.2, {BackgroundColor3 = Color3.fromRGB(30,30,35)})
                        local c2 = ts2:FindFirstChild("Circle")
                        if c2 then tw(c2, 0.2, {Position = UDim2.new(0,3,0.5,-5), BackgroundColor3 = Color3.fromRGB(130,130,135)}) end
                    end
                    cr.toggles.Main.Get = function() return a end
                end
            end
        end
    end

    function ex:AddDropdown(id, text, options, default, callback)
        local df = Instance.new("Frame"); df.Size = UDim2.new(1, 0, 0, 34)
        df.BackgroundTransparency = 1; df.ZIndex = 9; df.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 12); l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = TXT2; l.Font = Enum.Font.GothamMedium; l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 9; l.Parent = df
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 18); b.Position = UDim2.new(0, 0, 0, 15)
        b.BackgroundColor3 = Color3.fromRGB(22,22,26)
        b.Font = Enum.Font.GothamMedium; b.Text = " " .. default
        b.TextColor3 = Color3.fromRGB(210,210,215); b.TextSize = 10
        b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
        b.ZIndex = 10; b.Parent = df
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        local ar = Instance.new("TextLabel")
        ar.Size = UDim2.new(0, 18, 1, 0); ar.Position = UDim2.new(1, -18, 0, 0)
        ar.BackgroundTransparency = 1; ar.Text = "▼"; ar.TextColor3 = Color3.fromRGB(100,100,105)
        ar.TextSize = 7; ar.ZIndex = 10; ar.Parent = b
        local lf = Instance.new("Frame")
        lf.Name = "ListFrame"; lf.Size = UDim2.new(1, 0, 0, 0); lf.Position = UDim2.new(0, 0, 1, 2)
        lf.BackgroundColor3 = Color3.fromRGB(20,20,24); lf.BorderSizePixel = 0
        lf.ClipsDescendants = true; lf.ZIndex = 15; lf.Parent = b
        Instance.new("UICorner", lf).CornerRadius = UDim.new(0, 4)
        local ls = Instance.new("UIStroke"); ls.Thickness = 1; ls.Color = Color3.fromRGB(40,40,45); ls.Parent = lf
        Instance.new("UIListLayout", lf).SortOrder = Enum.SortOrder.LayoutOrder
        local cval = default
        local open = false
        local function toggle()
            open = not open
            if open then
                cf.ClipsDescendants = false; ar.Text = "▲"
                tw(lf, 0.2, {Size = UDim2.new(1, 0, 0, #options * 18)})
            else
                ar.Text = "▼"
                tw(lf, 0.2, {Size = UDim2.new(1, 0, 0, 0)}).Completed:Connect(function()
                    if not open then cf.ClipsDescendants = true end
                end)
            end
        end
        b.MouseButton1Click:Connect(toggle)
        for _, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 18); ob.BackgroundColor3 = Color3.fromRGB(20,20,24)
            ob.BackgroundTransparency = 1; ob.Font = Enum.Font.GothamMedium
            ob.Text = " " .. opt; ob.TextColor3 = Color3.fromRGB(180,180,185)
            ob.TextSize = 10; ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.BorderSizePixel = 0; ob.ZIndex = 16; ob.Parent = lf
            ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0 end)
            ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
            ob.MouseButton1Click:Connect(function()
                cval = opt; b.Text = " " .. opt; toggle(); pcall(callback, opt); saveCur()
            end)
        end
        cr.dropdowns[id] = {
            Set = function(v) cval = v; b.Text = " " .. v; pcall(callback, v) end,
            Get = function() return cval end
        }
        return cr.dropdowns[id]
    end

    local activeSlider = nil
    function ex:AddSlider(id, text, mn, mx, df, callback)
        local sf = Instance.new("Frame"); sf.Size = UDim2.new(1, 0, 0, 28)
        sf.BackgroundTransparency = 1; sf.ZIndex = 8; sf.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 0, 12); l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = TXT2; l.Font = Enum.Font.GothamMedium; l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 8; l.Parent = sf
        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0.4, 0, 0, 12); vl.Position = UDim2.new(0.6, 0, 0, 0)
        vl.BackgroundTransparency = 1; vl.Text = string.format("%.2f", df)
        vl.TextColor3 = Color3.fromRGB(240,240,245); vl.Font = Enum.Font.GothamBold
        vl.TextSize = 10; vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.ZIndex = 8; vl.Parent = sf
        local sb = Instance.new("TextButton")
        sb.Size = UDim2.new(1, 0, 0, 4); sb.Position = UDim2.new(0, 0, 0, 18)
        sb.BackgroundColor3 = Color3.fromRGB(30,30,35); sb.Text = ""
        sb.AutoButtonColor = false; sb.BorderSizePixel = 0; sb.ZIndex = 8; sb.Parent = sf
        Instance.new("UICorner", sb).CornerRadius = UDim.new(1, 0)
        local fl = Instance.new("Frame")
        local iPct = (df - mn) / (mx - mn)
        fl.Size = UDim2.new(iPct, 0, 1, 0); fl.BackgroundColor3 = Color3.fromRGB(240,240,245)
        fl.BorderSizePixel = 0; fl.ZIndex = 8; fl.Parent = sb
        Instance.new("UICorner", fl).CornerRadius = UDim.new(1, 0)
        local tg = Instance.new("Frame")
        tg.Size = UDim2.new(0, 12, 0, 12); tg.Position = UDim2.new(iPct, -6, 0.5, -6)
        tg.BackgroundColor3 = Color3.fromRGB(255,255,255); tg.BorderSizePixel = 0; tg.ZIndex = 9; tg.Parent = sb
        Instance.new("UICorner", tg).CornerRadius = UDim.new(1, 0)
        local tgs = Instance.new("UIStroke"); tgs.Thickness = 1; tgs.Color = Color3.fromRGB(0,0,0)
        tgs.Transparency = 0.6; tgs.Parent = tg
        local cval = df
        local function updV(v)
            local pct = math.clamp((v - mn) / (mx - mn), 0, 1)
            fl.Size = UDim2.new(pct, 0, 1, 0); tg.Position = UDim2.new(pct, -6, 0.5, -6)
            vl.Text = string.format("%.2f", v)
        end
        local function updI(inp)
            local off = math.clamp((inp.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
            cval = mn + (mx - mn) * off; updV(cval); pcall(callback, cval)
        end
        sb.InputBegan:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and activeSlider == nil then
                activeSlider = id; updI(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if activeSlider == id and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updI(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and activeSlider == id then
                activeSlider = nil; saveCur()
            end
        end)
        cr.sliders[id] = {
            Set = function(v) cval = math.clamp(v, mn, mx); updV(cval); pcall(callback, cval) end,
            Get = function() return cval end
        }
    end

    function ex:AddButton(text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = BG3; b.Text = text
        b.TextColor3 = TXT; b.Font = Enum.Font.GothamBold; b.TextSize = 10
        b.AutoButtonColor = false; b.Parent = cc
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local bs = Instance.new("UIStroke"); bs.Color = BRD; bs.Thickness = 1; bs.Parent = b
        b.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    return ex
end

-- ==================================================
-- ВКЛАДКИ
-- ==================================================
local tabsList = {"Movement", "Player", "Combat", "PL Functions", "Players", "Configs", "Settings"}
local tabsOrder = {}
for i, v in ipairs(tabsList) do tabsOrder[v] = i end

for _, name in ipairs(tabsList) do
    mkPage(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 44, 0, 40); b.BackgroundColor3 = BG2
    b.BorderSizePixel = 0; b.Text = ""; b.LayoutOrder = tabsOrder[name]
    b.Parent = TabsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke"); bs.Color = BRD; bs.Thickness = 1; bs.Parent = b
    S.tabs[name] = b
    local im = Instance.new("ImageLabel")
    im.Size = UDim2.new(0, 22, 0, 22); im.Position = UDim2.new(0.5, -11, 0.5, -11)
    im.BackgroundTransparency = 1
    im.Image = icons[name] or "rbxassetid://10723345709"; im.ImageColor3 = TXT2; im.Parent = b
    b.MouseButton1Click:Connect(function() S.curTab = name; updVis() end)
end

-- ==================================================
-- КАРТОЧКИ ПО ВКЛАДКАМ
-- ==================================================

-- MOVEMENT
local c1 = mkCard(S.pages["Movement"], "Walk Speed", {origPage = "Movement"})
c1:AddSlider(1, "Speed Value", 1, 500, 16, function(v)
    S.walkV = v
    if S.walk then local c = LP.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end end
end)
c1:SetToggleCallback(function(s)
    S.walk = s
    local c = LP.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s and S.walkV or 16 end
    startWD(); saveCur()
end)

local c2 = mkCard(S.pages["Movement"], "Jump Power", {origPage = "Movement"})
c2:AddSlider(2, "Power Value", 1, 500, 50, function(v)
    S.jumpV = v
    if S.jump then local c = LP.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end end
end)
c2:SetToggleCallback(function(s)
    S.jump = s
    local c = LP.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = s and S.jumpV or 50 end
    startWD(); saveCur()
end)

local c3 = mkCard(S.pages["Movement"], "Spider", {origPage = "Movement"})
c3:AddSlider(3, "Climb Speed", 1, 20, 3, function(v) S.climbV = v / 10 end)
c3:SetToggleCallback(function(s) S.spider = s; startSpider(); saveCur() end)

local c4 = mkCard(S.pages["Movement"], "Infinite Jump", {origPage = "Movement", content = false})
c4:SetToggleCallback(function(s)
    S.infJump = s
    if s and not S.jumpC then
        S.jumpC = UIS.JumpRequest:Connect(function()
            if not S.infJump then return end
            local c = LP.Character; if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    saveCur()
end)

local c5 = mkCard(S.pages["Movement"], "Vehicle Speed", {origPage = "Movement"})
c5:AddSlider(4, "Speed", 50, 500, 100, function(v) S.vehV = v end)
c5:SetToggleCallback(function(s) S.veh = s; startVeh(); saveCur() end)

-- PLAYER
local p1 = mkCard(S.pages["Player"], "ESP Boxes", {origPage = "Player", content = false})
p1:SetToggleCallback(function(s) S.espBox = s; startBox(); saveCur() end)

local p2 = mkCard(S.pages["Player"], "ESP Names", {origPage = "Player", content = false})
p2:SetToggleCallback(function(s) S.espName = s; startName(); saveCur() end)

local p3 = mkCard(S.pages["Player"], "ESP Lines", {origPage = "Player", content = false})
p3:SetToggleCallback(function(s) S.espLine = s; startLine(); saveCur() end)

local p4 = mkCard(S.pages["Player"], "ESP Team Check", {origPage = "Player", content = false})
p4:SetToggleCallback(function(s) S.espTeam = s; saveCur() end)

local p5 = mkCard(S.pages["Player"], "FOV Changer", {origPage = "Player"})
p5:AddSlider(5, "FOV", 30, 120, 70, function(v)
    S.fovV = v
    if S.fov and WS.CurrentCamera then WS.CurrentCamera.FieldOfView = v end
end)
p5:SetToggleCallback(function(s) S.fov = s; startFOV(); saveCur() end)

local p6 = mkCard(S.pages["Player"], "Fullbright", {origPage = "Player", content = false})
p6:SetToggleCallback(function(s) S.fb = s; startFB(); saveCur() end)

local p7 = mkCard(S.pages["Player"], "Spin", {origPage = "Player"})
p7:AddSlider(6, "Spin Rate", 1, 50, 10, function(v) S.spinV = v end)
p7:SetToggleCallback(function(s) S.spin = s; startSpin(); saveCur() end)

-- COMBAT
local cm1 = mkCard(S.pages["Combat"], "Silent Aim", {origPage = "Combat"})
cm1:AddSlider(7, "FOV", 30, 360, 100, function(v) S.aimFOV = v end)
cm1:AddDropdown(1, "Aim Part", {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}, "Head", function(v) S.aimPart = v end)
cm1:AddSlider(8, "Hit Chance", 1, 100, 100, function(v) S.aimCh = v end)
cm1:SetToggleCallback(function(s) S.aim = s; if s then installAim() end; saveCur() end)

local cm2 = mkCard(S.pages["Combat"], "Silent Team Check", {origPage = "Combat", content = false})
cm2:SetToggleCallback(function(s) S.aimTeam = s; saveCur() end)

local cm3 = mkCard(S.pages["Combat"], "Silent Wall Check", {origPage = "Combat", content = false})
cm3:SetToggleCallback(function(s) S.aimWall = s; saveCur() end)

local cm4 = mkCard(S.pages["Combat"], "Silent Ignore Friends", {origPage = "Combat", content = false})
cm4:SetToggleCallback(function(s) S.aimIgnoreFr = s; saveCur() end)

local cm5 = mkCard(S.pages["Combat"], "Hitbox Expander", {origPage = "Combat"})
cm5:AddSlider(9, "Size x", 1, 10, 3, function(v) S.hbV = v end)
cm5:SetToggleCallback(function(s) S.hb = s; startHB(); saveCur() end)

local cm6 = mkCard(S.pages["Combat"], "Hitbox Team Check", {origPage = "Combat", content = false})
cm6:SetToggleCallback(function(s) S.hbTeam = s; saveCur() end)

local cm7 = mkCard(S.pages["Combat"], "Hitbox Ignore Friends", {origPage = "Combat", content = false})
cm7:SetToggleCallback(function(s) S.hbIgnoreFr = s; saveCur() end)

local cm8 = mkCard(S.pages["Combat"], "Hitbox Visual", {origPage = "Combat", content = false})
cm8:SetToggleCallback(function(s) S.hbVis = s; if S.hb then startHB() end; saveCur() end)

local cm9 = mkCard(S.pages["Combat"], "Infinite Ammo", {origPage = "Combat", content = false})
cm9:SetToggleCallback(function(s) S.ammo = s; startWP(); saveCur() end)

local cm10 = mkCard(S.pages["Combat"], "Rapid Fire", {origPage = "Combat", content = false})
cm10:SetToggleCallback(function(s) S.rapid = s; startWP(); saveCur() end)

local cm11 = mkCard(S.pages["Combat"], "Instant Reload", {origPage = "Combat", content = false})
cm11:SetToggleCallback(function(s) S.reload = s; startWP(); saveCur() end)

-- PL FUNCTIONS
local pl1 = mkCard(S.pages["PL Functions"], "Auto Keycard", {origPage = "PL Functions"})
pl1:AddSlider(10, "Range", 10, 100, 20, function(v) S.keyR = v end)
pl1:SetToggleCallback(function(s) S.keycard = s; startKey(); saveCur() end)

local pl2 = mkCard(S.pages["PL Functions"], "Arrest Aura", {origPage = "PL Functions"})
pl2:AddSlider(11, "Range", 1, 15, 7.5, function(v) S.arrestR = v end)
pl2:SetToggleCallback(function(s) S.arrest = s; startArrest(); saveCur() end)

local pl3 = mkCard(S.pages["PL Functions"], "Melee Aura", {origPage = "PL Functions"})
pl3:AddSlider(12, "Range", 1, 9, 4, function(v) S.meleeR = v end)
pl3:SetToggleCallback(function(s) S.melee = s; startMelee(); saveCur() end)

local pl4 = mkCard(S.pages["PL Functions"], "Anti-Taze", {origPage = "PL Functions", content = false})
pl4:SetToggleCallback(function(s) S.antiTaze = s; startAT(); saveCur() end)

local pl5 = mkCard(S.pages["PL Functions"], "Auto Get Gun", {origPage = "PL Functions", content = false})
pl5:SetToggleCallback(function(s) S.autoGun = s; startAG(); saveCur() end)

-- Item Giver (без свитча, только кнопки)
local pl6 = mkCard(S.pages["PL Functions"], "Item Giver", {origPage = "PL Functions", hasToggle = false})
pl6:AddButton("🎁 Получить M4A1", function() getGun("M4A1") end)
pl6:AddButton("🎁 Получить Remington 870", function() getGun("Remington 870") end)
pl6:AddButton("🎁 Получить AK-47", function() getGun("AK-47") end)
pl6:AddButton("🎁 Получить MP5", function() getGun("MP5") end)

-- Teleports (без свитча, только кнопки)
local pl7 = mkCard(S.pages["PL Functions"], "Teleports", {origPage = "PL Functions", hasToggle = false})
local tps = {
    ["Оружейная"] = Vector3.new(826.20, 101.46, 2294.85),
    ["Кафетерий"] = Vector3.new(924.52, 101.48, 2227.59),
    ["База преступников"] = Vector3.new(-975.03, 109.82, 2057.95),
    ["Секретная комната"] = Vector3.new(701.45, 101.45, 2354.30),
    ["Двор"] = Vector3.new(795.78, 99.65, 2541.00),
    ["Внутри тюрьмы"] = Vector3.new(915.29, 101.49, 2388.00),
}
for name, pos in pairs(tps) do
    pl7:AddButton("📍 " .. name, function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
    end)
end

-- PLAYERS (список с аватарками)
local playersPage = S.pages["Players"]
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, 0, 1, 0)
listFrame.BackgroundTransparency = 1
listFrame.Parent = playersPage.Frame

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(1, 0, 1, 0)
listScroll.BackgroundTransparency = 1
listScroll.ScrollBarThickness = 4
listScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50)
listScroll.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = listScroll

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 150, 0, 30)
refreshBtn.Position = UDim2.new(0, 5, 0, 5)
refreshBtn.BackgroundColor3 = AC
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 11
refreshBtn.AutoButtonColor = false
refreshBtn.Parent = listScroll
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

local function refreshPlayers()
    for _, ch in ipairs(listScroll:GetChildren()) do
        if ch:IsA("TextButton") and ch ~= refreshBtn then ch:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 48)
        row.BackgroundColor3 = Color3.fromRGB(20,20,26)
        row.BorderSizePixel = 0
        row.Parent = listScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rStr = Instance.new("UIStroke"); rStr.Color = BRD; rStr.Thickness = 1; rStr.Parent = row

        local av = Instance.new("ImageLabel")
        av.Size = UDim2.new(0, 36, 0, 36); av.Position = UDim2.new(0, 6, 0.5, -18)
        av.BackgroundColor3 = BG2; av.BorderSizePixel = 0
        av.Parent = row
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and thumb and av.Parent then av.Image = thumb end
        end)

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, -150, 0, 16); nm.Position = UDim2.new(0, 48, 0, 6)
        nm.BackgroundTransparency = 1; nm.Text = p.Name
        nm.TextColor3 = TXT; nm.Font = Enum.Font.GothamBold
        nm.TextSize = 12; nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.Parent = row

        local st = Instance.new("TextLabel")
        st.Size = UDim2.new(1, -150, 0, 14); st.Position = UDim2.new(0, 48, 0, 24)
        st.BackgroundTransparency = 1; st.Text = "..."
        st.TextColor3 = TXT2; st.Font = Enum.Font.Gotham
        st.TextSize = 10; st.TextXAlignment = Enum.TextXAlignment.Left
        st.Parent = row

        local hpC
        hpC = RS.Heartbeat:Connect(function()
            if not row.Parent then hpC:Disconnect() return end
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local tn = p.Team and p.Team.Name or "Нет команды"
            if h then
                if h.Health > 0 then
                    st.Text = string.format("❤ %d | %s", math.floor(h.Health), tn)
                    st.TextColor3 = GREEN
                else
                    st.Text = "☠ Мёртв | " .. tn
                    st.TextColor3 = RED
                end
            else
                st.Text = tn; st.TextColor3 = TXT2
            end
        end)

        local tpB = Instance.new("TextButton")
        tpB.Size = UDim2.new(0, 64, 0, 30); tpB.Position = UDim2.new(1, -72, 0.5, -15)
        tpB.BackgroundColor3 = AC; tpB.Text = "TP"
        tpB.TextColor3 = Color3.fromRGB(255,255,255)
        tpB.Font = Enum.Font.GothamBold; tpB.TextSize = 11
        tpB.AutoButtonColor = false; tpB.Parent = row
        Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 6)
        tpB.MouseButton1Click:Connect(function()
            if p.Character then
                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hr and mr then mr.CFrame = CFrame.new(hr.Position + Vector3.new(0, 3, 0)) end
            end
        end)
    end
    if #Players:GetPlayers() <= 1 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -10, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "На сервере нет других игроков"
        empty.TextColor3 = TXT2; empty.Font = Enum.Font.Gotham
        empty.TextSize = 12; empty.Parent = listScroll
    end
end

refreshBtn.MouseButton1Click:Connect(refreshPlayers)
Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) refreshPlayers() end)

-- CONFIGS (полноценная система)
local cfgPage = S.pages["Configs"]
local nameInp = Instance.new("TextBox")
nameInp.Size = UDim2.new(0, 200, 0, 32); nameInp.Position = UDim2.new(0, 5, 0, 5)
nameInp.BackgroundColor3 = Color3.fromRGB(24,24,30)
nameInp.PlaceholderText = "Имя конфига..."
nameInp.PlaceholderColor3 = TXT2
nameInp.Text = ""; nameInp.TextColor3 = TXT
nameInp.Font = Enum.Font.Gotham; nameInp.TextSize = 12
nameInp.Parent = cfgPage.Frame
Instance.new("UICorner", nameInp).CornerRadius = UDim.new(0, 6)
local nStr = Instance.new("UIStroke"); nStr.Color = BRD; nStr.Thickness = 1; nStr.Parent = nameInp

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 120, 0, 32); saveBtn.Position = UDim2.new(0, 215, 0, 5)
saveBtn.BackgroundColor3 = GREEN; saveBtn.Text = "💾 Сохранить"
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 11
saveBtn.AutoButtonColor = false; saveBtn.Parent = cfgPage.Frame
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local listCfg = Instance.new("ScrollingFrame")
listCfg.Size = UDim2.new(1, -10, 1, -50); listCfg.Position = UDim2.new(0, 5, 0, 45)
listCfg.BackgroundTransparency = 1
listCfg.ScrollBarThickness = 4
listCfg.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50)
listCfg.Parent = cfgPage.Frame
local listCfgL = Instance.new("UIListLayout")
listCfgL.Padding = UDim.new(0, 6); listCfgL.Parent = listCfg

local function rebuildCfgList()
    for _, ch in ipairs(listCfg:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    for name, _ in pairs(S.configs) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Color3.fromRGB(20,20,26)
        row.BorderSizePixel = 0; row.Parent = listCfg
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local rs = Instance.new("UIStroke"); rs.Color = BRD; rs.Thickness = 1; rs.Parent = row

        local nl = Instance.new("TextLabel")
        nl.Size = UDim2.new(1, -180, 1, 0); nl.Position = UDim2.new(0, 12, 0, 0)
        nl.BackgroundTransparency = 1; nl.Text = name
        nl.TextColor3 = TXT; nl.Font = Enum.Font.GothamBold
        nl.TextSize = 12; nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.Parent = row

        local lb = Instance.new("TextButton")
        lb.Size = UDim2.new(0, 75, 0, 28); lb.Position = UDim2.new(1, -165, 0.5, -14)
        lb.BackgroundColor3 = AC; lb.Text = "📂 Load"
        lb.TextColor3 = Color3.fromRGB(255,255,255)
        lb.Font = Enum.Font.GothamBold; lb.TextSize = 10
        lb.AutoButtonColor = false; lb.Parent = row
        Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)

        local db = Instance.new("TextButton")
        db.Size = UDim2.new(0, 75, 0, 28); db.Position = UDim2.new(1, -85, 0.5, -14)
        db.BackgroundColor3 = RED; db.Text = "🗑 Delete"
        db.TextColor3 = Color3.fromRGB(255,255,255)
        db.Font = Enum.Font.GothamBold; db.TextSize = 10
        db.AutoButtonColor = false; db.Parent = row
        Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)

        lb.MouseButton1Click:Connect(function()
            local d = S.configs[name]
            if d then
                applyCfg(d)
                startAll()
                syncUI()
                saveCur()
            end
        end)
        db.MouseButton1Click:Connect(function()
            S.configs[name] = nil
            saveAll()
            rebuildCfgList()
        end)
    end
end

saveBtn.MouseButton1Click:Connect(function()
    local n = nameInp.Text
    if n == "" then return end
    S.configs[n] = getCfg()
    nameInp.Text = ""
    saveAll()
    rebuildCfgList()
end)

-- ==================================================
-- СИНХРОНИЗАЦИЯ UI С СОСТОЯНИЕМ
-- ==================================================
local function syncUI()
    for _, cr in ipairs(S.cards) do
        if cr.name == "Walk Speed" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.walk, false) end
            if cr.sliders[1] then cr.sliders[1].Set(S.walkV) end
        elseif cr.name == "Jump Power" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.jump, false) end
            if cr.sliders[2] then cr.sliders[2].Set(S.jumpV) end
        elseif cr.name == "Spider" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.spider, false) end
            if cr.sliders[3] then cr.sliders[3].Set(S.climbV * 10) end
        elseif cr.name == "Infinite Jump" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.infJump, false) end
        elseif cr.name == "Vehicle Speed" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.veh, false) end
            if cr.sliders[4] then cr.sliders[4].Set(S.vehV) end
        elseif cr.name == "ESP Boxes" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.espBox, false) end
        elseif cr.name == "ESP Names" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.espName, false) end
        elseif cr.name == "ESP Lines" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.espLine, false) end
        elseif cr.name == "ESP Team Check" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.espTeam, false) end
        elseif cr.name == "FOV Changer" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.fov, false) end
            if cr.sliders[5] then cr.sliders[5].Set(S.fovV) end
        elseif cr.name == "Fullbright" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.fb, false) end
        elseif cr.name == "Spin" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.spin, false) end
            if cr.sliders[6] then cr.sliders[6].Set(S.spinV) end
        elseif cr.name == "Silent Aim" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.aim, false) end
            if cr.sliders[7] then cr.sliders[7].Set(S.aimFOV) end
            if cr.dropdowns[1] then cr.dropdowns[1].Set(S.aimPart) end
            if cr.sliders[8] then cr.sliders[8].Set(S.aimCh) end
        elseif cr.name == "Silent Team Check" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.aimTeam, false) end
        elseif cr.name == "Silent Wall Check" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.aimWall, false) end
        elseif cr.name == "Silent Ignore Friends" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.aimIgnoreFr, false) end
        elseif cr.name == "Hitbox Expander" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.hb, false) end
            if cr.sliders[9] then cr.sliders[9].Set(S.hbV) end
        elseif cr.name == "Hitbox Team Check" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.hbTeam, false) end
        elseif cr.name == "Hitbox Ignore Friends" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.hbIgnoreFr, false) end
        elseif cr.name == "Hitbox Visual" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.hbVis, false) end
        elseif cr.name == "Infinite Ammo" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.ammo, false) end
        elseif cr.name == "Rapid Fire" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.rapid, false) end
        elseif cr.name == "Instant Reload" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.reload, false) end
        elseif cr.name == "Auto Keycard" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.keycard, false) end
            if cr.sliders[10] then cr.sliders[10].Set(S.keyR) end
        elseif cr.name == "Arrest Aura" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.arrest, false) end
            if cr.sliders[11] then cr.sliders[11].Set(S.arrestR) end
        elseif cr.name == "Melee Aura" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.melee, false) end
            if cr.sliders[12] then cr.sliders[12].Set(S.meleeR) end
        elseif cr.name == "Anti-Taze" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.antiTaze, false) end
        elseif cr.name == "Auto Get Gun" then
            if cr.toggles.Main then cr.toggles.Main.Set(S.autoGun, false) end
        end
    end
end

local function startAll()
    startSpin(); startSpider(); startBox(); startName(); startLine()
    startAT(); startKey(); startHB(); startArrest(); startMelee(); startAG()
    startFOV(); startFB(); startVeh(); startWP()
    if S.aim then installAim() end
end

-- ==================================================
-- СТАРТ
-- ==================================================
loadAll()
loadCur()
startAll()
rebuildCfgList()
refreshPlayers()

task.wait(0.3)
for _, tn in ipairs(tabsList) do
    if S.pages[tn] then arr(S.pages[tn]) end
end
updVis()
syncUI()

local function onChar(char)
    char:WaitForChild("Humanoid", 5)
    task.wait(0.3)
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if S.walk then h.WalkSpeed = S.walkV end
    if S.jump then
        if h.UseJumpPower then h.JumpPower = S.jumpV
        else h.JumpHeight = S.jumpV / 7.5 end
    end
    startAll()
end

LP.CharacterAdded:Connect(onChar)
if LP.Character then task.spawn(onChar, LP.Character) end

startWD()

task.spawn(function()
    while true do
        task.wait(10)
        saveCur()
    end
end)

print("✨ ALPHA HUB PRISON LIFE — загружено!")