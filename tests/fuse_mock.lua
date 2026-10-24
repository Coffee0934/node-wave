-- A tiny Fusion API double for deterministic image tests; no Resolve installation needed.
CT_Tool = 1
local registeredAttrs
function FuRegisterClass(_, _, attrs) registeredAttrs = attrs end
self = {}
function self:AddInput(_, id, attrs)
    local input = {value = attrs.INP_Default, attrs = attrs}
    if attrs.LINKID_DataType == "Point" then
        input.value = {X=attrs.INP_DefaultX, Y=attrs.INP_DefaultY}
    end
    function input:SetAttrs(values)
        for key, value in pairs(values) do self.attrs[key] = value end
    end
    function input:GetValue()
        if id == "Input" then return self.value end
        if type(self.value) == "table" then return self.value end
        return {Value=self.value}
    end
    return input
end
function self:AddOutput()
    local output = {}
    function output:Set(_, value) self.value = value end
    return output
end
function Pixel() return {R=0,G=0,B=0,A=0} end
local function image(w,h)
    local img = {Width=w, Height=h, pixels={}}
    for y=0,h-1 do
        local row = {}
        for x=0,w-1 do
            row[x] = {R=x/(w-1), G=y/(h-1), B=0.2, A=(x>=4 and x<=27) and 1 or 0}
        end
        img.pixels[y] = row
    end
    function img:Copy()
        local out = image(self.Width,self.Height)
        for yy=0,self.Height-1 do for xx=0,self.Width-1 do
            local p=self.pixels[yy][xx]
            out.pixels[yy][xx]={R=p.R,G=p.G,B=p.B,A=p.A}
        end end
        return out
    end
    function img:SetPixel(x,y,p)
        self.pixels[y][x]={R=p.R,G=p.G,B=p.B,A=p.A}
    end
    function img:SamplePixelB(x,y,p)
        local function at(xx,yy)
            if xx<0 or yy<0 or xx>=w or yy>=h then return {R=0,G=0,B=0,A=0} end
            return self.pixels[yy][xx]
        end
        local x0,y0=math.floor(x),math.floor(y)
        local fx,fy=x-x0,y-y0
        local a,b,c,d=at(x0,y0),at(x0+1,y0),at(x0,y0+1),at(x0+1,y0+1)
        for _,k in ipairs({"R","G","B","A"}) do
            p[k]=(a[k]*(1-fx)+b[k]*fx)*(1-fy)+(c[k]*(1-fx)+d[k]*fx)*fy
        end
    end
    return img
end
local path = ...
dofile(path)
assert(registeredAttrs and registeredAttrs.REG_TimeVariant == true, "Fuse must render each requested frame")
Create()
local source=image(32,32)
InImage.value=source
InRoot.value={X=0.5,Y=0.1}
InTip.value={X=0.5,Y=0.9}
InAmplitude.value=0.25
InFrequency.value=0
InPhase.value=90
InDamping.value=0
InStiffness.value=0
InBendAmount.value=0
InRootLock.value=0
InFalloff.value=0.8
local req={Time=0}
function req:IsPreCalc() return false end
Process(req)
local first=OutImage.value
assert(first ~= source, "sway must render a new image")
assert(first.pixels[3][16].R == source.pixels[3][16].R, "root must stay locked")
assert(math.abs(first.pixels[26][16].R-source.pixels[26][16].R)>0.01, "tip must bend")
assert(first.pixels[26][16].A == 1, "opaque alpha must survive warp")
Process(req)
assert(math.abs(first.pixels[26][16].R-OutImage.value.pixels[26][16].R)<1e-12, "same frame must match")
InFrequency.value=1
req.Time=0
Process(req)
local atZero=OutImage.value.pixels[26][16].R
req.Time=25
Process(req)
local atTwentyFive=OutImage.value.pixels[26][16].R
assert(math.abs(atZero-atTwentyFive)>0.01, "motion must change with frame")
req.Time=0
Process(req)
assert(math.abs(atZero-OutImage.value.pixels[26][16].R)<1e-12, "scrubbing back must reproduce frame")

-- Joint-chain mode uses viewer points without a mesh. Moving a joint must
-- change the shape, while frame requests remain deterministic.
InPointCount.value=4
NotifyChanged(InPointCount, {Value=4}, 0)
assert(InJoints[1].attrs.IC_Visible and InJoints[2].attrs.IC_Visible)
assert(not InJoints[3].attrs.IC_Visible and not InJoints[4].attrs.IC_Visible)
InJoints[1].value={X=0.5,Y=0.35}
InJoints[2].value={X=0.5,Y=0.65}
InAmplitude.value=0.2
InFalloff.value=0.35
InPhase.value=90
req.Time=0
Process(req)
local straight=OutImage.value
InJoints[1].value={X=0.25,Y=0.35}
InJoints[2].value={X=0.75,Y=0.65}
Process(req)
local bent=OutImage.value
local function imageDifference(a,b)
    local total=0
    for y=0,a.Height-1 do for x=0,a.Width-1 do
        local pa,pb=a.pixels[y][x],b.pixels[y][x]
        total=total+math.abs(pa.R-pb.R)+math.abs(pa.G-pb.G)+math.abs(pa.A-pb.A)
    end end
    return total
end
assert(imageDifference(straight,bent)>1, "joint placement must alter the deformation")
assert(bent.pixels[3][16].R==source.pixels[3][16].R, "joint chain must keep root fixed")
req.Time=25
Process(req)
local bentLater=OutImage.value
assert(imageDifference(bent,bentLater)>1, "joint chain must animate over time")
req.Time=0
Process(req)
assert(imageDifference(bent,OutImage.value)<1e-10, "joint chain must reproduce a frame")
NotifyChanged(InPointCount, {Value=2}, 0)
assert(not InJoints[1].attrs.IC_Visible and not InJoints[2].attrs.IC_Visible)
InPointCount.value=6
InJoints[1].value={X=0.5,Y=0.1} -- Coincident with Root: skipped safely.
InJoints[2].value={X=0.3,Y=0.35}
InJoints[3].value={X=0.7,Y=0.55}
InJoints[4].value={X=0.5,Y=0.75}
req.Time=12
Process(req)
assert(OutImage.value ~= source, "six-point chain must render")
InPointCount.value=2
InEnabled.value=0
Process(req)
assert(OutImage.value == source, "disabled rig must bypass")
InEnabled.value=1
InAmplitude.value=0
Process(req)
assert(OutImage.value == source, "zero amplitude must bypass")
print("fuse_mock: all checks passed")
