
local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Limpeza
if PlayerGui:FindFirstChild("CombatHub") then PlayerGui.CombatHub:Destroy() end

-- ════════════════════════════════════════════════════════════════
-- UTILS
-- ════════════════════════════════════════════════════════════════
local function addCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p; return c
end
local function addStroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(38,38,38)
    s.Thickness = thick or 1
    s.Parent = p; return s
end
local function tw(o, props, t)
    TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart), props):Play()
end
local function makeDrag(handle, target)
    target = target or handle
    local dr, ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dr=true; ds=i.Position; sp=target.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then dr=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if dr and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- BORDA ANIMADA
-- ════════════════════════════════════════════════════════════════
local Root = Instance.new("ScreenGui")
Root.Name           = "CombatHub"
Root.ResetOnSpawn   = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.Parent         = PlayerGui

local activeBorders = {}
local function createBorder(targetFrame, thickness)
    thickness = thickness or 2
    local border = Instance.new("Frame")
    border.BackgroundColor3 = Color3.fromRGB(255,255,255)
    border.BorderSizePixel  = 0
    border.ZIndex           = targetFrame.ZIndex - 1
    border.Parent           = Root
    addCorner(border, 14)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(8,  8,  8  )),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(55, 55, 55 )),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(150,150,150)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(150,150,150)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(55, 55, 55 )),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(8,  8,  8  )),
    })
    grad.Parent = border

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not border.Parent then return end
        border.Visible  = targetFrame.Visible
        border.Size     = UDim2.new(0, targetFrame.AbsoluteSize.X + thickness*2,
                                    0, targetFrame.AbsoluteSize.Y + thickness*2)
        border.Position = UDim2.new(0, targetFrame.AbsolutePosition.X - thickness,
                                    0, targetFrame.AbsolutePosition.Y - thickness)
    end)

    task.spawn(function()
        local rot = 0
        while border.Parent do
            rot = (rot+1)%360; grad.Rotation = rot; task.wait(0.016)
        end
    end)

    table.insert(activeBorders, border)
    return border
end

-- ════════════════════════════════════════════════════════════════
-- JANELA PRINCIPAL
-- ════════════════════════════════════════════════════════════════
local WIN_W, WIN_H = 260, 340

local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position         = UDim2.new(0.5, -WIN_W/2, 0.4, -WIN_H/2)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.ZIndex           = 10
Main.Parent           = Root
addCorner(Main, 14)

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8 )),
})
bgGrad.Rotation = 90; bgGrad.Parent = Main
createBorder(Main, 3)

-- ── Header ───────────────────────────────────────────────────────
local Header = Instance.new("Frame")
Header.Size              = UDim2.new(1,0,0,48)
Header.BackgroundColor3  = Color3.fromRGB(14,14,14)
Header.BackgroundTransparency = 0.2
Header.BorderSizePixel   = 0
Header.ZIndex            = 11
Header.Parent            = Main
addCorner(Header, 14)
-- tapa canto inferior
local hf=Instance.new("Frame"); hf.Size=UDim2.new(1,0,0,14); hf.Position=UDim2.new(0,0,1,-14)
hf.BackgroundColor3=Color3.fromRGB(14,14,14); hf.BackgroundTransparency=0.2
hf.BorderSizePixel=0; hf.ZIndex=11; hf.Parent=Header
-- divisor
local hd=Instance.new("Frame"); hd.Size=UDim2.new(1,-32,0,1); hd.Position=UDim2.new(0,16,1,0)
hd.BackgroundColor3=Color3.fromRGB(28,28,28); hd.BorderSizePixel=0; hd.ZIndex=12; hd.Parent=Header

makeDrag(Header, Main)

-- Ícone
local hIco=Instance.new("TextLabel"); hIco.Size=UDim2.new(0,28,0,28)
hIco.Position=UDim2.new(0,12,0.5,-14); hIco.Text="⚔"
hIco.TextSize=16; hIco.Font=Enum.Font.GothamBold
hIco.BackgroundColor3=Color3.fromRGB(20,20,20); hIco.TextColor3=Color3.fromRGB(210,210,210)
hIco.ZIndex=12; hIco.Parent=Header; addCorner(hIco,7)

-- Título
local hTitle=Instance.new("TextLabel"); hTitle.Size=UDim2.new(0,150,0,16)
hTitle.Position=UDim2.new(0,50,0,8); hTitle.Text="Combat Hub"
hTitle.TextSize=12; hTitle.Font=Enum.Font.GothamBold
hTitle.TextColor3=Color3.fromRGB(225,225,225); hTitle.BackgroundTransparency=1
hTitle.TextXAlignment=Enum.TextXAlignment.Left; hTitle.ZIndex=12; hTitle.Parent=Header

local hSub=Instance.new("TextLabel"); hSub.Size=UDim2.new(0,160,0,12)
hSub.Position=UDim2.new(0,50,0,26); hSub.Text="Auto Atk & Defense"
hSub.TextSize=8; hSub.Font=Enum.Font.Gotham
hSub.TextColor3=Color3.fromRGB(60,60,60); hSub.BackgroundTransparency=1
hSub.TextXAlignment=Enum.TextXAlignment.Left; hSub.ZIndex=12; hSub.Parent=Header

-- Botão minimizar
local MinBtn=Instance.new("TextButton"); MinBtn.Size=UDim2.new(0,24,0,24)
MinBtn.Position=UDim2.new(1,-58,0.5,-12); MinBtn.Text="−"
MinBtn.TextSize=14; MinBtn.Font=Enum.Font.GothamBold
MinBtn.TextColor3=Color3.fromRGB(130,130,130)
MinBtn.BackgroundColor3=Color3.fromRGB(22,22,22); MinBtn.BorderSizePixel=0
MinBtn.AutoButtonColor=false; MinBtn.ZIndex=13; MinBtn.Parent=Header
addCorner(MinBtn,6); addStroke(MinBtn,Color3.fromRGB(35,35,35))
MinBtn.MouseEnter:Connect(function() tw(MinBtn,{TextColor3=Color3.fromRGB(220,220,220)}) end)
MinBtn.MouseLeave:Connect(function() tw(MinBtn,{TextColor3=Color3.fromRGB(130,130,130)}) end)

-- Botão fechar
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,24,0,24)
CloseBtn.Position=UDim2.new(1,-28,0.5,-12); CloseBtn.Text="✕"
CloseBtn.TextSize=10; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.TextColor3=Color3.fromRGB(100,100,100)
CloseBtn.BackgroundColor3=Color3.fromRGB(22,22,22); CloseBtn.BorderSizePixel=0
CloseBtn.AutoButtonColor=false; CloseBtn.ZIndex=13; CloseBtn.Parent=Header
addCorner(CloseBtn,6); addStroke(CloseBtn,Color3.fromRGB(35,35,35))
CloseBtn.MouseEnter:Connect(function() tw(CloseBtn,{TextColor3=Color3.fromRGB(210,60,60)}) end)
CloseBtn.MouseLeave:Connect(function() tw(CloseBtn,{TextColor3=Color3.fromRGB(100,100,100)}) end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

-- ── Área de conteúdo (minimizável) ──────────────────────────────
local Content = Instance.new("Frame")
Content.Name             = "Content"
Content.Size             = UDim2.new(1,0,1,-52)
Content.Position         = UDim2.new(0,0,0,52)
Content.BackgroundTransparency = 1
Content.ZIndex           = 11
Content.Parent           = Main

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding   = UDim.new(0,6)
contentLayout.Parent    = Content

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop   = UDim.new(0,8)
contentPad.PaddingBottom = UDim.new(0,8)
contentPad.PaddingLeft  = UDim.new(0,12)
contentPad.PaddingRight = UDim.new(0,12)
contentPad.Parent       = Content

-- Minimizar: mostra/oculta Content e redimensiona Main
local minimized = false
local FULL_H = WIN_H
local MINI_H = 52

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "−"
    tw(Main, {Size = UDim2.new(0, WIN_W, 0, minimized and MINI_H or FULL_H)}, 0.22)
    Content.Visible = not minimized
end)

-- ════════════════════════════════════════════════════════════════
-- BOTÕES DE TOGGLE
-- ════════════════════════════════════════════════════════════════
local BTN_LABELS = {
    atk     = "Attack",
    hatk    = "H Attack",
    hback   = "H BackAttack",
    back    = "BackAttack",
    autoDef = "Auto Defense",
}
local BTN_ORDER = {"atk","hatk","hback","back","autoDef"}

local states   = {atk=false,hatk=false,hback=false,back=false,autoDef=false}
local btnRefs  = {}

local function makeToggleBtn(key, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,38)
    row.BackgroundColor3 = Color3.fromRGB(16,16,16)
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 12
    row.Parent           = Content
    addCorner(row, 9); addStroke(row, Color3.fromRGB(26,26,26))

    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-70,1,0)
    lbl.Position=UDim2.new(0,12,0,0); lbl.Text=BTN_LABELS[key]
    lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
    lbl.TextColor3=Color3.fromRGB(160,160,160); lbl.BackgroundTransparency=1
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13; lbl.Parent=row

    local pill=Instance.new("TextButton"); pill.Size=UDim2.new(0,42,0,20)
    pill.Position=UDim2.new(1,-52,0.5,-10)
    pill.BackgroundColor3=Color3.fromRGB(28,28,28)
    pill.Text=""; pill.AutoButtonColor=false; pill.ZIndex=13; pill.Parent=row
    addCorner(pill,10)

    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14)
    knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(80,80,80)
    knob.ZIndex=14; knob.Parent=pill; addCorner(knob,7)

    local statusDot=Instance.new("Frame"); statusDot.Size=UDim2.new(0,6,0,6)
    statusDot.Position=UDim2.new(0,0,0.5,-3)
    statusDot.BackgroundColor3=Color3.fromRGB(55,55,55)
    statusDot.ZIndex=13; statusDot.Parent=row; addCorner(statusDot,3)

    local function setOn(v)
        states[key]=v
        tw(pill,{BackgroundColor3=v and Color3.fromRGB(45,45,45) or Color3.fromRGB(28,28,28)})
        tw(knob,{
            Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=v and Color3.fromRGB(230,230,230) or Color3.fromRGB(80,80,80),
        })
        tw(statusDot,{BackgroundColor3=v and Color3.fromRGB(120,220,80) or Color3.fromRGB(55,55,55)})
        tw(lbl,{TextColor3=v and Color3.fromRGB(210,210,210) or Color3.fromRGB(160,160,160)})
    end

    pill.MouseButton1Click:Connect(function()
        setOn(not states[key])
    end)

    btnRefs[key] = {pill=pill,knob=knob,dot=statusDot,lbl=lbl,setOn=setOn}
    return row
end

for i, key in ipairs(BTN_ORDER) do
    makeToggleBtn(key, i)
end

-- ════════════════════════════════════════════════════════════════
-- KEYBIND ROW
-- ════════════════════════════════════════════════════════════════
local sepLine=Instance.new("Frame"); sepLine.Size=UDim2.new(1,0,0,1)
sepLine.BackgroundColor3=Color3.fromRGB(22,22,22); sepLine.BorderSizePixel=0
sepLine.LayoutOrder=10; sepLine.ZIndex=12; sepLine.Parent=Content

local currentKeybind = Enum.KeyCode.RightShift
local waitingKey     = false

local kbRow=Instance.new("Frame"); kbRow.Size=UDim2.new(1,0,0,34)
kbRow.BackgroundColor3=Color3.fromRGB(14,14,14); kbRow.BackgroundTransparency=0.4
kbRow.BorderSizePixel=0; kbRow.LayoutOrder=11; kbRow.ZIndex=12; kbRow.Parent=Content
addCorner(kbRow,9); addStroke(kbRow,Color3.fromRGB(26,26,26))

local kbIco=Instance.new("TextLabel"); kbIco.Size=UDim2.new(0,16,1,0)
kbIco.Position=UDim2.new(0,10,0,0); kbIco.Text="⌨"
kbIco.TextSize=11; kbIco.Font=Enum.Font.GothamBold
kbIco.TextColor3=Color3.fromRGB(90,90,90); kbIco.BackgroundTransparency=1
kbIco.ZIndex=13; kbIco.Parent=kbRow

local kbLbl=Instance.new("TextLabel"); kbLbl.Size=UDim2.new(0,80,1,0)
kbLbl.Position=UDim2.new(0,30,0,0); kbLbl.Text="Keybind"
kbLbl.TextSize=10; kbLbl.Font=Enum.Font.Gotham
kbLbl.TextColor3=Color3.fromRGB(120,120,120); kbLbl.BackgroundTransparency=1
kbLbl.TextXAlignment=Enum.TextXAlignment.Left; kbLbl.ZIndex=13; kbLbl.Parent=kbRow

local kbBtn=Instance.new("TextButton"); kbBtn.Size=UDim2.new(0,90,0,22)
kbBtn.Position=UDim2.new(1,-98,0.5,-11); kbBtn.Text="RightShift"
kbBtn.TextSize=9; kbBtn.Font=Enum.Font.GothamBold
kbBtn.TextColor3=Color3.fromRGB(180,180,180)
kbBtn.BackgroundColor3=Color3.fromRGB(22,22,22); kbBtn.BorderSizePixel=0
kbBtn.AutoButtonColor=false; kbBtn.ZIndex=13; kbBtn.Parent=kbRow
addCorner(kbBtn,6); addStroke(kbBtn,Color3.fromRGB(38,38,38))

kbBtn.MouseButton1Click:Connect(function()
    if waitingKey then return end
    waitingKey=true
    kbBtn.Text="Aguardando..."
    tw(kbBtn,{TextColor3=Color3.fromRGB(220,220,220)})
end)

-- ════════════════════════════════════════════════════════════════
-- BOTÃO EXTERNO (toggle-all flutuante)
-- ════════════════════════════════════════════════════════════════
local ExtGui = Instance.new("ScreenGui")
ExtGui.Name           = "CombatHubExt"
ExtGui.ResetOnSpawn   = false
ExtGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ExtGui.Parent         = PlayerGui

local ExtBtn=Instance.new("TextButton")
ExtBtn.Size             = UDim2.new(0,120,0,40)
ExtBtn.Position         = UDim2.new(0,15,0,15)
ExtBtn.Text             = "⚔  Combat"
ExtBtn.TextSize         = 12
ExtBtn.Font             = Enum.Font.GothamBold
ExtBtn.TextColor3       = Color3.fromRGB(190,190,190)
ExtBtn.BackgroundColor3 = Color3.fromRGB(12,12,12)
ExtBtn.BorderSizePixel  = 0
ExtBtn.AutoButtonColor  = false
ExtBtn.ZIndex           = 10
ExtBtn.Parent           = ExtGui
addCorner(ExtBtn,10)

-- borda animada no ExtBtn
do
    local eb=Instance.new("Frame")
    eb.BackgroundColor3=Color3.fromRGB(255,255,255); eb.BorderSizePixel=0
    eb.ZIndex=9; eb.Parent=ExtGui; addCorner(eb,12)
    local eg=Instance.new("UIGradient")
    eg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(8,8,8)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,8,8)),
    }); eg.Parent=eb
    game:GetService("RunService").RenderStepped:Connect(function()
        eb.Size=UDim2.new(0,ExtBtn.AbsoluteSize.X+4,0,ExtBtn.AbsoluteSize.Y+4)
        eb.Position=UDim2.new(0,ExtBtn.AbsolutePosition.X-2,0,ExtBtn.AbsolutePosition.Y-2)
    end)
    task.spawn(function()
        local r=0
        while eb.Parent do r=(r+1)%360; eg.Rotation=r; task.wait(0.016) end
    end)
end

makeDrag(ExtBtn)
ExtBtn.MouseEnter:Connect(function() tw(ExtBtn,{TextColor3=Color3.fromRGB(255,255,255)}) end)
ExtBtn.MouseLeave:Connect(function() tw(ExtBtn,{TextColor3=Color3.fromRGB(190,190,190)}) end)

-- Status do toggle-all
local allOn = false

local function setAllStates(v)
    allOn = v
    for _,key in ipairs(BTN_ORDER) do
        if btnRefs[key] then
            btnRefs[key].setOn(v)
        end
    end
    tw(ExtBtn,{
        BackgroundColor3 = v and Color3.fromRGB(18,28,18) or Color3.fromRGB(12,12,12),
        TextColor3       = v and Color3.fromRGB(140,230,100) or Color3.fromRGB(190,190,190),
    })
    ExtBtn.Text = v and "⚔  ATIVO" or "⚔  Combat"
end

ExtBtn.MouseButton1Click:Connect(function()
    setAllStates(not allOn)
end)

-- ════════════════════════════════════════════════════════════════
-- KEYBIND — toggle-all + abrir/fechar GUI
-- ════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Captura nova tecla
    if waitingKey and input.UserInputType==Enum.UserInputType.Keyboard then
        currentKeybind = input.KeyCode
        kbBtn.Text     = input.KeyCode.Name
        tw(kbBtn,{TextColor3=Color3.fromRGB(180,180,180)})
        waitingKey = false
        return
    end

    if input.KeyCode == currentKeybind then
        setAllStates(not allOn)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- LÓGICA ORIGINAL (intocada) - Trocado Shii-Cho por Crossguard
-- ════════════════════════════════════════════════════════════════
local Remote = ReplicatedStorage:WaitForChild("SBModules")
    :WaitForChild("Remotes"):WaitForChild("State")

local function runAttack()
    while states.atk do
        local char=LocalPlayer.Character
        local weapon=char and char:FindFirstChild("Crossguard")
        if weapon then
            for i=1,5 do
                if not states.atk then break end
                Remote:FireServer(weapon,"Crossguard","Attack",i,
                    ReplicatedStorage.Animations.Attacks.Form1.Level2["AT"..i],
                    {attacktime=0.3,staminadrain=0,
                     animation=ReplicatedStorage.Animations.Attacks.Form1.Level2["AT"..i],
                     soundname="Attack"..i})
                task.wait(0.1)
            end
        end
        task.wait()
    end
end

local function runHAttack()
    while states.hatk do
        local char=LocalPlayer.Character
        local weapon=char and char:FindFirstChild("Crossguard")
        if weapon then
            Remote:FireServer(weapon,"Crossguard","HeavyAttack",1,
                ReplicatedStorage.Animations.Attacks.Backhand.AT1,
                {attacktime=0.3,staminadrain=0,
                 animation=ReplicatedStorage.Animations.Attacks.Backhand.AT1,
                 soundname="Attack1"})
        end
        task.wait(0.1)
    end
end

local function runHBackAttack()
    while states.hback do
        local char=LocalPlayer.Character
        local weapon=char and char:FindFirstChild("Crossguard")
        if weapon then
            Remote:FireServer(weapon,"Crossguard","BackAttack",1,
                ReplicatedStorage.Animations.Backattack.Anakin,
                {attacktime=0.3,staminadrain=0,
                 animation=ReplicatedStorage.Animations.Backattack.Anakin,
                 sound1="Attack2",sound2="Attack3"})
        end
        task.wait(0.1)
    end
end

local function runBackAttack()
    while states.back do
        local char=LocalPlayer.Character
        local weapon=char and char:FindFirstChild("Crossguard")
        if weapon then
            Remote:FireServer(weapon,"Crossguard","BackAttack",1,
                ReplicatedStorage.Animations.Backattack.Anakin,
                {attacktime=0.3,staminadrain=0,
                 animation=ReplicatedStorage.Animations.Backattack.Anakin,
                 sound1="Attack2",sound2="Attack3"})
        end
        task.wait()
    end
end

local function runAutoDef()
    while states.autoDef do
        local char=LocalPlayer.Character
        local weapon=char and char:FindFirstChild("Crossguard")
        if weapon then
            Remote:FireServer(weapon,"Crossguard","Block")
            Remote:FireServer(weapon,"Crossguard","BackCounter")
        end
        task.wait(0.1)
    end
end

-- Conecta pills aos loops
local loopFns = {
    atk     = runAttack,
    hatk    = runHAttack,
    hback   = runHBackAttack,
    back    = runBackAttack,
    autoDef = runAutoDef,
}

for _,key in ipairs(BTN_ORDER) do
    local ref = btnRefs[key]
    local origSetOn = ref.setOn
    ref.setOn = function(v)
        origSetOn(v)
        if v then task.spawn(loopFns[key]) end
    end
    ref.pill.MouseButton1Click:Connect(function() end) -- já conectado acima
end

-- Reconecta clicks das pills com os loops
for _,key in ipairs(BTN_ORDER) do
    local ref = btnRefs[key]
    -- desconecta anterior e reconecta com loop
    ref.pill:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        -- loop já iniciado pelo setOn acima
    end)
end

-- Garante que os clicks das pills disparem os loops
for _,key in ipairs(BTN_ORDER) do
    local ref   = btnRefs[key]
    local fn    = loopFns[key]
    ref.pill.MouseButton1Click:Connect(function()
        if states[key] then
            task.spawn(fn)
        end
    end)
end

print("[CombatHub] Carregado. Keybind padrão: RightShift")
