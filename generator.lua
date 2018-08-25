#!/usr/bin/lua
local xml={}
xml.head=[[
<MixxxControllerPreset mixxxVersion="1.10.1+" schemaVersion="1">
    <info>
        <name>Hercules Universal DJ</name>
        <author>Ard van Breemenr</author>
    </info>
    <controller id="Hercules Universel DJ">
        <scriptfiles>
            <file functionprefix="HCUniversalDJ" filename="DJHERCULESMIX-Universal-DJ-scripts.js"/>
        </scriptfiles>
]]
xml.controls={}
xml.outputs={}
xml.tail=[[
    </controller>
</MixxxControllerPreset>
]]

local function C(desc,group,status,midino,key,options)
	local txml=[[
	<control>
		<group>@_GROUP_@</group>
		<key>@_KEY_@</key>
		<description>@_DESCRIPTION_@</description>
		<status>@_STATUS_@</status>
		<midino>@_MIDINO_@</midino>
		<options>@_OPTIONS_@
		</options>
	</control>
]]
	local control=xml.controls
	local repl={ }
	repl.DESCRIPTION=desc
	repl.STATUS=status
	repl.GROUP=group
	--repl.MIDINO=midino
	repl.MIDINO=string.format("0x%02x",midino)
	repl.KEY=key
	if options ~= nil then
		options="\n\t\t\t"..options
	else
		options=''
	end
	repl.OPTIONS=options
	control[#control+1]=txml:gsub("@_([A-Z]+)_@",repl)
end

local function DC(desc,midino_a,midino_b,key,...)
	C(desc.."_DA","[Channel1]","0xB0",midino_a,key,...)
	C(desc.."_DB","[Channel2]","0xB0",midino_b,key,...)
end

local function DB(desc,midino,key,...)
	C(desc.."_DA","[Channel1]","0x90",midino,key,...)
	C(desc.."_DB","[Channel2]","0x91",midino,key,...)
end

local function DO(desc,midino,key)
	local txml=[[
	<output>
		<status>@_STATUS_@</status>
		<midino>@_MIDINO_@</midino>
		<group>@_GROUP_@</group>
		<key>@_KEY_@</key>
		<description>@_DESCRIPTION_@</description>
		<options>
		</options>
		<minimum>0.5</minimum>
		<maximum>1</maximum>
		<on>0x7f</on>
		<off>0x0</off>
	</output>
]]
	local repl={ }
	local control=xml.outputs
	repl.KEY=key
	repl.MIDINO=midino
	repl.DESCRIPTION=desc.."_DA" repl.GROUP="[Channel1]" repl.STATUS="0x90"
	control[#control+1]=txml:gsub("@_([A-Z]+)_@",repl)
	repl.DESCRIPTION=desc.."_DB" repl.GROUP="[Channel2]" repl.STATUS="0x91"
	control[#control+1]=txml:gsub("@_([A-Z]+)_@",repl)
end
local function D(...)
	DB(...)
	DO(...)
end

local function dumpxml()
	io.write(xml.head)
	io.write[[
	<controls>
]]
	for _,v in ipairs(xml.controls) do
		io.write(v)
	end
	io.write[[
	</controls>
	<outputs>
]]
	for _,v in ipairs(xml.outputs) do
		io.write(v)
	end
	io.write[[
	</outputs>
]]
	io.write(xml.tail)
end

D("PFL",83,"pfl")
DB("PLAY",65,"play")
DO("PLAY",65,"play_indicator")
D("SYNC",67,"beatsync")
DB("CUE",66,"cue_default")
DB("LOAD",81,"LoadSelectedTrack")
C("BROWSE","[Library]","0xB0",54,"MoveVertical","<SelectKnob/>")
C("BROWSE","[Library]","0x90",92,"MoveFocus")
DO("CUE",66,"cue_indicator")
C("XFADER","[Master]","0xB0",65,"crossfader")
DC("TREBLE",59,62,"filterHigh")
DC("MEDIUM",60,63,"filterMid")
DC("BASS",61,64,"filterLow")
DC("VOL",57,58,"volume")
DC("PITCH",1,2,"rate")
DC("JOG_Scratch",50,51,"HCUniversalDJ.wheelScratch","<Script-Binding/>")
DB("JOG_Touch",82,"HCUniversalDJ.wheelTouch","<Script-Binding/>")
DB("CUE_MODE",65,"HCUniversalDJ.setMode","<Script-Binding/>")
DB("FX_MODE",66,"HCUniversalDJ.setMode","<Script-Binding/>")
DB("SAM_MODE",67,"HCUniversalDJ.setMode","<Script-Binding/>")
DB("LOOP_MODE",68,"HCUniversalDJ.setMode","<Script-Binding/>")

-- Beat loop
function BL(n,shift,X)
	if shift ~= 0 then
		DB("SH_LOOP_KP"..n,56+n,"beatloop_"..X.."_toggle")
		DO("SH_LOOP_KP"..n,56+n,"beatloop_"..X.."_enabled")
	else
		DB("LOOP_KP"..n,48+n,"beatloop_"..X.."_toggle")
		DO("LOOP_KP"..n,48+n,"beatloop_"..X.."_enabled")
	end
end
BL(1,0,0.125)
BL(2,0,0.25)
BL(3,0,0.5)
BL(4,0,1)
BL(5,0,2)
BL(6,0,4)
BL(7,0,8)
BL(8,0,16)

dumpxml()
