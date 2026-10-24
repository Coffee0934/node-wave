-- Minimal UIManager and Composition doubles for the script-first workflow.
local ui = setmetatable({}, {__index=function(_, kind)
    return function(_, attrs) attrs.kind=kind; return attrs end
end})
local items = {}
local function visit(value)
    if type(value) ~= "table" then return end
    if value.ID then items[value.ID]=value end
    for _, child in pairs(value) do if type(child)=="table" then visit(child) end end
end
local disp = {}
function disp:AddWindow(spec, body)
    visit(spec); visit(body)
    local on = setmetatable({}, {__index=function(t,k)
        local v={}; rawset(t,k,v); return v
    end})
    local win={On=on}
    function win:GetItems() return items end
    function win:Show() end
    function win:Hide() end
    _G.mockwin=win
    return win
end
function disp:RunLoop() end
function disp:ExitLoop() end
bmd = {UIDispatcher=function() return disp end}
local saves=0
local savedPaths={}
local image={Width=1920,Height=1080}
function image:Save(path)
    saves=saves+1
    savedPaths[#savedPaths+1]=path
    return path:match("%.png$")~=nil
end
local sourceOutput={GetValue=function() return image end}
local source={Output=sourceOutput, GetAttrs=function() return {TOOLS_RegID="Loader"} end}
local comp={ActiveTool=source, CurrentTime=25}
function comp:StartUndo() end
function comp:EndUndo() end
function comp:AddToolAction(id)
    assert(id=="Fuse.NodeWaveDeform")
    local rig={Enabled=1, PointCount=2,
        Root={X=0.5,Y=0.2}, Tip={X=0.5,Y=0.8}}
    rig.Phase={SetExpression=function(_, expression)
        rig.phaseExpression=expression
        rig.phaseValue=tonumber(expression:match("^([%+%-]?[%d%.]+)"))
    end}
    function rig:GetAttrs() return {TOOLS_RegID="Fuse.NodeWaveDeform"} end
    function rig:GetInput(key) if key=="Phase" then return self.phaseValue end; return self[key] end
    function rig:Delete() self.deleted=true end
    rig.Input={GetConnectedOutput=function() return sourceOutput end}
    rig.Output={GetValue=function() return image end, GetConnectedInputs=function() return {} end}
    self.ActiveTool=rig
    _G.mockrig=rig
    return rig
end
fu={UIManager=ui, GetCurrentComp=function() return comp end}
function Point(x,y) return {X=x,Y=y} end
-- Check the preview path with both macOS and Windows-style environments.
local path, platform=...
assert(platform=="macOS" or platform=="Windows")
local realGetenv, realPackageConfig=os.getenv, package.config
if platform=="Windows" then package.config="\\" .. realPackageConfig:sub(2) end
os.getenv=function(key)
    if platform=="Windows" then
        if key=="TEMP" then return [[C:\Users\Test User\Temp#1]] end
        if key=="TMPDIR" or key=="TMP" then return nil end
    else
        if key=="TMPDIR" then return "/private/tmp/Node Wave#1/" end
        if key=="TEMP" or key=="TMP" then return nil end
    end
    return realGetenv(key)
end
dofile(path)
os.getenv, package.config=realGetenv, realPackageConfig
assert(items.Language.Text=="English")
mockwin.On.CreateRig.Clicked()
assert(mockrig and mockrig.Amplitude==0.08 and mockrig.Enabled==1)
assert(mockrig.phaseExpression and mockrig.phaseExpression:find("time",1,true))
assert(items.PointCountLabel.Text:find("2/6",1,true))
mockwin.On.AddPoint.Clicked()
assert(mockrig.PointCount==3 and mockrig.Joint1.X==0.5 and mockrig.Joint1.Y==0.5)
assert(items.PointCountLabel.Text:find("3/6",1,true))
mockrig.Joint1=Point(0.6,0.5)
mockwin.On.AddPoint.Clicked()
assert(mockrig.PointCount==4 and math.abs(mockrig.Joint2.X-0.55)<1e-12)
mockwin.On.RemovePoint.Clicked()
assert(mockrig.PointCount==3 and items.PointCountLabel.Text:find("3/6",1,true))
for _=1,3 do mockwin.On.AddPoint.Clicked() end
assert(mockrig.PointCount==6 and items.PointCountLabel.Text:find("6/6",1,true))
mockwin.On.AddPoint.Clicked()
assert(mockrig.PointCount==6, "joint limit must be enforced")
for _=1,4 do mockwin.On.RemovePoint.Clicked() end
assert(mockrig.PointCount==2)
mockwin.On.RemovePoint.Clicked()
assert(mockrig.PointCount==2, "Root and Tip must remain")
assert(saves>=2 and items.Preview.HTML:find("<img",1,true))
if platform=="Windows" then
    assert(savedPaths[1]:find("C:/Users/Test User/Temp#1/node-wave-preview-",1,true))
    assert(items.Preview.HTML:find("file:///C:/Users/Test%20User/Temp%231/node-wave-preview-",1,true))
else
    assert(savedPaths[1]:find("/private/tmp/Node Wave#1/node-wave-preview-",1,true))
    assert(items.Preview.HTML:find("file:///private/tmp/Node%20Wave%231/node-wave-preview-",1,true))
end
mockwin.On.Language.Clicked()
assert(items.Language.Text=="한국어" and items.Label_Amplitude.Text=="Amplitude")
mockwin.On.Language.Clicked()
assert(items.Label_Amplitude.Text=="흔들림 크기")
mockwin.On.Wind.Clicked()
mockwin.On.Apply.Clicked()
assert(mockrig.Amplitude==0.16 and mockrig.Irregularity==0.4)
mockwin.On.Original.Clicked()
assert(items.Preview.HTML:find("original.png",1,true))
mockwin.On.Result.Clicked()
assert(items.Preview.HTML:find("result.png",1,true))
items.Frame.Text="42"
mockwin.On.Refresh.Clicked()
assert(items.Frame.Text=="42")
mockwin.On.Disable.Clicked()
assert(mockrig.Enabled==0)
mockwin.On.ResetRig.Clicked()
assert(mockrig.Amplitude==0.08 and mockrig.Enabled==1 and mockrig.phaseValue==0)
assert(mockrig.PointCount==2 and items.PointCountLabel.Text:find("2/6",1,true))
mockwin.On.Remove.Clicked()
assert(mockrig.deleted and items.Preview.HTML:find("리깅을 선택",1,true))
print("controller_mock (" .. platform .. "): all checks passed")
