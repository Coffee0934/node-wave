-- Node Wave 2.2.2: script-first, bilingual controller with an on-demand media preview.
local fusion = fu or fusion
if not fusion then error("Node Wave: Fusion is unavailable") end
local ui = fusion.UIManager
if not ui then error("Node Wave: UIManager is unavailable") end
local disp = bmd.UIDispatcher(ui)

local fields = {
    {"Amplitude", 0.08, 0, 0.4}, {"Frequency", 1, 0, 10},
    {"Speed", 1, 0, 4}, {"Direction", 0, -75, 75},
    {"Phase", 0, -360, 360}, {"Stiffness", 0.5, 0, 1},
    {"Damping", 0.15, 0, 1}, {"FollowDelay", 0.6, 0, 6.28},
    {"Irregularity", 0.12, 0, 1}, {"RootLock", 0.2, 0, 0.8},
    {"TipInfluence", 1, 0, 2}, {"BendAmount", 0.7, 0, 2},
    {"Falloff", 0.25, 0.02, 1},
}
local presets = {
    Gentle = {Amplitude=0.05, Frequency=0.7, Speed=1, Stiffness=0.5, Damping=0.25, FollowDelay=0.5, Irregularity=0.06},
    Wind = {Amplitude=0.16, Frequency=1.3, Speed=1.2, Stiffness=0.25, Damping=0.1, FollowDelay=1.2, Irregularity=0.4},
    Elastic = {Amplitude=0.12, Frequency=1.7, Speed=1, Stiffness=0.8, Damping=0.08, FollowDelay=1.8, Irregularity=0.1},
    Floating = {Amplitude=0.09, Frequency=0.45, Speed=0.8, Stiffness=0.15, Damping=0.35, FollowDelay=0.35, Irregularity=0.2},
}
local strings = {
    ko = {
        language="English", setup="시작", motion="움직임", behavior="움직임 성질", region="변형 범위",
        presets="빠른 설정", actions="리깅 관리", preview="미디어 미리보기",
        intro="이미지 노드를 선택하고 리깅 만들기를 누르세요.",
        pointHelp="Root/Tip: Fusion 뷰어에서 조절",
        motionHelp="흔들림의 크기, 횟수와 방향을 정합니다.",
        behaviorHelp="탄성과 불규칙한 움직임을 조절합니다.",
        regionHelp="고정할 부분과 휘어지는 범위를 정합니다.",
        previewHelp="설정 적용이나 새로고침 때 현재 프레임을 표시합니다.",
        create="리깅 만들기", select="리깅 불러오기", reset="기본값 복원",
        apply="설정 적용", update="다시 적용", disable="켜기 / 끄기", remove="리깅 제거",
        gentle="잔잔하게", wind="바람", elastic="탄성", floating="둥실", custom="직접 설정",
        original="원본", result="결과", frame="프레임", refresh="새로고침",
        noRig="Node Wave 리깅을 먼저 선택하세요.", noComp="Fusion 컴포지션을 먼저 여세요.",
        noSource="이미지를 출력하는 노드를 선택하세요.", needRestart="새 Node Wave 엔진은 다음 Resolve 실행 때 등록됩니다.",
        selected="리깅을 불러왔습니다. Root와 Tip을 뷰어에서 조절하세요.", created="리깅을 만들었습니다.",
        updated="설정을 적용했습니다.", disabled="리깅을 껐습니다.", enabled="리깅을 켰습니다.",
        removed="리깅을 제거하고 원본 연결을 복구했습니다.", resetDone="기본값으로 복원했습니다.",
        already="이미 리깅이 선택되어 있습니다.", presetLoaded="빠른 설정을 불러왔습니다. 설정 적용을 누르세요.",
        customHint="값을 직접 바꾼 뒤 설정 적용을 누르세요.", badFrame="프레임 번호를 입력하세요.",
        badValue="값 범위: ", previewFailed="미리보기를 만들 수 없습니다. 이미지 연결을 확인하세요.",
        previewReady="미리보기를 새로 고쳤습니다.", previewEmpty="리깅을 선택하면 이미지가 여기에 표시됩니다.",
        Amplitude="흔들림 크기", Frequency="흔들림 횟수", Speed="움직임 속도",
        Direction="움직임 방향", Phase="시작 위상", Stiffness="단단함", Damping="감쇠",
        FollowDelay="끝부분 지연", Irregularity="불규칙성", RootLock="뿌리 고정",
        TipInfluence="끝 영향도", BendAmount="휘어짐 정도", Falloff="영향 폭",
    },
    en = {
        language="한국어", setup="SETUP", motion="MOTION", behavior="BEHAVIOR", region="REGION",
        presets="PRESETS", actions="ACTIONS", preview="MEDIA PREVIEW",
        intro="Select an image-producing node, then choose Create Rig.",
        pointHelp="Drag Root/Tip in Fusion Viewer.",
        motionHelp="Set sway size and direction.",
        behaviorHelp="Adjust spring and variation.",
        regionHelp="Set the fixed area and bend range.",
        previewHelp="The current frame refreshes on Apply or Refresh.",
        create="Create Rig", select="Select Rig", reset="Reset Rig",
        apply="Apply", update="Update", disable="Enable / Disable", remove="Remove",
        gentle="Gentle", wind="Wind", elastic="Elastic", floating="Floating", custom="Custom",
        original="Original", result="Result", frame="Frame", refresh="Refresh",
        noRig="Select a Node Wave rig first.", noComp="Open a Fusion composition first.",
        noSource="Select an image-producing node.", needRestart="The new Node Wave engine registers on the next Resolve launch.",
        selected="Rig selected. Drag Root and Tip in the Viewer.", created="Rig created.",
        updated="Settings applied.", disabled="Rig disabled.", enabled="Rig enabled.",
        removed="Rig removed; source reconnected.", resetDone="Default values restored.",
        already="A rig is already selected.", presetLoaded="Preset loaded. Choose Apply.",
        customHint="Edit values, then choose Apply.", badFrame="Enter a frame number.",
        badValue="Allowed range: ", previewFailed="Could not create preview. Check the image connection.",
        previewReady="Preview refreshed.", previewEmpty="Select a rig to see its image here.",
        Amplitude="Amplitude", Frequency="Frequency", Speed="Speed",
        Direction="Direction", Phase="Phase", Stiffness="Stiffness", Damping="Damping",
        FollowDelay="Follow Delay", Irregularity="Irregularity", RootLock="Root Lock",
        TipInfluence="Tip Influence", BendAmount="Bend Amount", Falloff="Falloff",
    },
}
local locale = "ko"
local rig
local previewFiles = {}
local previewSize = {Width=1920, Height=1080}
local previewMode = "result"
local previewSerial = 0
-- Resolve can run on macOS or Windows; both the image writer and HTML viewer
-- accept forward slashes, including Windows drive paths.
local function previewDirectory()
    local windows = package.config:sub(1, 1) == "\\"
    local envKeys = windows and {"TEMP", "TMP", "TMPDIR"} or {"TMPDIR", "TMP", "TEMP"}
    for _, key in ipairs(envKeys) do
        local path = os.getenv(key)
        if path and path ~= "" then
            return path:gsub("\\", "/"):gsub("/+$", "") .. "/"
        end
    end
    local localAppData = os.getenv("LOCALAPPDATA")
    if windows and localAppData and localAppData ~= "" then
        return localAppData:gsub("\\", "/"):gsub("/+$", "") .. "/Temp/"
    end
    return windows and "./" or "/tmp/"
end
local tempDir = previewDirectory()
local previewPrefix = tempDir .. "node-wave-preview-" .. os.time() .. "-" .. math.random(1000000) .. "-"
local function currentComp() return fusion:GetCurrentComp() end
local function isRig(tool)
    if not tool or not tool.GetAttrs then return false end
    if tool:GetAttrs().TOOLS_RegID == "Fuse.NodeWaveDeform" then return true end
    -- Recognize older compositions by their controls without exposing the old name in the UI.
    if not tool.GetInput or not tool.Input or not tool.Tip then return false end
    local ok1, delay = pcall(tool.GetInput, tool, "FollowDelay")
    local ok2, bend = pcall(tool.GetInput, tool, "BendAmount")
    return ok1 and ok2 and type(delay) == "number" and type(bend) == "number"
end
local function selectedRig()
    local c = currentComp()
    if not c then return nil end
    if isRig(c.ActiveTool) then rig = c.ActiveTool; return rig end
    if isRig(rig) then return rig end
    return nil
end
local function fieldRow(key, default)
    return ui:HGroup{Weight=0, Spacing=3,
        ui:Label{ID="Label_" .. key, Text=strings.ko[key], Weight=1},
        ui:LineEdit{ID=key, Text=tostring(default), Weight=0.45}}
end
local function heading(id, value) return ui:Label{ID=id, Text=value, Weight=0} end
local win = disp:AddWindow({ID="NodeWaveWindow", WindowTitle="Node Wave 2.2.2",
    Geometry={70, 70, 900, 520}, Spacing=5},
    ui:VGroup{ID="Root", Spacing=3,
        ui:HGroup{Weight=0,
            ui:Label{ID="Title", Text="Node Wave 2.2.2", Weight=1},
            ui:Button{ID="Language", Text="English", Weight=0}},
        ui:HGroup{Spacing=8,
            ui:VGroup{Weight=1, Spacing=2,
                heading("MotionHead", strings.ko.motion), heading("MotionHelp", strings.ko.motionHelp),
                fieldRow("Amplitude", 0.08), fieldRow("Frequency", 1), fieldRow("Speed", 1),
                fieldRow("Direction", 0), fieldRow("Phase", 0),
                heading("BehaviorHead", strings.ko.behavior), heading("BehaviorHelp", strings.ko.behaviorHelp),
                fieldRow("Stiffness", 0.5), fieldRow("Damping", 0.15),
                fieldRow("FollowDelay", 0.6), fieldRow("Irregularity", 0.12),
                heading("RegionHead", strings.ko.region), heading("RegionHelp", strings.ko.regionHelp),
                fieldRow("RootLock", 0.2), fieldRow("TipInfluence", 1),
                fieldRow("BendAmount", 0.7), fieldRow("Falloff", 0.25),
            },
            ui:VGroup{Weight=0.9, Spacing=3,
                heading("SetupHead", strings.ko.setup),
                ui:HGroup{Weight=0,
                    ui:Button{ID="CreateRig", Text=strings.ko.create},
                    ui:Button{ID="SelectRig", Text=strings.ko.select}},
                ui:Button{ID="ResetRig", Text=strings.ko.reset, Weight=0},
                heading("PointHelp", strings.ko.pointHelp),
                heading("PresetsHead", strings.ko.presets),
                ui:HGroup{Weight=0,
                    ui:Button{ID="Gentle", Text=strings.ko.gentle},
                    ui:Button{ID="Wind", Text=strings.ko.wind}},
                ui:HGroup{Weight=0,
                    ui:Button{ID="Elastic", Text=strings.ko.elastic},
                    ui:Button{ID="Floating", Text=strings.ko.floating}},
                ui:Button{ID="Custom", Text=strings.ko.custom, Weight=0},
                heading("ActionsHead", strings.ko.actions),
                ui:HGroup{Weight=0,
                    ui:Button{ID="Apply", Text=strings.ko.apply},
                    ui:Button{ID="Update", Text=strings.ko.update}},
                ui:HGroup{Weight=0,
                    ui:Button{ID="Disable", Text=strings.ko.disable},
                    ui:Button{ID="Remove", Text=strings.ko.remove}},
            },
            ui:VGroup{Weight=1.35, Spacing=3,
                heading("PreviewHead", strings.ko.preview),
                ui:HGroup{Weight=0,
                    ui:Button{ID="Original", Text=strings.ko.original},
                    ui:Button{ID="Result", Text=strings.ko.result}},
                ui:TextEdit{ID="Preview", ReadOnly=true, HTML=strings.ko.previewEmpty},
                ui:HGroup{Weight=0,
                    ui:Label{ID="FrameLabel", Text=strings.ko.frame, Weight=0},
                    ui:LineEdit{ID="Frame", Text="0", Weight=0.5},
                    ui:Button{ID="Refresh", Text=strings.ko.refresh}},
                heading("PreviewHelp", strings.ko.previewHelp),
            },
        },
        heading("Status", strings.ko.intro),
    })
local items = win:GetItems()
local lastStatus = "intro"
local function status(key, suffix)
    lastStatus = key
    items.Status.Text = (strings[locale][key] or key) .. (suffix or "")
end
local function clearPreview()
    for _, path in pairs(previewFiles) do os.remove(path) end
    previewFiles = {}
    items.Preview.HTML = strings[locale].previewEmpty
end
local function previewHTML(path)
    if not path then return strings[locale].previewEmpty end
    local w, h = previewSize.Width or 1920, previewSize.Height or 1080
    local scale = math.min(330 / math.max(1,w), 250 / math.max(1,h))
    w, h = math.max(1, math.floor(w*scale)), math.max(1, math.floor(h*scale))
    local normalized = path:gsub("\\", "/")
    -- file:///C:/... is required for drive paths; file://server/... for UNC.
    if normalized:match("^%a:/") then normalized = "/" .. normalized end
    local url = "file://" .. normalized:gsub("[^%w%-%._~/:%-]", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
    return '<html><body style="background-color:#242428;text-align:center;">' ..
        '<img src="' .. url .. '" width="' .. w .. '" height="' .. h .. '"></body></html>'
end
local function showPreview()
    items.Preview.HTML = previewHTML(previewFiles[previewMode])
end
local function refreshPreview(quiet)
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return false end
    local frame = tonumber(items.Frame.Text)
    if not frame then status("badFrame"); return false end
    frame = math.floor(frame)
    items.Frame.Text = tostring(frame)
    local upstream = tool.Input and tool.Input:GetConnectedOutput()
    if not upstream or not tool.Output then status("previewFailed"); return false end
    previewSerial = previewSerial + 1
    local newFiles = {
        original = previewPrefix .. previewSerial .. "-original.png",
        result = previewPrefix .. previewSerial .. "-result.png",
    }
    local ok = pcall(function()
        local sourceImage = upstream:GetValue(frame)
        local resultImage = tool.Output:GetValue(frame)
        assert(sourceImage and resultImage)
        previewSize = {Width=resultImage.Width, Height=resultImage.Height}
        assert(sourceImage:Save(newFiles.original))
        assert(resultImage:Save(newFiles.result))
    end)
    if not ok then
        os.remove(newFiles.original); os.remove(newFiles.result)
        status("previewFailed")
        return false
    end
    local oldFiles = previewFiles
    previewFiles = newFiles
    showPreview()
    for _, path in pairs(oldFiles) do os.remove(path) end
    if not quiet then status("previewReady") end
    return true
end
local function loadRig()
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return end
    for _, f in ipairs(fields) do
        local value = tool:GetInput(f[1], c.CurrentTime)
        if type(value) == "number" then items[f[1]].Text = string.format("%.4g", value) end
    end
    items.Frame.Text = tostring(math.floor(c.CurrentTime))
    status("selected")
    refreshPreview(true)
end
-- Referencing time in a control keeps static-image rigs animated in Resolve
-- sessions that loaded an older Fuse registration before the time-variant flag.
local function setPhase(tool, value)
    local input = tool.Phase
    if input and input.SetExpression then
        input:SetExpression(string.format("%.12g + time * 0", value))
    else
        tool.Phase = value
    end
end
local function applyValues()
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return end
    local parsed = {}
    for _, f in ipairs(fields) do
        local n = tonumber(items[f[1]].Text)
        if not n or n < f[3] or n > f[4] then
            status("badValue", strings[locale][f[1]] .. " " .. f[3] .. "–" .. f[4])
            return
        end
        parsed[f[1]] = n
    end
    c:StartUndo("Node Wave Update")
    for _, f in ipairs(fields) do
        if f[1] ~= "Phase" then tool[f[1]] = parsed[f[1]] end
    end
    setPhase(tool, parsed.Phase)
    tool.Enabled = 1
    c:EndUndo(true)
    status("updated")
    refreshPreview(true)
end
local function updateLanguage()
    local t = strings[locale]
    items.Language.Text = t.language
    for _, pair in ipairs({
        {"MotionHead","motion"},{"MotionHelp","motionHelp"},
        {"BehaviorHead","behavior"},{"BehaviorHelp","behaviorHelp"},
        {"RegionHead","region"},{"RegionHelp","regionHelp"},
        {"SetupHead","setup"},{"PointHelp","pointHelp"},
        {"PresetsHead","presets"},{"ActionsHead","actions"},
        {"PreviewHead","preview"},{"PreviewHelp","previewHelp"},
        {"CreateRig","create"},{"SelectRig","select"},{"ResetRig","reset"},
        {"Apply","apply"},{"Update","update"},{"Disable","disable"},{"Remove","remove"},
        {"Gentle","gentle"},{"Wind","wind"},{"Elastic","elastic"},
        {"Floating","floating"},{"Custom","custom"},
        {"Original","original"},{"Result","result"},{"FrameLabel","frame"},{"Refresh","refresh"},
    }) do items[pair[1]].Text = t[pair[2]] end
    for _, f in ipairs(fields) do items["Label_" .. f[1]].Text = t[f[1]] end
    status(lastStatus)
    showPreview()
end
function win.On.NodeWaveWindow.Close() clearPreview(); disp:ExitLoop() end
function win.On.Language.Clicked()
    locale = locale == "ko" and "en" or "ko"
    updateLanguage()
end
function win.On.CreateRig.Clicked()
    local c = currentComp()
    if not c then status("noComp"); return end
    if isRig(c.ActiveTool) then status("already"); return end
    if not c.ActiveTool then status("noSource"); return end
    c:StartUndo("Node Wave Create")
    local newRig = c:AddToolAction("Fuse.NodeWaveDeform")
    if not newRig then c:EndUndo(false); status("needRestart"); return end
    rig = newRig
    c:EndUndo(true)
    applyValues()
    status("created")
end
function win.On.SelectRig.Clicked() loadRig() end
function win.On.ResetRig.Clicked()
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return end
    c:StartUndo("Node Wave Reset")
    for _, f in ipairs(fields) do
        if f[1] ~= "Phase" then tool[f[1]] = f[2] end
        items[f[1]].Text = tostring(f[2])
    end
    setPhase(tool, 0)
    tool.Root = Point(0.5, 0.2)
    tool.Tip = Point(0.5, 0.8)
    tool.Enabled = 1
    c:EndUndo(true)
    status("resetDone")
    refreshPreview(true)
end
function win.On.Apply.Clicked() applyValues() end
function win.On.Update.Clicked() applyValues() end
function win.On.Disable.Clicked()
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return end
    local enabled = tool:GetInput("Enabled", c.CurrentTime)
    c:StartUndo("Node Wave Toggle")
    tool.Enabled = enabled and enabled > 0.5 and 0 or 1
    c:EndUndo(true)
    status(tool:GetInput("Enabled", c.CurrentTime) > 0.5 and "enabled" or "disabled")
    refreshPreview(true)
end
function win.On.Remove.Clicked()
    local tool, c = selectedRig(), currentComp()
    if not tool or not c then status("noRig"); return end
    c:StartUndo("Node Wave Remove")
    local upstream = tool.Input:GetConnectedOutput()
    local downstream = tool.Output:GetConnectedInputs() or {}
    for _, input in pairs(downstream) do input:ConnectTo(upstream) end
    tool:Delete()
    c:EndUndo(true)
    rig = nil
    clearPreview()
    status("removed")
end
function win.On.Original.Clicked() previewMode="original"; showPreview() end
function win.On.Result.Clicked() previewMode="result"; showPreview() end
function win.On.Refresh.Clicked() refreshPreview() end
function win.On.Custom.Clicked() status("customHint") end
for name, values in pairs(presets) do
    win.On[name].Clicked = function()
        for key, value in pairs(values) do items[key].Text = tostring(value) end
        status("presetLoaded")
    end
end
win:Show()
if selectedRig() then loadRig() end
-- Script window stays responsive; preview renders only on explicit actions.
disp:RunLoop()
clearPreview()
win:Hide()
