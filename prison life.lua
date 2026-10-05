-- Alpha Hub PL
if game.PlaceId ~= 155615604 then game.Players.LocalPlayer:Kick("Alpha Hub — только Prison Life") return end
local P=game:GetService("Players")local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")local T=game:GetService("TweenService")
local WS=game:GetService("Workspace")local LT=game:GetService("Lighting")
local HS=game:GetService("HttpService")local R=game:GetService("ReplicatedStorage")
local LP=P.LocalPlayer local PG=LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("AH")then PG.AH:Destroy()end

local S={walk=false,walkV=16,jump=false,jumpV=50,ij=false,spin=false,spinV=10,
eT=true,eB=false,eN=false,eL=false,spd=false,climbV=0.28,
aim=false,aimT=true,aimW=true,aimF=100,aimP="Head",aimC=100,
hb=false,hbV=3,hbT=false,ammo=false,rapid=false,reload=false,
arr=false,arrR=7.5,mel=false,melR=4,atz=false,kc=false,kcR=20,
fov=false,fovV=70,fb=false,veh=false,vehV=100,
pages={},tabs={},cur="Movement",conns={},trs={},names={},lines={},hbS={},
aimH=false,oldCR=nil,tgt=nil,frC={},rem={},cfg={},
draw=false,file=false,hook=false,sliders={},drops={},switches={}}

pcall(function()if Drawing then S.draw=true end end)
pcall(function()if writefile then S.file=true end end)
pcall(function()if hookfunction and getgc then S.hook=true end end)

local cam=WS.CurrentCamera
while not cam do RS.RenderStepped:Wait()cam=WS.CurrentCamera end
local defFOV=cam.FieldOfView

pcall(function()
    local G=R:FindFirstChild("GunRemotes")local Rm=R:FindFirstChild("Remotes")
    if G then S.rem.taze=G:FindFirstChild("PlayerTased")end
    if Rm then S.rem.arr=Rm:FindFirstChild("ArrestPlayer")end
    S.rem.mel=R:FindFirstChild("meleeEvent")
end)

local BG=Color3.fromRGB(15,15,18)local BG2=Color3.fromRGB(22,22,27)
local BG3=Color3.fromRGB(30,30,37)local AC=Color3.fromRGB(100,150,255)
local GN=Color3.fromRGB(80,220,130)local RD=Color3.fromRGB(255,90,90)
local TX=Color3.fromRGB(235,235,245)local T2=Color3.fromRGB(130,135,150)
local BR=Color3.fromRGB(38,40,50)

local function tw(o,t,p)local a=T:Create(o,TweenInfo.new(t),p)a:Play()return a end
local function isFr(u)if S.frC[u]~=nil then return S.frC[u]end
    local ok,r=pcall(function()return LP:IsFriendsWith(u)end)S.frC[u]=ok and r or false return S.frC[u]end

-- ===== ФУНКЦИИ =====
local function wd()if S.conns.wd then S.conns.wd:Disconnect()end
    S.conns.wd=RS.Heartbeat:Connect(function()
        local c=LP.Character if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid")if not h then return end
        if S.walk and h.WalkSpeed~=S.walkV then h.WalkSpeed=S.walkV end
        if S.jump and h.JumpPower~=S.jumpV then h.JumpPower=S.jumpV end
    end)end

local function wp()if S.conns.wp then S.conns.wp:Disconnect()end
    if not(S.ammo or S.rapid or S.reload)then return end
    S.conns.wp=RS.Heartbeat:Connect(function()
        local c=LP.Character if not c then return end
        for _,tl in ipairs(c:GetChildren())do
            if tl:IsA("Tool")then local gs=tl:FindFirstChild("GunStates")
                if gs then pcall(function()local e=getsenv(gs)if not e then return end
                    if S.ammo then e.MaxAmmo=math.huge e.StoredAmmo=math.huge end
                    if S.rapid then e.FireRate=0.0001 end
                    if S.reload then e.ReloadTime=0.0001 end
                end)end
            end
        end
    end)end

local function getGun(n)
    local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")
    if not(c and r)then return end
    if LP.Backpack:FindFirstChild(n)or c:FindFirstChild(n)then return end
    local g for _,v in ipairs(WS:GetDescendants())do
        if v.Name=="TouchGiver"and v:GetAttribute("ToolName")==n then
            g=v:FindFirstChildWhichIsA("BasePart")break end end
    if not g then return end
    local o=g.CFrame local oc=r.CFrame local u=o-Vector3.new(0,15.5,0)
    g.CanTouch=true g.CFrame=u c:PivotTo(u+Vector3.new(0,5,0))
    task.wait(0.25)pcall(function()firetouchinterest(g,r,0)end)
    task.wait(0.3)pcall(function()firetouchinterest(g,r,1)end)
    task.wait(0.05)g.CFrame=o c:PivotTo(oc)end

local function startArr()if S.conns.arr then S.conns.arr:Disconnect()end
    if not S.arr or not S.rem.arr then return end
    S.conns.arr=RS.Heartbeat:Connect(function()
        local c=LP.Character local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,pl in ipairs(P:GetPlayers())do
            if pl~=LP and pl.Character then
                local h=pl.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health>0 then
                    local isC=(pl.Team and pl.Team.Name=="Criminals")or h.DisplayName:find("🔗",1,true)
                    if isC then local hr=pl.Character:FindFirstChild("HumanoidRootPart")
                        if hr and(rt.Position-hr.Position).Magnitude<=S.arrR then
                            pcall(function()S.rem.arr:InvokeServer(pl)end)end
                    end
                end
            end
        end
    end)end

local function startMel()if S.conns.mel then S.conns.mel:Disconnect()end
    if not S.mel or not S.rem.mel then return end
    S.conns.mel=RS.Heartbeat:Connect(function()
        local c=LP.Character local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,pl in ipairs(P:GetPlayers())do
            if pl~=LP and pl.Character then
                local hr=pl.Character:FindFirstChild("HumanoidRootPart")
                local h=pl.Character:FindFirstChildOfClass("Humanoid")
                if hr and h and h.Health>0 and(rt.Position-hr.Position).Magnitude<=S.melR then
                    pcall(function()S.rem.mel:FireServer(pl)end)end
            end
        end
    end)end

local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Exclude rp.IgnoreWater=true
local function vis(p,o)
    if not p then return false end
    rp.FilterDescendantsInstances={LP.Character}
    local r=WS:Raycast(o,p.Position-o,rp)
    return(not r)or r.Instance:IsDescendantOf(p.Parent)end

local function closest()
    local best,bd=nil,S.aimF
    local ctr=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local org=cam.CFrame.Position
    for _,pl in ipairs(P:GetPlayers())do
        if pl==LP then continue end
        local C=pl.Character
        if C then local H=C:FindFirstChildOfClass("Humanoid")
            if H and H.Health>0 and not(S.aimT and LP.Team and pl.Team==LP.Team)then
                local part=C:FindFirstChild(S.aimP)or C:FindFirstChild("Head")
                if part and(org-part.Position).Magnitude<=400 then
                    local pos,on=cam:WorldToViewportPoint(part.Position)
                    if on and(not S.aimW or vis(part,org))then
                        local d=(Vector2.new(pos.X,pos.Y)-ctr).Magnitude
                        if d<bd then bd=d best=pl end end end end end
        end
    end
    return best end

local function installAim()
    if S.aimH or not S.hook then return end
    local cr
    pcall(function()for _,f in next,getgc(true)do
        if type(f)=="function"then local i=debug.getinfo(f,"nS")
            if i and i.name=="castRay"then cr=f break end end end end)
    if not cr then return end
    S.aimH=true S.oldCR=cr
    pcall(function()hookfunction(cr,function(...)
        local a={...}
        if S.aim and S.tgt and S.tgt.Character then
            local p=S.tgt.Character:FindFirstChild(S.aimP)
            if p and math.random(1,100)<=S.aimC then a[2]=p.Position end end
        return S.oldCR(table.unpack(a))end)end)end

RS.Heartbeat:Connect(function()if S.aim then S.tgt=closest()end end)

local function startSpin()if S.conns.spin then S.conns.spin:Disconnect()end
    if not S.spin then return end
    S.conns.spin=RS.Stepped:Connect(function()
        local ch=LP.Character if not ch then return end
        local hu=ch:FindFirstChildOfClass("Humanoid")
        local rp2=ch:FindFirstChild("HumanoidRootPart")
        if not rp2 then return end
        if hu then hu.AutoRotate=false end
        rp2.CFrame=rp2.CFrame*CFrame.Angles(0,math.rad(S.spinV),0)end)end

local function mkB(t)if not S.draw or t==LP or S.trs[t]then return end
    local b=Drawing.new("Square")b.Thickness=1.5 b.Color=AC b.Filled=false b.Visible=false S.trs[t]=b end
local function rmB(t)if S.trs[t]then pcall(function()S.trs[t]:Remove()end)end S.trs[t]=nil end
local function startBox()if S.conns.b then S.conns.b:Disconnect()end
    if not S.eB or not S.draw then for t in pairs(S.trs)do rmB(t)end return end
    S.conns.b=RS.RenderStepped:Connect(function()
        for _,p in ipairs(P:GetPlayers())do
            if p==LP then continue end
            local b=S.trs[p]if not b then mkB(p)continue end
            local c=p.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
            local hd=c and c:FindFirstChild("Head")local h=c and c:FindFirstChildOfClass("Humanoid")
            local sh=not(S.eT and LP.Team and p.Team==LP.Team)
            if sh and hr and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                local fs,fo=cam:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
                if ho and fo then local hh=math.abs(hs.Y-fs.Y)local ww=hh/2
                    b.Size=Vector2.new(ww,hh)b.Position=Vector2.new(hs.X-ww/2,hs.Y)b.Visible=true
                else b.Visible=false end
            else b.Visible=false end end end)end

local function mkN(t)if not S.draw or t==LP or S.names[t]then return end
    local n=Drawing.new("Text")n.Size=14 n.Center=true n.Outline=true
    n.Color=Color3.fromRGB(255,255,255)n.OutlineColor=Color3.fromRGB(0,0,0)
    n.Visible=false n.Font=2 n.Text=t.Name S.names[t]=n end
local function rmN(t)if S.names[t]then pcall(function()S.names[t]:Remove()end)end S.names[t]=nil end
local function startName()if S.conns.n then S.conns.n:Disconnect()end
    if not S.eN or not S.draw then for t in pairs(S.names)do rmN(t)end return end
    S.conns.n=RS.RenderStepped:Connect(function()
        for _,p in ipairs(P:GetPlayers())do
            if p==LP then continue end
            local n=S.names[p]if not n then mkN(p)continue end
            local c=p.Character local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local sh=not(S.eT and LP.Team and p.Team==LP.Team)
            if sh and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                if ho then n.Position=Vector2.new(hs.X,hs.Y-18)
                    n.Text=string.format("%s [%d]",p.Name,math.floor(h.Health))n.Visible=true
                else n.Visible=false end
            else n.Visible=false end end end)end

local function mkL(t)if not S.draw or t==LP or S.lines[t]then return end
    local l=Drawing.new("Line")l.Thickness=1 l.Color=AC l.Visible=false S.lines[t]=l end
local function rmL(t)if S.lines[t]then pcall(function()S.lines[t]:Remove()end)end S.lines[t]=nil end
local function startLine()if S.conns.l then S.conns.l:Disconnect()end
    if not S.eL or not S.draw then for t in pairs(S.lines)do rmL(t)end return end
    S.conns.l=RS.RenderStepped:Connect(function()
        for _,p in ipairs(P:GetPlayers())do
            if p==LP then continue end
            local l=S.lines[p]if not l then mkL(p)continue end
            local c=p.Character local hd=c and c:FindFirstChild("Head")
            local h=c and c:FindFirstChildOfClass("Humanoid")
            local sh=not(S.eT and LP.Team and p.Team==LP.Team)
            if sh and hd and h and h.Health>0 then
                local hs,ho=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
                if ho then l.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
                    l.To=Vector2.new(hs.X,hs.Y)l.Visible=true
                else l.Visible=false end
            else l.Visible=false end end end)end

local function startSpd()if S.conns.spd then S.conns.spd:Disconnect()end
    if not S.spd then return end
    S.conns.spd=RS.PreRender:Connect(function()
        local c=LP.Character if not c then return end
        local rt=c:FindFirstChild("HumanoidRootPart")
        local h=c:FindFirstChildOfClass("Humanoid")
        if not rt or not h or h.MoveDirection.Magnitude<=0.1 then return end
        local rp2=RaycastParams.new()rp2.FilterDescendantsInstances={c}rp2.FilterType=Enum.RaycastFilterType.Exclude
        if WS:Raycast(rt.Position,rt.CFrame.LookVector*2.5,rp2)then
            rt.CFrame=rt.CFrame+Vector3.new(0,S.climbV,0)end end)end

local function startKC()if S.conns.kc then S.conns.kc:Disconnect()end
    if not S.kc then return end
    S.conns.kc=RS.Heartbeat:Connect(function()
        local tn=LP.Team and LP.Team.Name:lower()or""
        if not(tn:find("prisoner")or tn:find("inmate")or tn:find("criminal"))then return end
        local c=LP.Character local rt=c and c:FindFirstChild("HumanoidRootPart")
        if not rt then return end
        for _,o in ipairs(WS:GetDescendants())do
            if o.Name:lower():find("keycard")then
                local p=o:IsA("BasePart")and o or o:FindFirstChildWhichIsA("BasePart")
                if p and(p.Position-rt.Position).Magnitude<S.kcR then
                    rt.CFrame=CFrame.new(p.Position+Vector3.new(0,3,0))end end end end)end

local function hbP(c)local t={}for _,n in ipairs({"Head","HumanoidRootPart","UpperTorso","Torso"})do
    local p=c:FindFirstChild(n)if p then t[#t+1]=p end end return t end
local function startHB()if S.conns.hb then S.conns.hb:Disconnect()end
    if not S.hb then return end
    S.conns.hb=RS.Heartbeat:Connect(function()
        for _,pl in ipairs(P:GetPlayers())do
            if pl==LP then continue end
            local c=pl.Character
            if c then local h=c:FindFirstChildOfClass("Humanoid")
                if h and h.Health>0 and not(S.hbT and LP.Team and pl.Team==LP.Team)then
                    for _,p in ipairs(hbP(c))do
                        if not S.hbS[p]then S.hbS[p]={p.Size,p.Transparency}end
                        p.Size=S.hbS[p][1]*S.hbV end end end end end)end

local function startFOV()if S.conns.fov then S.conns.fov:Disconnect()end
    if not S.fov then if WS.CurrentCamera then WS.CurrentCamera.FieldOfView=defFOV end return end
    S.conns.fov=RS.Heartbeat:Connect(function()
        if WS.CurrentCamera then WS.CurrentCamera.FieldOfView=S.fovV end end)end

local function startFB()if S.conns.fb then S.conns.fb:Disconnect()end
    if not S.fb then return end
    S.conns.fb=RS.Heartbeat:Connect(function()
        LT.Ambient=Color3.fromRGB(200,200,200)LT.OutdoorAmbient=Color3.fromRGB(200,200,200)
        LT.Brightness=3 LT.ClockTime=14 LT.FogEnd=100000 LT.FogStart=100000 end)end

local function startVeh()if S.conns.veh then S.conns.veh:Disconnect()end
    if not S.veh then return end
    S.conns.veh=RS.Heartbeat:Connect(function()
        local c=LP.Character if not c then return end
        local h=c:FindFirstChildOfClass("Humanoid")if not h then return end
        local s=h.SeatPart
        if s then local v=s:FindFirstAncestorOfClass("Model")or s.Parent
            if v then for _,o in ipairs(v:GetDescendants())do
                if o:IsA("VehicleSeat")or o:IsA("Seat")then pcall(function()o.MaxSpeed=S.vehV end)end
            end end end end)end

local function startAll()
    startBox()startName()startLine()startSpin()startSpd()startKC()
    startHB()startArr()startMel()startFOV()startFB()startVeh()wp()
    if S.aim then installAim()end end

local function getCfg()return{walk=S.walk,walkV=S.walkV,jump=S.jump,jumpV=S.jumpV,ij=S.ij,
    spin=S.spin,spinV=S.spinV,eT=S.eT,eB=S.eB,eN=S.eN,eL=S.eL,spd=S.spd,climbV=S.climbV,
    aim=S.aim,aimT=S.aimT,aimW=S.aimW,aimF=S.aimF,aimP=S.aimP,aimC=S.aimC,
    hb=S.hb,hbV=S.hbV,hbT=S.hbT,ammo=S.ammo,rapid=S.rapid,reload=S.reload,
    arr=S.arr,arrR=S.arrR,mel=S.mel,melR=S.melR,atz=S.atz,kc=S.kc,kcR=S.kcR,
    fov=S.fov,fovV=S.fovV,fb=S.fb,veh=S.veh,vehV=S.vehV}end
local function applyCfg(d)
    if not d then return end
    S.walk=d.walk or false S.walkV=d.walkV or 16 S.jump=d.jump or false S.jumpV=d.jumpV or 50
    S.ij=d.ij or false S.spin=d.spin or false S.spinV=d.spinV or 10
    S.eT=d.eT~=false S.eB=d.eB or false S.eN=d.eN or false S.eL=d.eL or false
    S.spd=d.spd or false S.climbV=d.climbV or 0.28
    S.aim=d.aim or false S.aimT=d.aimT~=false S.aimW=d.aimW~=false
    S.aimF=d.aimF or 100 S.aimP=d.aimP or"Head"S.aimC=d.aimC or 100
    S.hb=d.hb or false S.hbV=d.hbV or 3 S.hbT=d.hbT or false
    S.ammo=d.ammo or false S.rapid=d.rapid or false S.reload=d.reload or false
    S.arr=d.arr or false S.arrR=d.arrR or 7.5 S.mel=d.mel or false S.melR=d.melR or 4
    S.atz=d.atz or false S.kc=d.kc or false S.kcR=d.kcR or 20
    S.fov=d.fov or false S.fovV=d.fovV or 70 S.fb=d.fb or false
    S.veh=d.veh or false S.vehV=d.vehV or 100 end
local function saveCur()if S.file then pcall(function()writefile("AH_S.json",HS:JSONEncode(getCfg()))end)end end
local function loadCur()if S.file and isfile("AH_S.json")then pcall(function()applyCfg(HS:JSONDecode(readfile("AH_S.json")))end)end end
local function saveAll()if S.file then pcall(function()writefile("AH_C.json",HS:JSONEncode(S.cfg))end)end end
local function loadAll()if S.file and isfile("AH_C.json")then pcall(function()S.cfg=HS:JSONDecode(readfile("AH_C.json"))end)end end

-- ===== UI =====
local SG=Instance.new("ScreenGui")SG.Name="AH"SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling SG.Parent=PG

local Main=Instance.new("Frame")
Main.Size=UDim2.new(0,720,0,420)Main.Position=UDim2.new(0.5,-360,0.5,-210)
Main.BackgroundColor3=BG Main.BorderSizePixel=0 Main.Active=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",Main).Color=BR

local drag,dS,sP
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true dS=i.Position sP=Main.Position end end)
UIS.InputChanged:Connect(function(i)
    if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
        local d=i.Position-dS
        Main.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)

-- Top
local Top=Instance.new("Frame")
Top.Size=UDim2.new(1,0,0,42)Top.BackgroundColor3=Color3.fromRGB(20,20,24)
Top.BorderSizePixel=0 Top.Parent=Main
Instance.new("UICorner",Top).CornerRadius=UDim.new(0,10)

local Logo=Instance.new("TextLabel")
Logo.Size=UDim2.new(0,50,1,0)Logo.Position=UDim2.new(0,10,0,0)
Logo.BackgroundTransparency=1 Logo.Text="⚡"Logo.TextColor3=AC
Logo.TextSize=20 Logo.Font=Enum.Font.GothamBold Logo.Parent=Top

local TabFrame=Instance.new("Frame")
TabFrame.Size=UDim2.new(1,-300,1,0)TabFrame.Position=UDim2.new(0,60,0,0)
TabFrame.BackgroundTransparency=1 TabFrame.Parent=Top
local TFL=Instance.new("UIListLayout")
TFL.FillDirection=Enum.FillDirection.Horizontal TFL.VerticalAlignment=Enum.VerticalAlignment.Center
TFL.Padding=UDim.new(0,6)TFL.Parent=TabFrame

local Close=Instance.new("TextButton")
Close.Size=UDim2.new(0,28,0,28)Close.Position=UDim2.new(1,-38,0,7)
Close.BackgroundColor3=Color3.fromRGB(40,20,20)Close.Text="✕"
Close.TextColor3=RD Close.TextSize=13 Close.Font=Enum.Font.GothamBold
Close.AutoButtonColor=false Close.Parent=Top
Instance.new("UICorner",Close).CornerRadius=UDim.new(0,6)

local Body=Instance.new("Frame")
Body.Size=UDim2.new(1,-20,1,-55)Body.Position=UDim2.new(0,10,0,50)
Body.BackgroundTransparency=1 Body.Parent=Main

-- Pill
local Pill=Instance.new("Frame")
Pill.Size=UDim2.new(0,140,0,36)Pill.Position=UDim2.new(0.5,-70,0.5,-18)
Pill.BackgroundColor3=Color3.fromRGB(0,0,0)Pill.BackgroundTransparency=0.3
Pill.Visible=false Pill.Parent=SG
Instance.new("UICorner",Pill).CornerRadius=UDim.new(0,18)
Instance.new("UIStroke",Pill).Color=Color3.fromRGB(80,80,80)
local PI=Instance.new("TextLabel")
PI.Size=UDim2.new(0,24,1,0)PI.Position=UDim2.new(0,12,0,0)
PI.BackgroundTransparency=1 PI.Text="⌇"PI.TextColor3=TX PI.TextSize=16
PI.Font=Enum.Font.GothamBold PI.Parent=Pill
local PT=Instance.new("TextLabel")
PT.Size=UDim2.new(1,-45,1,0)PT.Position=UDim2.new(0,36,0,0)
PT.BackgroundTransparency=1 PT.Text="Alpha Hub"PT.TextColor3=TX PT.TextSize=13
PT.Font=Enum.Font.GothamBold PT.TextXAlignment=Enum.TextXAlignment.Left PT.Parent=Pill
local PC=Instance.new("TextButton")
PC.Size=UDim2.new(1,0,1,0)PC.BackgroundTransparency=1 PC.Text=""PC.Parent=Pill

local tD,tS,tSP
PC.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        tD=true tS=i.Position tSP=Pill.Position end end)
UIS.InputChanged:Connect(function(i)
    if tD and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
        local d=i.Position-tS
        Pill.Position=UDim2.new(tSP.X.Scale,tSP.X.Offset+d.X,tSP.Y.Scale,tSP.Y.Offset+d.Y)end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        if tD then tD=false local d=i.Position-tS
            if d.Magnitude<5 then Pill.Visible=false Main.Visible=true end end end end)
Close.MouseButton1Click:Connect(function()Main.Visible=false Pill.Visible=true end)

-- Колонки
local function mkCol(parent)
    local c=Instance.new("ScrollingFrame")
    c.Size=UDim2.new(0.333,-6,1,0)c.BackgroundColor3=BG2
    c.BorderSizePixel=0 c.ScrollBarThickness=3
    c.ScrollBarImageColor3=Color3.fromRGB(60,60,70)
    c.AutomaticCanvasSize=Enum.AutomaticSize.Y
    c.CanvasSize=UDim2.new(0,0,0,0)
    c.Parent=parent
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,6)
    local l=Instance.new("UIListLayout",c)
    l.Padding=UDim.new(0,4)l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",c)
    p.PaddingTop=UDim.new(0,6)p.PaddingBottom=UDim.new(0,6)
    p.PaddingLeft=UDim.new(0,6)p.PaddingRight=UDim.new(0,6)
    return c end

local function mkPage(name)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,1,0)f.BackgroundTransparency=1
    f.Visible=false f.Parent=Body
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,1,0)row.BackgroundTransparency=1 row.Parent=f
    local layout=Instance.new("UIListLayout",row)
    layout.FillDirection=Enum.FillDirection.Horizontal layout.Padding=UDim.new(0,8)layout.Parent=row
    local c1=mkCol(row)c1.LayoutOrder=1
    local c2=mkCol(row)c2.LayoutOrder=2
    local c3=mkCol(row)c3.LayoutOrder=3
    S.pages[name]={frame=f,cols={c1,c2,c3}}end

local tabsList={"Movement","Player","Combat","PL","Config"}
for _,name in ipairs(tabsList)do
    mkPage(name)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,90,0,28)b.BackgroundColor3=BG2
    b.Text=name b.TextColor3=T2 b.TextSize=11 b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0 b.AutoButtonColor=false b.Parent=TabFrame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    S.tabs[name]=b
    b.MouseButton1Click:Connect(function()
        S.cur=name
        for n,p in pairs(S.pages)do p.frame.Visible=(n==name)end
        for n,bt in pairs(S.tabs)do
            if n==name then bt.BackgroundColor3=AC bt.TextColor3=Color3.fromRGB(255,255,255)
            else bt.BackgroundColor3=BG2 bt.TextColor3=T2 end
        end
    end)
end
S.tabs["Movement"].BackgroundColor3=AC
S.tabs["Movement"].TextColor3=Color3.fromRGB(255,255,255)
S.pages["Movement"].frame.Visible=true

local function mkSection(parent,text)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,20)l.BackgroundTransparency=1
    l.Text=text l.TextColor3=AC l.Font=Enum.Font.GothamBold
    l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=parent end

local function mkToggle(parent,text,key,onChange)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,24)row.BackgroundTransparency=1 row.Parent=parent
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-40,1,0)lbl.BackgroundTransparency=1
    lbl.Text=text lbl.TextColor3=TX lbl.TextSize=11 lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=row
    local sw=Instance.new("TextButton")
    sw.Size=UDim2.new(0,26,0,14)sw.Position=UDim2.new(1,-30,0.5,-7)
    sw.BackgroundColor3=BG3 sw.Text=""sw.AutoButtonColor=false sw.Parent=row
    Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,10,0,10)dot.Position=UDim2.new(0,2,0.5,-5)
    dot.BackgroundColor3=Color3.fromRGB(120,120,130)dot.BorderSizePixel=0 dot.Parent=sw
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local state=false
    local function set(v,fire)
        state=v
        if v then tw(sw,0.15,{BackgroundColor3=GN})
            tw(dot,0.15,{Position=UDim2.new(1,-12,0.5,-5),BackgroundColor3=Color3.fromRGB(20,20,25)})
        else tw(sw,0.15,{BackgroundColor3=BG3})
            tw(dot,0.15,{Position=UDim2.new(0,2,0.5,-5),BackgroundColor3=Color3.fromRGB(120,120,130)})end
        if fire and onChange then pcall(onChange,v)end end
    sw.MouseButton1Click:Connect(function()set(not state)saveCur()end)
    S.switches[key]={set=set,get=function()return state end}end

local function mkSlider(parent,text,key,mn,mx,df,onChange)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,26)row.BackgroundTransparency=1 row.Parent=parent
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0.55,0,0,12)lbl.BackgroundTransparency=1
    lbl.Text=text lbl.TextColor3=T2 lbl.TextSize=10 lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=row
    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0.45,0,0,12)vl.Position=UDim2.new(0.55,0,0,0)
    vl.BackgroundTransparency=1 vl.Text=string.format("%.2f",df)
    vl.TextColor3=AC vl.TextSize=10 vl.Font=Enum.Font.GothamBold
    vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=row
    local sb=Instance.new("TextButton")
    sb.Size=UDim2.new(1,0,0,3)sb.Position=UDim2.new(0,0,0,20)
    sb.BackgroundColor3=BG3 sb.Text=""sb.AutoButtonColor=false sb.Parent=row
    Instance.new("UICorner",sb).CornerRadius=UDim.new(1,0)
    local fl=Instance.new("Frame")
    local pc=(df-mn)/(mx-mn)
    fl.Size=UDim2.new(pc,0,1,0)fl.BackgroundColor3=AC fl.BorderSizePixel=0 fl.Parent=sb
    Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local cur=df
    local dragging=false
    local function upd(off)cur=mn+(mx-mn)*off fl.Size=UDim2.new(off,0,1,0)
        vl.Text=string.format("%.2f",cur)pcall(onChange,cur)end
    local function fromI(i)local off=math.clamp((i.Position.X-sb.AbsolutePosition.X)/sb.AbsoluteSize.X,0,1)upd(off)end
    sb.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true fromI(i)end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then fromI(i)end end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if dragging then dragging=false saveCur()end end end)
    S.sliders[key]={set=function(v)cur=math.clamp(v,mn,mx)upd((cur-mn)/(mx-mn))end,get=function()return cur end}end

-- MOVEMENT
local c=S.pages["Movement"].cols
mkSection(c[1],"ДВИЖЕНИЕ")
mkToggle(c[1],"Walk Speed","walk",function(v)S.walk=v wd()end)
mkSlider(c[1],"Скорость","walkV",1,500,16,function(v)S.walkV=v end)
mkToggle(c[1],"Jump Power","jump",function(v)S.jump=v wd()end)
mkSlider(c[1],"Прыжок","jumpV",1,500,50,function(v)S.jumpV=v end)
mkToggle(c[1],"Infinite Jump","ij",function(v)S.ij=v end)
mkToggle(c[1],"Spider","spd",function(v)S.spd=v startSpd()end)
mkSlider(c[1],"Climb Speed","climbV",1,20,3,function(v)S.climbV=v/10 end)
mkToggle(c[1],"Vehicle Speed","veh",function(v)S.veh=v startVeh()end)
mkSlider(c[1],"Veh Speed","vehV",50,500,100,function(v)S.vehV=v end)

-- PLAYER
local c=S.pages["Player"].cols
mkSection(c[1],"ESP")
mkToggle(c[1],"ESP Boxes","eB",function(v)S.eB=v startBox()end)
mkToggle(c[1],"ESP Names","eN",function(v)S.eN=v startName()end)
mkToggle(c[1],"ESP Lines","eL",function(v)S.eL=v startLine()end)
mkToggle(c[1],"Team Check","eT",function(v)S.eT=v end)
mkSection(c[2],"ВИЗУАЛ")
mkToggle(c[2],"Fullbright","fb",function(v)S.fb=v startFB()end)
mkToggle(c[2],"FOV Changer","fov",function(v)S.fov=v startFOV()end)
mkSlider(c[2],"FOV","fovV",30,120,70,function(v)S.fovV=v end)
mkToggle(c[2],"Spin","spin",function(v)S.spin=v startSpin()end)
mkSlider(c[2],"Spin Rate","spinV",1,50,10,function(v)S.spinV=v end)

-- COMBAT
local c=S.pages["Combat"].cols
mkSection(c[1],"AIM")
mkToggle(c[1],"Silent Aim","aim",function(v)S.aim=v if v then installAim()end end)
mkToggle(c[1],"Team Check","aimT",function(v)S.aimT=v end)
mkToggle(c[1],"Wall Check","aimW",function(v)S.aimW=v end)
mkSlider(c[1],"Hit Chance","aimC",1,100,100,function(v)S.aimC=v end)
mkSection(c[1],"HITBOX")
mkToggle(c[1],"Hitbox","hb",function(v)S.hb=v startHB()end)
mkSlider(c[1],"Size","hbV",1,10,3,function(v)S.hbV=v end)
mkToggle(c[1],"Team Check","hbT",function(v)S.hbT=v end)
mkSection(c[2],"ОРУЖИЕ")
mkToggle(c[2],"Infinite Ammo","ammo",function(v)S.ammo=v wp()end)
mkToggle(c[2],"Rapid Fire","rapid",function(v)S.rapid=v wp()end)
mkToggle(c[2],"Instant Reload","reload",function(v)S.reload=v wp()end)

-- PL
local c=S.pages["PL"].cols
mkSection(c[1],"PRISON LIFE")
mkToggle(c[1],"Auto Keycard","kc",function(v)S.kc=v startKC()end)
mkSlider(c[1],"Range","kcR",10,100,20,function(v)S.kcR=v end)
mkToggle(c[1],"Arrest Aura","arr",function(v)S.arr=v startArr()end)
mkSlider(c[1],"Arrest R","arrR",1,15,7.5,function(v)S.arrR=v end)
mkToggle(c[1],"Melee Aura","mel",function(v)S.mel=v startMel()end)
mkSlider(c[1],"Melee R","melR",1,9,4,function(v)S.melR=v end)
mkToggle(c[1],"Anti-Taze","atz",function(v)S.atz=v end)
mkSection(c[2],"TELEPORTS")
local tps={["Оружейная"]=Vector3.new(826.2,101.5,2294.9),["Кафетерий"]=Vector3.new(924.5,101.5,2227.6),
    ["База"]=Vector3.new(-975,109.8,2058),["Секретка"]=Vector3.new(701.5,101.5,2354.3),
    ["Двор"]=Vector3.new(795.8,99.7,2541),["Тюрьма"]=Vector3.new(915.3,101.5,2388)}
for name,pos in pairs(tps)do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,24)b.BackgroundColor3=BG3
    b.Text="📍 "..name b.TextColor3=TX b.TextSize=10 b.Font=Enum.Font.Gotham
    b.AutoButtonColor=false b.Parent=c[2]
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    b.MouseButton1Click:Connect(function()
        local ch=LP.Character local r=ch and ch:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(pos+Vector3.new(0,3,0))end end)end

-- CONFIG
local c=S.pages["Config"].cols
mkSection(c[1],"КОНФИГИ")
local nameI=Instance.new("TextBox")
nameI.Size=UDim2.new(1,0,0,26)nameI.BackgroundColor3=BG3
nameI.PlaceholderText="Имя конфига..."nameI.PlaceholderColor3=T2
nameI.Text=""nameI.TextColor3=TX nameI.TextSize=11 nameI.Font=Enum.Font.Gotham
nameI.Parent=c[1]Instance.new("UICorner",nameI).CornerRadius=UDim.new(0,4)
local saveB=Instance.new("TextButton")
saveB.Size=UDim2.new(1,0,0,26)saveB.BackgroundColor3=GN
saveB.Text="Сохранить"saveB.TextColor3=Color3.fromRGB(255,255,255)
saveB.TextSize=11 saveB.Font=Enum.Font.GothamBold saveB.AutoButtonColor=false saveB.Parent=c[1]
Instance.new("UICorner",saveB).CornerRadius=UDim.new(0,4)

local listScroll=Instance.new("ScrollingFrame")
listScroll.Size=UDim2.new(1,0,0,200)listScroll.BackgroundTransparency=1
listScroll.ScrollBarThickness=3 listScroll.Parent=c[2]
Instance.new("UIListLayout",listScroll).Padding=UDim.new(0,3)

local function rebuild()
    for _,x in ipairs(listScroll:GetChildren())do if x:IsA("Frame")then x:Destroy()end end
    for name,_ in pairs(S.cfg)do
        local r=Instance.new("Frame")
        r.Size=UDim2.new(1,0,0,24)r.BackgroundColor3=BG3 r.BorderSizePixel=0 r.Parent=listScroll
        Instance.new("UICorner",r).CornerRadius=UDim.new(0,4)
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-70,1,0)l.Position=UDim2.new(0,6,0,0)
        l.BackgroundTransparency=1 l.Text=name l.TextColor3=TX l.TextSize=10
        l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=r
        local lb=Instance.new("TextButton")
        lb.Size=UDim2.new(0,30,0,20)lb.Position=UDim2.new(1,-60,0.5,-10)
        lb.BackgroundColor3=AC lb.Text="L"lb.TextColor3=Color3.fromRGB(255,255,255)
        lb.TextSize=10 lb.Font=Enum.Font.GothamBold lb.AutoButtonColor=false lb.Parent=r
        Instance.new("UICorner",lb).CornerRadius=UDim.new(0,4)
        local db=Instance.new("TextButton")
        db.Size=UDim2.new(0,30,0,20)db.Position=UDim2.new(1,-28,0.5,-10)
        db.BackgroundColor3=RD db.Text="X"db.TextColor3=Color3.fromRGB(255,255,255)
        db.TextSize=10 db.Font=Enum.Font.GothamBold db.AutoButtonColor=false db.Parent=r
        Instance.new("UICorner",db).CornerRadius=UDim.new(0,4)
        lb.MouseButton1Click:Connect(function()
            if S.cfg[name]then applyCfg(S.cfg[name])startAll()saveCur()end end)
        db.MouseButton1Click:Connect(function()S.cfg[name]=nil saveAll()rebuild()end)end end
saveB.MouseButton1Click:Connect(function()
    if nameI.Text==""then return end
    S.cfg[nameI.Text]=getCfg()nameI.Text=""saveAll()rebuild()end)

-- START
loadAll()loadCur()startAll()rebuild()
local function onChar(ch)
    ch:WaitForChild("Humanoid",5)task.wait(0.3)
    local h=ch:FindFirstChildOfClass("Humanoid")if not h then return end
    if S.walk then h.WalkSpeed=S.walkV end
    if S.jump then h.JumpPower=S.jumpV end
    startAll()end
LP.CharacterAdded:Connect(onChar)
if LP.Character then task.spawn(onChar,LP.Character)end
wd()
task.spawn(function()while true do task.wait(10)saveCur()end end)

-- ПРИНУДИТЕЛЬНАЯ ПЕРЕРИСОВКА
task.wait(0.3)
for name,page in pairs(S.pages)do
    for _,col in ipairs(page.cols)do
        local l=col:FindFirstChildOfClass("UIListLayout")
        if l then col.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+30)end end end

print("✨ Alpha Hub PL — загружено!")