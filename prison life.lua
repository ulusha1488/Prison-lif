--[[ ALPHA HUB · PRISON LIFE ]]
if game.PlaceId ~= 155615604 then
    game.Players.LocalPlayer:Kick("❌ ALPHA HUB\n\nТолько для Prison Life!")
    return
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local WS = game:GetService("Workspace")
local LT = game:GetService("Lighting")
local R = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("AlphaPL") then PG.AlphaPL:Destroy() end

local S = {
    draw=false, file=false, hook=false, fgc=false, gc=false,
    walk=false, walkV=16, jump=false, jumpV=50, ij=false, ijC=nil, wd=nil,
    spin=false, spinV=10, spinC=nil, humSave=nil,
    eT=true, eB=false, eN=false, eL=false, bC=nil, nC=nil, lC=nil,
    BX={}, NM={}, LN={},
    spd=false, spdC=nil, wallHit=false, climbV=0.28, boost=22,
    atz=false, atzC={},
    kc=false, kcC=nil, kcR=20,
    getting=false, ag=false,
    guns={["M4A1"]=false,["Remington 870"]=false,["AK-47"]=false,["MP5"]=false},
    aim=false, aimT=true, aimW=true, aimF=100, aimR=300, aimP="Head", aimC=100,
    aimFr=false, aimHooked=false, oldCR=nil, frCache={}, tgt=nil,
    hb=false, hbV=3, hbVis=true, hbT=false, hbFr=false, hbC=nil, hbSave={},
    arr=false, arrR=7.5, arrFr=false, arrC=nil,
    mel=false, melR=4, melFr=false, melC=nil,
    fov=false, fovV=70, fovC=nil,
    fb=false, fbC=nil, fbSave={},
    veh=false, vehV=100, vehC=nil,
    ammo=false, rapid=false, reload=false, wpC=nil,
    cfg={}, cfgName="",
    pages={}, tabs={}, cards={}, cardMap={}, curTab="Movement",
    rem={},
}

pcall(function() if Drawing and Drawing.new then local t=Drawing.new("Square"); t:Remove(); S.draw=true end end)
pcall(function() if writefile and readfile and isfile then S.file=true end end)
pcall(function() if hookfunction and getgc then S.hook=true end end)
pcall(function() if filtergc then local ok,f=pcall(filtergc,"function",{Name="castRay"},true); S.fgc=ok and f~=nil end end)
pcall(function() if getconnections then S.gc=true end end)

local cam = WS.CurrentCamera
while not cam do RS.RenderStepped:Wait(); cam=WS.CurrentCamera end
local defFOV = cam.FieldOfView

pcall(function()
    local G = R:FindFirstChild("GunRemotes")
    if G then S.rem.shoot=G:FindFirstChild("ShootEvent"); S.rem.taze=G:FindFirstChild("PlayerTased") end
    local Rm = R:FindFirstChild("Remotes")
    if Rm then S.rem.arrest=Rm:FindFirstChild("ArrestPlayer") end
    S.rem.melee = R:FindFirstChild("meleeEvent")
end)

-- ===== ЦВЕТА (мои, чёрные) =====
local BG = Color3.fromRGB(10,10,12)
local BG2 = Color3.fromRGB(18,18,22)
local BG3 = Color3.fromRGB(26,26,32)
local BG4 = Color3.fromRGB(36,36,44)
local SB = Color3.fromRGB(7,7,9)
local AC = Color3.fromRGB(0,200,255)
local AC2 = Color3.fromRGB(130,90,255)
local GN = Color3.fromRGB(80,220,130)
local RD = Color3.fromRGB(255,90,110)
local TX = Color3.fromRGB(240,240,245)
local T2 = Color3.fromRGB(130,135,150)
local BD = Color3.fromRGB(35,38,48)

local function isFr(uid)
    if S.frCache[uid]~=nil then return S.frCache[uid] end
    local ok,res = pcall(function() return LP:IsFriendsWith(uid) end)
    S.frCache[uid] = ok and res or false
    return S.frCache[uid]
end

local function tw(o,t,p)
    local a = TS:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
    a:Play(); return a
end

-- ===== ФУНКЦИИ =====
local function startWD()
    if S.wd then S.wd:Disconnect() end
    S.wd = RS.Heartbeat:Connect(function()
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

local function getTools()
    local t={}
    local c=LP.Character
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
            local e=getsenv(gs)
            if e then
                if S.ammo then e.MaxAmmo=math.huge; e.StoredAmmo=math.huge end
                if S.rapid then e.FireRate=0.0001; e.AutoFire=true end
                if S.reload then e.ReloadTime=0.0001 end
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

local function getGun(name)
    if S.getting then return end
    S.getting=true
    local c=LP.Character
    local rt=c and c:FindFirstChild("HumanoidRootPart")
    if not (c and rt) or c:FindFirstChild("ForceField") then S.getting=false return end
    if LP.Backpack:FindFirstChild(name) or c:FindFirstChild(name) then S.getting=false return end
    local g
    for _,v in ipairs(WS:GetDescendants()) do
        if v.Name=="TouchGiver" and v:GetAttribute("ToolName")==name then
            g=v:FindFirstChildWhichIsA("BasePart"); break
        end
    end
    if not g then S.getting=false return end
    local ocf=g.CFrame; local oc=rt.CFrame
    local ug=ocf-Vector3.new(0,15.5,0)
    g.CanTouch=true; g.CFrame=ug
    c:PivotTo(ug+Vector3.new(0,5,0))
    task.wait(0.25); pcall(function() firetouchinterest(g,rt,0) end)
    task.wait(0.3); pcall(function() firetouchinterest(g,rt,1) end)
    task.wait(0.05)
    g.CFrame=ocf; c:PivotTo(oc)
    task.wait(0.1)
    S.getting=false
end

local function startAG()
    if not S.ag then return end
    task.spawn(function()
        while S.ag do
            task.wait(1)
            for n,e in pairs(S.guns) do if e then getGun(n) end end
        end
    end)
end

local function arrbl(P)
    if not P.Character then return false end
    local h=P.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then return false end
    if P.Team and P.Team.Name=="Criminals" then return true end
    local d=h.DisplayName
    return d:find("🔗",1,true) or d:find("💢",1,true)
end

local function startArr()
    if S.arrC then S.arrC:Disconnect() end
    if not S.arr or not S.rem.arrest then return end
    S.arrC=RS.Heartbeat:Connect(function()
        local c=LP.Character
        local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,P in ipairs(Players:GetPlayers()) do
            if P==LP or not P.Character then continue end
            if S.arrFr and isFr(P.UserId) then continue end
            if arrbl(P) then
                local hr=P.Character:FindFirstChild("HumanoidRootPart")
                if hr and (rt.Position-hr.Position).Magnitude<=S.arrR then
                    pcall(function() S.rem.arrest:InvokeServer(P) end)
                end
            end
        end
    end)
end

local function startMel()
    if S.melC then S.melC:Disconnect() end
    if not S.mel or not S.rem.melee then return end
    S.melC=RS.Heartbeat:Connect(function()
        local c=LP.Character
        local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,P in ipairs(Players:GetPlayers()) do
            if P==LP or not P.Character then continue end
            if S.melFr and isFr(P.UserId) then continue end
            local hr=P.Character:FindFirstChild("HumanoidRootPart")
            local h=P.Character:FindFirstChildOfClass("Humanoid")
            if hr and h and h.Health>0 and (rt.Position-hr.Position).Magnitude<=S.melR then
                pcall(function() S.rem.melee:FireServer(P) end)
            end
        end
    end)
end

local function startAT()
    if not S.gc or not S.rem.taze then return end
    if S.atz then
        pcall(function()
            for _,cn in pairs(getconnections(S.rem.taze.OnClientEvent)) do
                pcall(function() cn:Disable(); table.insert(S.atzC,cn) end)
            end
        end)
    else
        for _,cn in ipairs(S.atzC) do pcall(function() cn:Enable() end) end
        S.atzC={}
    end
end

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
    if S.aimFr and isFr(P.UserId) then return false end
    if S.aimT and LP.Team and P.Team==LP.Team then return false end
    return true
end

local function closest()
    local best,bd=nil,S.aimF
    local ctr=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local org=cam.CFrame.Position
    for _,P in ipairs(Players:GetPlayers()) do
        if P==LP then continue end
        if not canAim(P) then continue end
        local C=P.Character
        local part=C:FindFirstChild(S.aimP) or C:FindFirstChild("Head")
        if not part then continue end
        if (org-part.Position).Magnitude>S.aimR then continue end
        local pos,on=cam:WorldToViewportPoint(part.Position)
        if not on then continue end
        if (part.Position-org):Dot(cam.CFrame.LookVector)<=0 then continue end
        if S.aimW and not vis(part,org) then continue end
        local d=(Vector2.new(pos.X,pos.Y)-ctr).Magnitude
        if d<bd then bd=d; best=P end
    end
    return best
end

local function didHit() return math.random(1,100)<=S.aimC end

local function missOff(pp,org)
    local d=(pp-org).Magnitude
    local sc=math.clamp(d/3,3,4)
    return Vector3.new(math.random(-sc*10,sc*10)/10,math.random(-sc*10,sc*10)/10,math.random(-sc*10,sc*10)/10)
end

local function installAim()
    if S.aimHooked or not S.hook then return end
    local cr
    if S.fgc then pcall(function() cr=filtergc("function",{Name="castRay"},true) end) end
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
            if S.aim and S.tgt and S.tgt.Character then
                local p=S.tgt.Character:FindFirstChild(S.aimP)
                if p then
                    if didHit() then a[2]=p.Position
                    else
                        local mp=S.tgt.Character:FindFirstChild("LeftLeg") or S.tgt.Character:FindFirstChild("RightLeg")
                        if mp and typeof(a[1])=="Vector3" then a[2]=mp.Position+missOff(mp.Position,a[1]) end
                    end
                end
            end
            return S.oldCR(table.unpack(a))
        end)
    end)
end

RS.Heartbeat:Connect(function() if S.aim then S.tgt=closest() end end)

local function startSpin()
    if S.spinC then S.spinC:Disconnect() end
    local c=LP.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not S.spin then
        if h and S.humSave then
            h.AutoRotate=S.humSave.AutoRotate; h.CameraOffset=S.humSave.CameraOffset
            S.humSave=nil
        end
        return
    end
    if h then
        S.humSave={AutoRotate=h.AutoRotate,CameraOffset=h.CameraOffset}
        h.AutoRotate=false
    end
    S.spinC=RS.Stepped:Connect(function()
        local ch=LP.Character; if not ch then return end
        local hu=ch:FindFirstChildOfClass("Humanoid")
        local rp2=ch:FindFirstChild("HumanoidRootPart")
        if not rp2 then return end
        if hu and hu.AutoRotate then hu.AutoRotate=false end
        rp2.CFrame=rp2.CFrame*CFrame.Angles(0,math.rad(S.spinV),0)
    end)
end

local function mkBox(t)
    if not S.draw or t==LP or S.BX[t] then return end
    local b=Drawing.new("Square")
    b.Thickness=1.5; b.Color=AC; b.Filled=false; b.Visible=false; b.Transparency=1
    S.BX[t]=b
end
local function rmBox(t) if S.BX[t] then pcall(function() S.BX[t]:Remove() end) end S.BX[t]=nil end

local function startBox()
    if S.bC then S.bC:Disconnect() end
    if not S.eB or not S.draw then for t in pairs(S.BX) do rmBox(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkBox(p) end end
    S.bC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local b=S.BX[p]; if not b then mkBox(p) continue end
            local c=p.Character
            local hr=c and c:FindFirstChild("HumanoidRootPart")
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.eT and LP.Team and p.Team==LP.Team)
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
    if not S.draw or t==LP or S.NM[t] then return end
    local n=Drawing.new("Text")
    n.Size=14; n.Center=true; n.Outline=true; n.Color=Color3.fromRGB(255,255,255)
    n.OutlineColor=Color3.fromRGB(0,0,0); n.Visible=false; n.Font=2; n.Text=t.Name
    S.NM[t]=n
end
local function rmName(t) if S.NM[t] then pcall(function() S.NM[t]:Remove() end) end S.NM[t]=nil end

local function startName()
    if S.nC then S.nC:Disconnect() end
    if not S.eN or not S.draw then for t in pairs(S.NM) do rmName(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkName(p) end end
    S.nC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local n=S.NM[p]; if not n then mkName(p) continue end
            local c=p.Character
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.eT and LP.Team and p.Team==LP.Team)
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
    if not S.draw or t==LP or S.LN[t] then return end
    local l=Drawing.new("Line")
    l.Thickness=1; l.Color=AC2; l.Visible=false
    S.LN[t]=l
end
local function rmLine(t) if S.LN[t] then pcall(function() S.LN[t]:Remove() end) end S.LN[t]=nil end

local function startLine()
    if S.lC then S.lC:Disconnect() end
    if not S.eL or not S.draw then for t in pairs(S.LN) do rmLine(t) end return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkLine(p) end end
    S.lC=RS.RenderStepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local l=S.LN[p]; if not l then mkLine(p) continue end
            local c=p.Character
            local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local show = not (S.eT and LP.Team and p.Team==LP.Team)
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

local function startSpider()
    if S.spdC then S.spdC:Disconnect() end
    if not S.spd then S.wallHit=false return end
    S.spdC=RS.PreRender:Connect(function()
        local c=LP.Character; if not c then S.wallHit=false return end
        local rt=c:FindFirstChild("HumanoidRootPart")
        local h=c:FindFirstChildOfClass("Humanoid")
        if not rt or not h or h.Health<=0 then S.wallHit=false return end
        if h.MoveDirection.Magnitude<=0.1 then S.wallHit=false return end
        local rp2=RaycastParams.new()
        rp2.FilterDescendantsInstances={c}; rp2.FilterType=Enum.RaycastFilterType.Exclude
        local dir=rt.CFrame.LookVector*2.5
        local hit=WS:Raycast(rt.Position,dir,rp2) or WS:Raycast(rt.Position-rt.CFrame.RightVector*1.1,dir,rp2) or WS:Raycast(rt.Position+rt.CFrame.RightVector*1.1,dir,rp2)
        if hit then
            rt.CFrame=rt.CFrame+Vector3.new(0,S.climbV,0)+(rt.CFrame.LookVector*0.05)
            if rt.AssemblyLinearVelocity.Y<0 then rt.AssemblyLinearVelocity=Vector3.new(rt.AssemblyLinearVelocity.X,2,rt.AssemblyLinearVelocity.Z) end
            S.wallHit=true
        else
            if S.wallHit then
                S.wallHit=false
                local fwd=rt.CFrame.LookVector
                rt.AssemblyLinearVelocity=Vector3.new(fwd.X*S.boost*0.68,S.boost,fwd.Z*S.boost*0.68)
                rt.CFrame=rt.CFrame+Vector3.new(0,1.5,0)+(fwd*0.5)
            end
        end
    end)
end

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
    if S.kcC then S.kcC:Disconnect() end
    if not S.kc then return end
    S.kcC=RS.Heartbeat:Connect(function()
        if not isCrim() or hasKey() then return end
        local c=LP.Character
        local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,o in ipairs(WS:GetDescendants()) do
            if o:IsA("Tool") or o:IsA("BasePart") or o:IsA("Model") then
                local n=o.Name:lower()
                if n:find("keycard") or n:find("key card") or n:find("key_card") then
                    local p=o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                    if p and (p.Position-rt.Position).Magnitude<S.kcR then
                        rt.CFrame=CFrame.new(p.Position+Vector3.new(0,3,0))
                    end
                end
            end
        end
    end)
end

local function hbP(c)
    if not c then return {} end
    local t={}
    for _,n in ipairs({"Head","HumanoidRootPart","UpperTorso","Torso"}) do
        local p=c:FindFirstChild(n); if p then table.insert(t,p) end
    end
    return t
end
local function hbA(P)
    local c=P.Character; if not c then return end
    for _,p in ipairs(hbP(c)) do
        if not S.hbSave[p] then
            S.hbSave[p]={Size=p.Size,Transparency=p.Transparency,CanCollide=p.CanCollide,Material=p.Material,Color=p.Color}
        end
        p.Size=S.hbSave[p].Size*S.hbV
        p.CanCollide=false
        if S.hbVis then p.Transparency=0.5; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(255,100,100) end
    end
end
local function hbR(P)
    local c=P.Character; if not c then return end
    for _,p in ipairs(hbP(c)) do
        local sv=S.hbSave[p]
        if sv then
            p.Size=sv.Size; p.Transparency=sv.Transparency; p.CanCollide=sv.CanCollide
            p.Material=sv.Material; p.Color=sv.Color; S.hbSave[p]=nil
        end
    end
end
local function hbS(P)
    local C=P.Character; if not C then return false end
    local H=C:FindFirstChildOfClass("Humanoid")
    if not H or H.Health<=0 then return false end
    if S.hbFr and isFr(P.UserId) then return false end
    if S.hbT and LP.Team and P.Team==LP.Team then return false end
    return true
end
local function hbV(P)
    local c=P.Character
    if not c or not c.Parent then return end
    if S.hb and hbS(P) then
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
            hbR(p)
            local c=p.Character; if c and c:FindFirstChild("HitboxHighlight") then c.HitboxHighlight:Destroy() end
        end
        S.hbSave={}; return
    end
    S.hbC=RS.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            if hbS(p) then hbA(p) else hbR(p) end
            hbV(p)
        end
    end)
end

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
        for k,v in pairs(S.fbSave) do pcall(function() LT[k]=v end) end
        S.fbSave={}; return
    end
    S.fbSave={Ambient=LT.Ambient,OutdoorAmbient=LT.OutdoorAmbient,Brightness=LT.Brightness,
        ClockTime=LT.ClockTime,FogEnd=LT.FogEnd,FogStart=LT.FogStart,GlobalShadows=LT.GlobalShadows}
    S.fbC=RS.Heartbeat:Connect(function()
        if not S.fb then return end
        LT.Ambient=Color3.fromRGB(200,200,200); LT.OutdoorAmbient=Color3.fromRGB(200,200,200)
        LT.Brightness=3; LT.ClockTime=14; LT.FogEnd=100000; LT.FogStart=100000; LT.GlobalShadows=false
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
    return {walk=S.walk,walkV=S.walkV,jump=S.jump,jumpV=S.jumpV,ij=S.ij,spin=S.spin,spinV=S.spinV,
        eT=S.eT,eB=S.eB,eN=S.eN,eL=S.eL,spd=S.spd,climbV=S.climbV,boost=S.boost,
        atz=S.atz,kc=S.kc,kcR=S.kcR,ag=S.ag,guns=S.guns,
        aim=S.aim,aimT=S.aimT,aimW=S.aimW,aimF=S.aimF,aimR=S.aimR,aimP=S.aimP,aimC=S.aimC,aimFr=S.aimFr,
        hb=S.hb,hbV=S.hbV,hbVis=S.hbVis,hbT=S.hbT,hbFr=S.hbFr,
        arr=S.arr,arrR=S.arrR,arrFr=S.arrFr,mel=S.mel,melR=S.melR,melFr=S.melFr,
        fov=S.fov,fovV=S.fovV,fb=S.fb,veh=S.veh,vehV=S.vehV,
        ammo=S.ammo,rapid=S.rapid,reload=S.reload}
end
local function applyCfg(d)
    if not d then return end
    S.walk=d.walk or false; S.walkV=d.walkV or 16
    S.jump=d.jump or false; S.jumpV=d.jumpV or 50
    S.ij=d.ij or false; S.spin=d.spin or false; S.spinV=d.spinV or 10
    S.eT=d.eT~=false; S.eB=d.eB or false; S.eN=d.eN or false; S.eL=d.eL or false
    S.spd=d.spd or false; S.climbV=d.climbV or 0.28; S.boost=d.boost or 22
    S.atz=d.atz or false; S.kc=d.kc or false; S.kcR=d.kcR or 20
    S.ag=d.ag or false; S.guns=d.guns or S.guns
    S.aim=d.aim or false; S.aimT=d.aimT~=false; S.aimW=d.aimW~=false
    S.aimF=d.aimF or 100; S.aimR=d.aimR or 300; S.aimP=d.aimP or "Head"; S.aimC=d.aimC or 100
    S.aimFr=d.aimFr or false
    S.hb=d.hb or false; S.hbV=d.hbV or 3; S.hbVis=d.hbVis~=false
    S.hbT=d.hbT or false; S.hbFr=d.hbFr or false
    S.arr=d.arr or false; S.arrR=d.arrR or 7.5; S.arrFr=d.arrFr or false
    S.mel=d.mel or false; S.melR=d.melR or 4; S.melFr=d.melFr or false
    S.fov=d.fov or false; S.fovV=d.fovV or 70; S.fb=d.fb or false
    S.veh=d.veh or false; S.vehV=d.vehV or 100
    S.ammo=d.ammo or false; S.rapid=d.rapid or false; S.reload=d.reload or false
end
local function saveCur()
    if not S.file then return end
    pcall(function() writefile("AlphaPL_S.json",HS:JSONEncode(getCfg())) end)
end
local function loadCur()
    if not S.file then return end
    if isfile("AlphaPL_S.json") then pcall(function() applyCfg(HS:JSONDecode(readfile("AlphaPL_S.json"))) end) end
end
local function saveAll()
    if not S.file then return end
    pcall(function() writefile("AlphaPL_C.json",HS:JSONEncode(S.cfg)) end)
end
local function loadAll()
    if not S.file then return end
    if isfile("AlphaPL_C.json") then pcall(function() S.cfg=HS:JSONDecode(readfile("AlphaPL_C.json")) end) end
end

local function startAll()
    startSpin(); startSpider(); startBox(); startName(); startLine()
    startAT(); startKey(); startHB(); startArr(); startMel(); startAG()
    startFOV(); startFB(); startVeh(); startWP()
    if S.aim then installAim() end
end

-- ===== UI =====
local SG = Instance.new("ScreenGui")
SG.Name="AlphaPL"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=PG

local Main = Instance.new("Frame")
Main.Size=UDim2.new(0,720,0,450); Main.Position=UDim2.new(0.5,-360,0.5,-225)
Main.BackgroundColor3=BG; Main.BorderSizePixel=0; Main.Active=true
Main.ClipsDescendants=true; Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local MS=Instance.new("UIStroke"); MS.Color=BD; MS.Thickness=1.2; MS.Parent=Main

local drag,dS,sP
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true; dS=i.Position; sP=Main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dS
        Main.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

local Side = Instance.new("Frame")
Side.Size=UDim2.new(0,80,1,0); Side.BackgroundColor3=SB; Side.BorderSizePixel=0; Side.Parent=Main
Instance.new("UICorner",Side).CornerRadius=UDim.new(0,10)
local SideCov=Instance.new("Frame")
SideCov.Size=UDim2.new(0,15,1,0); SideCov.Position=UDim2.new(1,-15,0,0)
SideCov.BackgroundColor3=SB; SideCov.BorderSizePixel=0; SideCov.Parent=Side

local Top = Instance.new("Frame")
Top.Size=UDim2.new(1,0,0,55); Top.Position=UDim2.new(0,80,0,0)
Top.BackgroundColor3=BG2; Top.BorderSizePixel=0; Top.Parent=Main

local Title = Instance.new("TextLabel")
Title.Size=UDim2.new(1,-90,0,24); Title.Position=UDim2.new(0,20,0,16)
Title.BackgroundTransparency=1; Title.Text="Movement"
Title.TextColor3=TX; Title.Font=Enum.Font.GothamBold; Title.TextSize=18
Title.TextXAlignment=Enum.TextXAlignment.Left; Title.Parent=Top

local CloseB = Instance.new("TextButton")
CloseB.Size=UDim2.new(0,28,0,28); CloseB.Position=UDim2.new(1,-38,0,14)
CloseB.BackgroundColor3=Color3.fromRGB(40,20,26); CloseB.Text="✕"
CloseB.TextColor3=RD; CloseB.Font=Enum.Font.GothamBold; CloseB.TextSize=13
CloseB.AutoButtonColor=false; CloseB.Parent=Main
Instance.new("UICorner",CloseB).CornerRadius=UDim.new(0,8)

local MinB = Instance.new("TextButton")
MinB.Size=UDim2.new(0,28,0,28); MinB.Position=UDim2.new(1,-72,0,14)
MinB.BackgroundColor3=BG3; MinB.Text="—"
MinB.TextColor3=T2; MinB.Font=Enum.Font.GothamBold; MinB.TextSize=15
MinB.AutoButtonColor=false; MinB.Parent=Main
Instance.new("UICorner",MinB).CornerRadius=UDim.new(0,8)

local Body = Instance.new("Frame")
Body.Size=UDim2.new(1,-100,1,-70); Body.Position=UDim2.new(0,95,0,63)
Body.BackgroundTransparency=1; Body.Parent=Main

-- ==== ТАБЛЕТКА (твоя) ====
local Pill = Instance.new("Frame")
Pill.Size=UDim2.new(0,140,0,36); Pill.Position=UDim2.new(0.5,-70,0.5,-18)
Pill.BackgroundColor3=Color3.fromRGB(0,0,0); Pill.BackgroundTransparency=0.3
Pill.Visible=false; Pill.Parent=SG
Instance.new("UICorner",Pill).CornerRadius=UDim.new(0,18)
local PS=Instance.new("UIStroke"); PS.Color=Color3.fromRGB(80,80,80); PS.Thickness=1; PS.Parent=Pill
local PI=Instance.new("TextLabel")
PI.Size=UDim2.new(0,24,1,0); PI.Position=UDim2.new(0,12,0,0)
PI.BackgroundTransparency=1; PI.Text="⌇"; PI.TextColor3=TX
PI.TextSize=16; PI.Font=Enum.Font.GothamBold; PI.Parent=Pill
local PT=Instance.new("TextLabel")
PT.Size=UDim2.new(1,-45,1,0); PT.Position=UDim2.new(0,36,0,0)
PT.BackgroundTransparency=1; PT.Text="Alpha Hub"; PT.TextColor3=TX
PT.TextSize=13; PT.Font=Enum.Font.GothamBold; PT.TextXAlignment=Enum.TextXAlignment.Left; PT.Parent=Pill
local PC=Instance.new("TextButton")
PC.Size=UDim2.new(1,0,1,0); PC.BackgroundTransparency=1; PC.Text=""; PC.Parent=Pill

local tD,tS,tSP
PC.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        tD=true; tS=i.Position; tSP=Pill.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if tD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-tS
        Pill.Position=UDim2.new(tSP.X.Scale,tSP.X.Offset+d.X,tSP.Y.Scale,tSP.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        if tD then
            tD=false
            local d=i.Position-tS
            if d.Magnitude<5 then Pill.Visible=false; Main.Visible=true end
        end
    end
end)
CloseB.MouseButton1Click:Connect(function() Main.Visible=false; Pill.Visible=true end)
MinB.MouseButton1Click:Connect(function() Main.Visible=false; Pill.Visible=true end)

-- ===== СИСТЕМА СЕТКИ =====
local function grid(pd)
    if not pd then return end
    local cards = pd.Cards
    local cw,px,py,sx,sy = 200,10,10,5,5
    local cols={0,0,0}
    for _,cf in ipairs(cards) do
        if cf.Parent==pd.Frame then
            local mc,mh=1,cols[1]
            for c=2,3 do if cols[c]<mh then mh=cols[c]; mc=c end end
            cf.Position=UDim2.new(0, sx+(mc-1)*(cw+px), 0, sy+mh)
            cols[mc]=mh+cf.AbsoluteSize.Y+py
        end
    end
    local mh=cols[1]
    for c=2,3 do if cols[c]>mh then mh=cols[c] end end
    pd.Frame.CanvasSize=UDim2.new(0,0,0,sy+mh+20)
end

local function updVis()
    Title.Text = S.curTab
    for n,pd in pairs(S.pages) do
        if pd then
            pd.Frame.Visible = (n==S.curTab)
            if n==S.curTab then grid(pd) end
        end
    end
    for n,b in pairs(S.tabs) do
        local im=b:FindFirstChildOfClass("ImageLabel")
        local st=b:FindFirstChildOfClass("UIStroke")
        if n==S.curTab then
            b.BackgroundColor3=BG3
            if st then st.Color=AC end
            if im then im.ImageColor3=AC end
        else
            b.BackgroundColor3=BG2
            if st then st.Color=BD end
            if im then im.ImageColor3=T2 end
        end
    end
end

local icons = {
    ["Movement"]="rbxassetid://10723345709",
    ["Player"]="rbxassetid://10723395906",
    ["Combat"]="rbxassetid://10723345709",
    ["PL"]="rbxassetid://10734950349",
    ["Players"]="rbxassetid://10734963570",
    ["Configs"]="rbxassetid://10723345709",
    ["Settings"]="rbxassetid://10723345709",
}

local function mkPage(name)
    local pf = Instance.new("ScrollingFrame")
    pf.Size=UDim2.new(1,0,1,0); pf.BackgroundTransparency=1
    pf.ScrollBarThickness=4; pf.ScrollBarImageColor3=Color3.fromRGB(45,45,50)
    pf.Visible=false; pf.Parent=Body
    S.pages[name]={Frame=pf,Cards={}}
    return S.pages[name]
end

-- ===== КАРТОЧКА =====
local function mkCard(pd, title, opts)
    opts = opts or {}
    local hasContent = opts.content ~= false
    local hasToggle = opts.hasToggle ~= false
    local hasStar = opts.hasStar ~= false
    
    local cf = Instance.new("Frame")
    cf.Name = title.."Card"
    cf.Size = UDim2.new(0,200,0, hasContent and 110 or 40)
    cf.AutomaticSize = hasContent and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    cf.BackgroundColor3 = BG2
    cf.BorderSizePixel = 0; cf.ClipsDescendants = true; cf.Parent = pd.Frame
    table.insert(pd.Cards, cf)
    Instance.new("UICorner",cf).CornerRadius = UDim.new(0,8)
    local cs=Instance.new("UIStroke"); cs.Color=BD; cs.Thickness=1; cs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; cs.Parent=cf
    
    local cr = {frame=cf, name=title, home=pd, sliders={}, dropdowns={}, toggles={}, star=false, collapsed=false}
    table.insert(S.cards, cr)
    S.cardMap[title] = cr
    
    local hf = Instance.new("Frame")
    hf.Size = UDim2.new(1,0,0,40); hf.BackgroundTransparency = 1; hf.Parent = cf
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-100,1,0); tl.Position = UDim2.new(0,12,0,0)
    tl.BackgroundTransparency = 1; tl.Text = title
    tl.TextColor3 = TX; tl.Font = Enum.Font.GothamBold; tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = hf
    
    if hasStar then
        local sc = Instance.new("Frame")
        sc.Size = UDim2.new(0,20,0,20); sc.Position = UDim2.new(1,-70,0,10)
        sc.BackgroundColor3 = BG3; sc.BorderSizePixel = 0; sc.Parent = hf
        Instance.new("UICorner",sc).CornerRadius = UDim.new(0,5)
        local ss = Instance.new("UIStroke"); ss.Color = BD; ss.Thickness = 1; ss.Parent = sc
        local sb = Instance.new("TextButton")
        sb.Size = UDim2.new(1,0,1,0); sb.BackgroundTransparency = 1
        sb.Text = "★"; sb.Font = Enum.Font.GothamBold; sb.TextSize = 12
        sb.TextColor3 = Color3.fromRGB(80,80,85); sb.Parent = sc
        sb.MouseButton1Click:Connect(function()
            cr.star = not cr.star
            if cr.star then
                tw(sb,0.2,{TextColor3=Color3.fromRGB(255,255,255)})
                tw(ss,0.2,{Color=Color3.fromRGB(255,255,255)})
            else
                tw(sb,0.2,{TextColor3=Color3.fromRGB(80,80,85)})
                tw(ss,0.2,{Color=BD})
            end
        end)
    end
    
    local active = false
    local cb = nil
    
    if hasToggle then
        local ts = Instance.new("TextButton")
        ts.Size = UDim2.new(0,30,0,18); ts.Position = UDim2.new(1,-46,0,11)
        ts.BackgroundColor3 = BG3; ts.Text = ""; ts.AutoButtonColor = false; ts.Parent = hf
        Instance.new("UICorner",ts).CornerRadius = UDim.new(1,0)
        local tst = Instance.new("UIStroke"); tst.Color = BD; tst.Thickness = 1; tst.Parent = ts
        local tc = Instance.new("Frame")
        tc.Size = UDim2.new(0,12,0,12); tc.Position = UDim2.new(0,3,0.5,-6)
        tc.BackgroundColor3 = Color3.fromRGB(130,130,135); tc.BorderSizePixel = 0; tc.Parent = ts
        Instance.new("UICorner",tc).CornerRadius = UDim.new(1,0)
        
        local function setT(a, fire)
            active = a
            if a then
                tw(ts,0.2,{BackgroundColor3=GN})
                tw(tst,0.2,{Color=GN})
                tw(tc,0.2,{Position=UDim2.new(1,-15,0.5,-6)})
                tw(tc,0.2,{BackgroundColor3=Color3.fromRGB(15,15,18)})
            else
                tw(ts,0.2,{BackgroundColor3=BG3})
                tw(tst,0.2,{Color=BD})
                tw(tc,0.2,{Position=UDim2.new(0,3,0.5,-6)})
                tw(tc,0.2,{BackgroundColor3=Color3.fromRGB(130,130,135)})
            end
            if fire ~= false and cb then pcall(cb, active) end
        end
        ts.MouseButton1Click:Connect(function() setT(not active); saveCur() end)
        cr.setT = setT
        cr.getT = function() return active end
    end
    
    local colB = Instance.new("TextButton")
    colB.Size = UDim2.new(0,20,0,20); colB.Position = UDim2.new(1,-22,0,10)
    colB.BackgroundTransparency = 1; colB.Text = "▲"
    colB.Font = Enum.Font.GothamBold; colB.TextSize = 10
    colB.TextColor3 = T2; colB.Parent = hf
    
    local cc
    if hasContent then
        cc = Instance.new("Frame")
        cc.Name = "Content"; cc.Size = UDim2.new(1,-24,0,0); cc.Position = UDim2.new(0,12,0,42)
        cc.AutomaticSize = Enum.AutomaticSize.Y; cc.BackgroundTransparency = 1; cc.Parent = cf
        local ll = Instance.new("UIListLayout")
        ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0,10); ll.Parent = cc
    end
    
    colB.MouseButton1Click:Connect(function()
        cr.collapsed = not cr.collapsed
        if cr.collapsed then
            cr.savedH = cf.Size
            tw(cf,0.2,{Size=UDim2.new(0,200,0,40)})
            if cc then
                cc.Visible = false
            end
            colB.Text = "▼"
        else
            if cc then cc.Visible = true end
            tw(cf,0.2,{Size=cr.savedH or UDim2.new(0,200,0,110)})
            colB.Text = "▲"
        end
        task.wait(0.05); grid(cr.home)
    end)
    
    local ex = {}
    function ex:onToggle(f) cb = f end
    
    function ex:slider(id, text, mn, mx, df, fn)
        local sf = Instance.new("Frame")
        sf.Size = UDim2.new(1,0,0,30); sf.BackgroundTransparency = 1; sf.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6,0,0,14); l.BackgroundTransparency = 1
        l.Text = text; l.TextColor3 = T2; l.Font = Enum.Font.Gotham
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = sf
        local vl = Instance.new("TextLabel")
        vl.Size = UDim2.new(0.4,0,0,14); vl.Position = UDim2.new(0.6,0,0,0)
        vl.BackgroundTransparency = 1; vl.Text = string.format("%.2f", df)
        vl.TextColor3 = AC; vl.Font = Enum.Font.GothamBold; vl.TextSize = 11
        vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = sf
        local sb = Instance.new("TextButton")
        sb.Size = UDim2.new(1,0,0,4); sb.Position = UDim2.new(0,0,0,20)
        sb.BackgroundColor3 = BG3; sb.Text = ""; sb.AutoButtonColor = false; sb.Parent = sf
        Instance.new("UICorner",sb).CornerRadius = UDim.new(1,0)
        local fl = Instance.new("Frame")
        local iPct = (df-mn)/(mx-mn)
        fl.Size = UDim2.new(iPct,0,1,0); fl.BackgroundColor3 = AC; fl.BorderSizePixel = 0; fl.Parent = sb
        Instance.new("UICorner",fl).CornerRadius = UDim.new(1,0)
        local tg = Instance.new("Frame")
        tg.Size = UDim2.new(0,12,0,12); tg.Position = UDim2.new(iPct,-6,0.5,-6)
        tg.BackgroundColor3 = Color3.fromRGB(255,255,255); tg.BorderSizePixel = 0; tg.Parent = sb
        Instance.new("UICorner",tg).CornerRadius = UDim.new(1,0)
        
        local cur = df
        local slide = false
        local function updV(v)
            local pct = math.clamp((v-mn)/(mx-mn),0,1)
            fl.Size = UDim2.new(pct,0,1,0); tg.Position = UDim2.new(pct,-6,0.5,-6)
            vl.Text = string.format("%.2f", v)
        end
        local function updI(inp)
            local off = math.clamp((inp.Position.X-sb.AbsolutePosition.X)/sb.AbsoluteSize.X,0,1)
            cur = mn+(mx-mn)*off; updV(cur); pcall(fn, cur)
        end
        sb.InputBegan:Connect(function(i)
            if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
                slide = true; updI(i)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if slide and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                updI(i)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and slide then
                slide = false; saveCur()
            end
        end)
        cr.sliders[id] = {Set=function(v) cur=math.clamp(v,mn,mx); updV(cur); pcall(fn,cur) end, Get=function() return cur end}
    end
    
    function ex:dropdown(id, text, opts, df, fn)
        local dfr = Instance.new("Frame")
        dfr.Size = UDim2.new(1,0,0,38); dfr.BackgroundTransparency = 1; dfr.Parent = cc
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,14); l.BackgroundTransparency = 1
        l.Text = text; l.TextColor3 = T2; l.Font = Enum.Font.Gotham
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = dfr
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,20); b.Position = UDim2.new(0,0,0,16)
        b.BackgroundColor3 = BG3; b.Font = Enum.Font.Gotham
        b.Text = " "..df; b.TextColor3 = TX; b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0; b.Parent = dfr
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
        local lf = Instance.new("Frame")
        lf.Size = UDim2.new(1,0,0,0); lf.Position = UDim2.new(0,0,1,2)
        lf.BackgroundColor3 = BG; lf.ClipsDescendants = true; lf.Parent = b
        Instance.new("UICorner",lf).CornerRadius = UDim.new(0,4)
        Instance.new("UIListLayout",lf).SortOrder = Enum.SortOrder.LayoutOrder
        local cur = df
        local open = false
        b.MouseButton1Click:Connect(function()
            open = not open
            if open then
                cf.ClipsDescendants = false
                tw(lf,0.2,{Size=UDim2.new(1,0,0,#opts*18)})
            else
                tw(lf,0.2,{Size=UDim2.new(1,0,0,0)}).Completed:Connect(function()
                    if not open then cf.ClipsDescendants = true end
                end)
            end
        end)
        for _,opt in ipairs(opts) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1,0,0,18); ob.BackgroundTransparency = 1
            ob.Font = Enum.Font.Gotham; ob.Text = " "..opt
            ob.TextColor3 = Color3.fromRGB(200,200,205); ob.TextSize = 11
            ob.TextXAlignment = Enum.TextXAlignment.Left; ob.Parent = lf
            ob.MouseEnter:Connect(function() ob.BackgroundTransparency = 0; ob.BackgroundColor3 = BG3 end)
            ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
            ob.MouseButton1Click:Connect(function()
                cur = opt; b.Text = " "..opt
                open = false; tw(lf,0.2,{Size=UDim2.new(1,0,0,0)})
                pcall(fn,opt); saveCur()
            end)
        end
        cr.dropdowns[id] = {Set=function(v) cur=v; b.Text=" "..v; pcall(fn,v) end, Get=function() return cur end}
    end
    
    function ex:button(text, fn)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = BG3
        b.Text = text; b.TextColor3 = TX; b.Font = Enum.Font.GothamBold
        b.TextSize = 11; b.AutoButtonColor = false; b.Parent = cc
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
        b.MouseButton1Click:Connect(function() pcall(fn) end)
    end
    
    return ex
end

-- ===== СОЗДАНИЕ ВКЛАДОК =====
local tabList = {"Movement","Player","Combat","PL","Players","Configs","Settings"}
local tabOrder = {}
for i,v in ipairs(tabList) do tabOrder[v]=i end

local TabFrame = Instance.new("ScrollingFrame")
TabFrame.Size=UDim2.new(1,0,1,-60); TabFrame.Position=UDim2.new(0,0,0,55)
TabFrame.BackgroundTransparency=1; TabFrame.ScrollBarThickness=0
TabFrame.CanvasSize=UDim2.new(0,0,0,500); TabFrame.Parent=Side
local TFL = Instance.new("UIListLayout")
TFL.Padding=UDim.new(0,6); TFL.HorizontalAlignment=Enum.HorizontalAlignment.Center; TFL.Parent=TabFrame

for _,name in ipairs(tabList) do
    mkPage(name)
    local b = Instance.new("TextButton")
    b.Size=UDim2.new(0,44,0,42); b.BackgroundColor3=BG2
    b.BorderSizePixel=0; b.Text=""; b.LayoutOrder=tabOrder[name]; b.Parent=TabFrame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local bs=Instance.new("UIStroke"); bs.Color=BD; bs.Thickness=1; bs.Parent=b
    S.tabs[name]=b
    local im=Instance.new("ImageLabel")
    im.Size=UDim2.new(0,22,0,22); im.Position=UDim2.new(0.5,-11,0.5,-11)
    im.BackgroundTransparency=1; im.Image=icons[name] or "rbxassetid://10723345709"
    im.ImageColor3=T2; im.Parent=b
    b.MouseButton1Click:Connect(function() S.curTab=name; updVis() end)
end

-- ===== КАРТОЧКИ =====
local c1 = mkCard(S.pages["Movement"], "Walk Speed")
c1:slider(1,"Speed Value",1,500,16,function(v)
    S.walkV=v
    if S.walk then local c=LP.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed=v end end
end)
c1:onToggle(function(s)
    S.walk=s
    local c=LP.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s and S.walkV or 16 end
    startWD(); saveCur()
end)

local c2 = mkCard(S.pages["Movement"], "Jump Power")
c2:slider(2,"Power Value",1,500,50,function(v)
    S.jumpV=v
    if S.jump then local c=LP.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower=v end end
end)
c2:onToggle(function(s)
    S.jump=s
    local c=LP.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = s and S.jumpV or 50 end
    startWD(); saveCur()
end)

local c3 = mkCard(S.pages["Movement"], "Spider")
c3:slider(3,"Climb Speed",1,20,3,function(v) S.climbV=v/10 end)
c3:onToggle(function(s) S.spd=s; startSpider(); saveCur() end)

local c4 = mkCard(S.pages["Movement"], "Infinite Jump", {content=false})
c4:onToggle(function(s)
    S.ij=s
    if s and not S.ijC then
        S.ijC = UIS.JumpRequest:Connect(function()
            if not S.ij then return end
            local c=LP.Character; if not c then return end
            local h=c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    saveCur()
end)

local c5 = mkCard(S.pages["Movement"], "Vehicle Speed")
c5:slider(4,"Speed",50,500,100,function(v) S.vehV=v end)
c5:onToggle(function(s) S.veh=s; startVeh(); saveCur() end)

local p1 = mkCard(S.pages["Player"], "ESP Boxes", {content=false})
p1:onToggle(function(s) S.eB=s; startBox(); saveCur() end)

local p2 = mkCard(S.pages["Player"], "ESP Names", {content=false})
p2:onToggle(function(s) S.eN=s; startName(); saveCur() end)

local p3 = mkCard(S.pages["Player"], "ESP Lines", {content=false})
p3:onToggle(function(s) S.eL=s; startLine(); saveCur() end)

local p4 = mkCard(S.pages["Player"], "ESP Team Check", {content=false})
p4:onToggle(function(s) S.eT=s; saveCur() end)

local p5 = mkCard(S.pages["Player"], "FOV Changer")
p5:slider(5,"FOV",30,120,70,function(v)
    S.fovV=v
    if S.fov and WS.CurrentCamera then WS.CurrentCamera.FieldOfView=v end
end)
p5:onToggle(function(s) S.fov=s; startFOV(); saveCur() end)

local p6 = mkCard(S.pages["Player"], "Fullbright", {content=false})
p6:onToggle(function(s) S.fb=s; startFB(); saveCur() end)

local p7 = mkCard(S.pages["Player"], "Spin")
p7:slider(6,"Spin Rate",1,50,10,function(v) S.spinV=v end)
p7:onToggle(function(s) S.spin=s; startSpin(); saveCur() end)

local m1 = mkCard(S.pages["Combat"], "Silent Aim")
m1:slider(7,"FOV",30,360,100,function(v) S.aimF=v end)
m1:dropdown(1,"Aim Part",{"Head","HumanoidRootPart","UpperTorso","Torso"},"Head",function(v) S.aimP=v end)
m1:slider(8,"Hit Chance",1,100,100,function(v) S.aimC=v end)
m1:onToggle(function(s) S.aim=s; if s then installAim() end; saveCur() end)

local m2 = mkCard(S.pages["Combat"], "Silent Team Check", {content=false})
m2:onToggle(function(s) S.aimT=s; saveCur() end)

local m3 = mkCard(S.pages["Combat"], "Silent Wall Check", {content=false})
m3:onToggle(function(s) S.aimW=s; saveCur() end)

local m4 = mkCard(S.pages["Combat"], "Silent Ignore Friends", {content=false})
m4:onToggle(function(s) S.aimFr=s; saveCur() end)

local m5 = mkCard(S.pages["Combat"], "Hitbox Expander")
m5:slider(9,"Size x",1,10,3,function(v) S.hbV=v end)
m5:onToggle(function(s) S.hb=s; startHB(); saveCur() end)

local m6 = mkCard(S.pages["Combat"], "Hitbox Team Check", {content=false})
m6:onToggle(function(s) S.hbT=s; saveCur() end)

local m7 = mkCard(S.pages["Combat"], "Hitbox Ignore Friends", {content=false})
m7:onToggle(function(s) S.hbFr=s; saveCur() end)

local m8 = mkCard(S.pages["Combat"], "Hitbox Visual", {content=false})
m8:onToggle(function(s) S.hbVis=s; if S.hb then startHB() end; saveCur() end)

local m9 = mkCard(S.pages["Combat"], "Infinite Ammo", {content=false})
m9:onToggle(function(s) S.ammo=s; startWP(); saveCur() end)

local m10 = mkCard(S.pages["Combat"], "Rapid Fire", {content=false})
m10:onToggle(function(s) S.rapid=s; startWP(); saveCur() end)

local m11 = mkCard(S.pages["Combat"], "Instant Reload", {content=false})
m11:onToggle(function(s) S.reload=s; startWP(); saveCur() end)

local k1 = mkCard(S.pages["PL"], "Auto Keycard")
k1:slider(10,"Range",10,100,20,function(v) S.kcR=v end)
k1:onToggle(function(s) S.kc=s; startKey(); saveCur() end)

local k2 = mkCard(S.pages["PL"], "Arrest Aura")
k2:slider(11,"Range",1,15,7.5,function(v) S.arrR=v end)
k2:onToggle(function(s) S.arr=s; startArr(); saveCur() end)

local k3 = mkCard(S.pages["PL"], "Melee Aura")
k3:slider(12,"Range",1,9,4,function(v) S.melR=v end)
k3:onToggle(function(s) S.mel=s; startMel(); saveCur() end)

local k4 = mkCard(S.pages["PL"], "Anti-Taze", {content=false})
k4:onToggle(function(s) S.atz=s; startAT(); saveCur() end)

local k5 = mkCard(S.pages["PL"], "Auto Get Gun", {content=false})
k5:onToggle(function(s) S.ag=s; startAG(); saveCur() end)

local k6 = mkCard(S.pages["PL"], "Item Giver", {hasToggle=false})
k6:button("🎁 M4A1", function() getGun("M4A1") end)
k6:button("🎁 Remington 870", function() getGun("Remington 870") end)
k6:button("🎁 AK-47", function() getGun("AK-47") end)
k6:button("🎁 MP5", function() getGun("MP5") end)

local k7 = mkCard(S.pages["PL"], "Teleports", {hasToggle=false})
local tps = {
    ["Оружейная"]=Vector3.new(826.20,101.46,2294.85),
    ["Кафетерий"]=Vector3.new(924.52,101.48,2227.59),
    ["База преступников"]=Vector3.new(-975.03,109.82,2057.95),
    ["Секретная комната"]=Vector3.new(701.45,101.45,2354.30),
    ["Двор"]=Vector3.new(795.78,99.65,2541.00),
    ["Внутри тюрьмы"]=Vector3.new(915.29,101.49,2388.00),
}
for name,pos in pairs(tps) do
    k7:button("📍 "..name, function()
        local c=LP.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) end
    end)
end

-- ===== PLAYERS (список) =====
local plPage = S.pages["Players"]
local plScroll = Instance.new("ScrollingFrame")
plScroll.Size=UDim2.new(1,0,1,0); plScroll.BackgroundTransparency=1
plScroll.ScrollBarThickness=4; plScroll.ScrollBarImageColor3=Color3.fromRGB(45,45,50)
plScroll.Parent=plPage.Frame
Instance.new("UIListLayout",plScroll).Padding=UDim.new(0,6)

local function refreshPl()
    for _,ch in ipairs(plScroll:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local row = Instance.new("Frame")
        row.Size=UDim2.new(1,-8,0,50); row.BackgroundColor3=BG2; row.BorderSizePixel=0; row.Parent=plScroll
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rs=Instance.new("UIStroke"); rs.Color=BD; rs.Thickness=1; rs.Parent=row
        local av=Instance.new("ImageLabel")
        av.Size=UDim2.new(0,36,0,36); av.Position=UDim2.new(0,8,0.5,-18)
        av.BackgroundColor3=BG3; av.BorderSizePixel=0; av.Parent=row
        Instance.new("UICorner",av).CornerRadius=UDim.new(1,0)
        task.spawn(function()
            local ok,t=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
            if ok and t and av.Parent then av.Image=t end
        end)
        local nm=Instance.new("TextLabel")
        nm.Size=UDim2.new(1,-155,0,16); nm.Position=UDim2.new(0,52,0,8)
        nm.BackgroundTransparency=1; nm.Text=p.Name; nm.TextColor3=TX
        nm.Font=Enum.Font.GothamBold; nm.TextSize=12; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=row
        local st=Instance.new("TextLabel")
        st.Size=UDim2.new(1,-155,0,14); st.Position=UDim2.new(0,52,0,26)
        st.BackgroundTransparency=1; st.Text="..."; st.TextColor3=T2
        st.Font=Enum.Font.Gotham; st.TextSize=10; st.TextXAlignment=Enum.TextXAlignment.Left; st.Parent=row
        local hc
        hc=RS.Heartbeat:Connect(function()
            if not row.Parent then hc:Disconnect() return end
            local c=p.Character
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local tn=p.Team and p.Team.Name or "Нет команды"
            if h then
                if h.Health>0 then
                    st.Text=string.format("❤ %d | %s",math.floor(h.Health),tn); st.TextColor3=GN
                else st.Text="☠ Мёртв | "..tn; st.TextColor3=RD end
            else st.Text=tn; st.TextColor3=T2 end
        end)
        local tb=Instance.new("TextButton")
        tb.Size=UDim2.new(0,68,0,32); tb.Position=UDim2.new(1,-76,0.5,-16)
        tb.BackgroundColor3=AC; tb.Text="TP"; tb.TextColor3=Color3.fromRGB(255,255,255)
        tb.Font=Enum.Font.GothamBold; tb.TextSize=11; tb.AutoButtonColor=false; tb.Parent=row
        Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
        tb.MouseButton1Click:Connect(function()
            if p.Character then
                local hr=p.Character:FindFirstChild("HumanoidRootPart")
                local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hr and mr then mr.CFrame=CFrame.new(hr.Position+Vector3.new(0,3,0)) end
            end
        end)
    end
end

-- ===== CONFIGS =====
local cfgPage = S.pages["Configs"]
local nameI = Instance.new("TextBox")
nameI.Size=UDim2.new(0,220,0,32); nameI.Position=UDim2.new(0,5,0,5)
nameI.BackgroundColor3=BG3; nameI.PlaceholderText="Имя конфига..."
nameI.PlaceholderColor3=T2; nameI.Text=""; nameI.TextColor3=TX
nameI.Font=Enum.Font.Gotham; nameI.TextSize=12; nameI.Parent=cfgPage.Frame
Instance.new("UICorner",nameI).CornerRadius=UDim.new(0,6)

local saveB = Instance.new("TextButton")
saveB.Size=UDim2.new(0,130,0,32); saveB.Position=UDim2.new(0,235,0,5)
saveB.BackgroundColor3=GN; saveB.Text="💾 Сохранить"
saveB.TextColor3=Color3.fromRGB(255,255,255)
saveB.Font=Enum.Font.GothamBold; saveB.TextSize=11; saveB.AutoButtonColor=false; saveB.Parent=cfgPage.Frame
Instance.new("UICorner",saveB).CornerRadius=UDim.new(0,6)

local cfgScroll = Instance.new("ScrollingFrame")
cfgScroll.Size=UDim2.new(1,-10,1,-50); cfgScroll.Position=UDim2.new(0,5,0,45)
cfgScroll.BackgroundTransparency=1; cfgScroll.ScrollBarThickness=4
cfgScroll.ScrollBarImageColor3=Color3.fromRGB(45,45,50); cfgScroll.Parent=cfgPage.Frame
Instance.new("UIListLayout",cfgScroll).Padding=UDim.new(0,6)

local function rebuildCfg()
    for _,ch in ipairs(cfgScroll:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for name,_ in pairs(S.cfg) do
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,0,0,42); row.BackgroundColor3=BG2; row.BorderSizePixel=0; row.Parent=cfgScroll
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rs=Instance.new("UIStroke"); rs.Color=BD; rs.Thickness=1; rs.Parent=row
        local nl=Instance.new("TextLabel")
        nl.Size=UDim2.new(1,-180,1,0); nl.Position=UDim2.new(0,14,0,0)
        nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=TX
        nl.Font=Enum.Font.GothamBold; nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=row
        local lb=Instance.new("TextButton")
        lb.Size=UDim2.new(0,75,0,30); lb.Position=UDim2.new(1,-165,0.5,-15)
        lb.BackgroundColor3=AC; lb.Text="📂 Load"
        lb.TextColor3=Color3.fromRGB(255,255,255); lb.Font=Enum.Font.GothamBold
        lb.TextSize=10; lb.AutoButtonColor=false; lb.Parent=row
        Instance.new("UICorner",lb).CornerRadius=UDim.new(0,6)
        local db=Instance.new("TextButton")
        db.Size=UDim2.new(0,75,0,30); db.Position=UDim2.new(1,-85,0.5,-15)
        db.BackgroundColor3=RD; db.Text="🗑"
        db.TextColor3=Color3.fromRGB(255,255,255); db.Font=Enum.Font.GothamBold
        db.TextSize=10; db.AutoButtonColor=false; db.Parent=row
        Instance.new("UICorner",db).CornerRadius=UDim.new(0,6)
        lb.MouseButton1Click:Connect(function()
            local d=S.cfg[name]
            if d then applyCfg(d); startAll(); syncUI(); saveCur() end
        end)
        db.MouseButton1Click:Connect(function()
            S.cfg[name]=nil; saveAll(); rebuildCfg()
        end)
    end
end

saveB.MouseButton1Click:Connect(function()
    local n=nameI.Text
    if n=="" then return end
    S.cfg[n]=getCfg(); nameI.Text=""; saveAll(); rebuildCfg()
end)

-- ===== СИНХРОНИЗАЦИЯ UI =====
local function syncUI()
    local m = S.cardMap
    if m["Walk Speed"] then
        if m["Walk Speed"].setT then m["Walk Speed"].setT(S.walk, false) end
        if m["Walk Speed"].sliders[1] then m["Walk Speed"].sliders[1].Set(S.walkV) end
    end
    if m["Jump Power"] then
        if m["Jump Power"].setT then m["Jump Power"].setT(S.jump, false) end
        if m["Jump Power"].sliders[2] then m["Jump Power"].sliders[2].Set(S.jumpV) end
    end
    if m["Spider"] then
        if m["Spider"].setT then m["Spider"].setT(S.spd, false) end
        if m["Spider"].sliders[3] then m["Spider"].sliders[3].Set(S.climbV*10) end
    end
    if m["Infinite Jump"] and m["Infinite Jump"].setT then m["Infinite Jump"].setT(S.ij, false) end
    if m["Vehicle Speed"] then
        if m["Vehicle Speed"].setT then m["Vehicle Speed"].setT(S.veh, false) end
        if m["Vehicle Speed"].sliders[4] then m["Vehicle Speed"].sliders[4].Set(S.vehV) end
    end
    if m["ESP Boxes"] and m["ESP Boxes"].setT then m["ESP Boxes"].setT(S.eB, false) end
    if m["ESP Names"] and m["ESP Names"].setT then m["ESP Names"].setT(S.eN, false) end
    if m["ESP Lines"] and m["ESP Lines"].setT then m["ESP Lines"].setT(S.eL, false) end
    if m["ESP Team Check"] and m["ESP Team Check"].setT then m["ESP Team Check"].setT(S.eT, false) end
    if m["FOV Changer"] then
        if m["FOV Changer"].setT then m["FOV Changer"].setT(S.fov, false) end
        if m["FOV Changer"].sliders[5] then m["FOV Changer"].sliders[5].Set(S.fovV) end
    end
    if m["Fullbright"] and m["Fullbright"].setT then m["Fullbright"].setT(S.fb, false) end
    if m["Spin"] then
        if m["Spin"].setT then m["Spin"].setT(S.spin, false) end
        if m["Spin"].sliders[6] then m["Spin"].sliders[6].Set(S.spinV) end
    end
    if m["Silent Aim"] then
        if m["Silent Aim"].setT then m["Silent Aim"].setT(S.aim, false) end
        if m["Silent Aim"].sliders[7] then m["Silent Aim"].sliders[7].Set(S.aimF) end
        if m["Silent Aim"].dropdowns[1] then m["Silent Aim"].dropdowns[1].Set(S.aimP) end
        if m["Silent Aim"].sliders[8] then m["Silent Aim"].sliders[8].Set(S.aimC) end
    end
    if m["Silent Team Check"] and m["Silent Team Check"].setT then m["Silent Team Check"].setT(S.aimT, false) end
    if m["Silent Wall Check"] and m["Silent Wall Check"].setT then m["Silent Wall Check"].setT(S.aimW, false) end
    if m["Silent Ignore Friends"] and m["Silent Ignore Friends"].setT then m["Silent Ignore Friends"].setT(S.aimFr, false) end
    if m["Hitbox Expander"] then
        if m["Hitbox Expander"].setT then m["Hitbox Expander"].setT(S.hb, false) end
        if m["Hitbox Expander"].sliders[9] then m["Hitbox Expander"].sliders[9].Set(S.hbV) end
    end
    if m["Hitbox Team Check"] and m["Hitbox Team Check"].setT then m["Hitbox Team Check"].setT(S.hbT, false) end
    if m["Hitbox Ignore Friends"] and m["Hitbox Ignore Friends"].setT then m["Hitbox Ignore Friends"].setT(S.hbFr, false) end
    if m["Hitbox Visual"] and m["Hitbox Visual"].setT then m["Hitbox Visual"].setT(S.hbVis, false) end
    if m["Infinite Ammo"] and m["Infinite Ammo"].setT then m["Infinite Ammo"].setT(S.ammo, false) end
    if m["Rapid Fire"] and m["Rapid Fire"].setT then m["Rapid Fire"].setT(S.rapid, false) end
    if m["Instant Reload"] and m["Instant Reload"].setT then m["Instant Reload"].setT(S.reload, false) end
    if m["Auto Keycard"] then
        if m["Auto Keycard"].setT then m["Auto Keycard"].setT(S.kc, false) end
        if m["Auto Keycard"].sliders[10] then m["Auto Keycard"].sliders[10].Set(S.kcR) end
    end
    if m["Arrest Aura"] then
        if m["Arrest Aura"].setT then m["Arrest Aura"].setT(S.arr, false) end
        if m["Arrest Aura"].sliders[11] then m["Arrest Aura"].sliders[11].Set(S.arrR) end
    end
    if m["Melee Aura"] then
        if m["Melee Aura"].setT then m["Melee Aura"].setT(S.mel, false) end
        if m["Melee Aura"].sliders[12] then m["Melee Aura"].sliders[12].Set(S.melR) end
    end
    if m["Anti-Taze"] and m["Anti-Taze"].setT then m["Anti-Taze"].setT(S.atz, false) end
    if m["Auto Get Gun"] and m["Auto Get Gun"].setT then m["Auto Get Gun"].setT(S.ag, false) end
end

-- старт
loadAll(); loadCur(); startAll(); rebuildCfg(); refreshPl()
Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPl() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2) refreshPl() end)

task.wait(0.3)
for _,tn in ipairs(tabList) do if S.pages[tn] then grid(S.pages[tn]) end end
updVis()
syncUI()

local function onChar(char)
    char:WaitForChild("Humanoid",5); task.wait(0.3)
    local h=char:FindFirstChildOfClass("Humanoid"); if not h then return end
    if S.walk then h.WalkSpeed=S.walkV end
    if S.jump then
        if h.UseJumpPower then h.JumpPower=S.jumpV else h.JumpHeight=S.jumpV/7.5 end
    end
    startAll()
end
LP.CharacterAdded:Connect(onChar)
if LP.Character then task.spawn(onChar, LP.Character) end
startWD()
task.spawn(function() while true do task.wait(10); saveCur() end end)
print("✨ ALPHA HUB PRISON LIFE — загружено!")