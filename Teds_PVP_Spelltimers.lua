--Teds_PVP_Spelltimers.lua by Zendil-The Underbog (US)
--Define locals
local f = Teds_PVP_Spelltimers_Frame
local m = Teds_PVP_Spelltimers_DragFrame
local c = Teds_PVP_Spelltimers_Config_Frame
local w = {}
local s
--Set frame as user placed (this might be default? unsure)
f:SetUserPlaced(true)
m:SetUserPlaced(true)
--Define variables
w.activealerts = {}
--Create list of all defensive cooldowns that alerts will be created for
	--To add a spell, insert a new entry with the buff's spellid as the key and the name (or whatever text should be displayed) as the values
	--To remove a spell just delete or comment out it's line
	--Note when adding your own spells that the mechanism by which spells are tracked is as -BUFFS- on your -TARGET-
		--i.e. if you wanted to track "Marked for Death", it would not work as this creates a -DEBUFF- on the -PLAYER-
w.filter_def = {
	--Demon Hunter
		--All Specs
		[188501] = "Spectral Sight",
		--Havoc
		[212800] = "Blur",
		[209426] = "Darkness",
		[196555] = "Netherwalk",
		--Vengeance
		[203819] = "Demon Spikes",
		[263648] = "Soul Barrier",
		[205629] = "Demonic Trample",
	--Death Knight
		--All specs
		[48792] = "Icebound Fortitude",
		[48707] = "Anti-Magic Shell",
		[212552] = "Wraith Walk",
		[48265] = "Death's Advance",
		[145629] = "Anti-Magic Zone",
		--Blood
		[55233] = "Vampiric Blood",
		[81256] = "Dancing Rune Weapon",
		[194679] = "Rune Tap",
		--Frost
			--No spells
		--Unholy
			--No spells
	--Druid
		--All specs
		[1850] = "Dash",
		[22812] = "Barkskin",
		[236696] = "Thorns",
		[252216] = "Tiger Dash",
		--Balance
			--No spells
		--Restoration
		[102342] = "Ironbark",
		[117679] = "Incarnation: Tree of Life",
		--Feral/Guardian
		[61336] = "Survival Instincts",
		[77764] = "Stampeding Roar",
		[102558] = "Incarnation: Guardian of Ursoc",
	--Hunter
		--All Specs
			[109215] = "Posthaste",
			[186257] = "Aspect of the Cheetah",
			[186258] = "Aspect of the Cheetah",--follow up buff
			[203233] = "Aspect of the Cheetah",--hunting party honor talent
			[186265] = "Aspect of the Turtle",
			[53480] = "Roar of Sacrifice",--check
			[54216] = "Master's Call",--check
		--Marksmanship
			--No spells
		--Beast Mastery
			[212668] = "The Beast Within",--check
			[248518] = "Interlope",--check
		--Survival
			--No spells
	--Mage
		--All specs
		[198111] = "Temporal Shield",
		[45438] = "Ice Block",
		[198065] = "Prismatic Cloak",
		--Arcane
		[113862] = "Greater Invisibility",--after invisible
		[110960] = "Greater Invisibility",--while invisible
		[198158] = "Mass Invisibility",
		--Fire
		[87023] = "Cauterize",
		--Frost
			--No spells
	--Monk
		--All specs
			[116841] = "Tiger's Lust",
			[201318] = "Fortifying Brew",
			[122278] = "Dampen Harm",
		--Not Brewmaster
			[122783] = "Diffuse Magic",
		--Mistweaver
			[216113] = "Way of the Crane",
			[209584] = "Zen Focus Tea",
			[116849] = "Life Cocoon",
		--Windwalker
			[125174] = "Touch of Karma",
		--Brewmaster
			[120954] = "Fortifying Brew",
			[215479] = "Ironskin Brew",
			[115176] = "Zen Meditation",
			[202248] = "Guided Meditation",
			[213664] = "Nimble Brew",
	--Paladin
		--All Specs
			[1022] = "Blessing of Protection",
			[1044] = "Blessing of Freedom",
			[642] = "Divine Shield",
			[221886] = "Divine Steed",--working on blood elf, could be racial (further testing needed)
		--Holy
			[31821] = "Aura Mastery",--need to check for buffs on party members
			[31884] = "Avenging Wrath",--works for all specs but important for holy
			[498] = "Divine Protection",
			[105809] = "Holy Avenger",
			[199448] = "Blessing of Sacrifice",--Holy
		--Protection
			[86659] = "Guardian of Ancient Kings",
			[228050] = "Divine Shield",--from Guardian of the Forgotten Queen
			[204018] = "Blessing of Spellwarding",
			[31850] = "Ardent Defender",
			[204335] = "Aegis of Light",--Buff, source is different id
			[6940] = "Blessing of Sacrifice",--Prot
		--Retribution
			[184662] = "Shield of Vengeance",
			[205191] = "Eye for an Eye",
			[210256] = "Blessing of Sanctuary",
	--Priest
		--All Specs
			--[121557] = "Angelic Feather",--exclude, spammable
			--[65081] = "Body and Soul",--exclude, spammable
		--Discipline
			[33206] = "Pain Suppression",
			[81782] = "Power Word: Barrier",
			[47536] = "Rapture",
			[271466] = "Luminous Barrier",
		--Holy
			[200183] = "Apotheosis",
			[213610] = "Holy Ward",
			[47788] = "Guardian Spirit",
			[196773] = "Inner Focus",
			[213602] = "Greater Fade",
			[215769] = "Spirit of Redemption",
			[232707] = "Ray of Hope",
		--Shadow
			[47585] = "Dispersion",
			[15286] = "Vampiric Embrace",
	--Rogue
		--All Specs
			[5277] = "Evasion",--Not outlaw
			[31224] = "Cloak of Shadows",
			[31230] = "Cheat Death",
			[2983] = "Sprint",
		--Subtlety
			--[212182] = "Smoke Bomb",--debuff, doesn't work
		--Outlaw
			[199754] = "Riposte",
	--Shaman
		--All Specs
			[108271] = "Astral Shift",--Not enhancement
			--[204331] = "Counterstrike Totem",--counterstrike gives no buff, cannot be detected
			[8178] = "Grounding Totem",
			[192082] = "Wind Rush Totem",
			--[8143] = "Tremor Totem",--tremor gives no buff, cannot be detected
		--Elemental
			[108281] = "Ancestral Guidance",
		--Enhancement
			[210918] = "Ethereal Form",
			[58875] = "Spirit Walk",
		--Restoration
			[114052] = "Ascendance", --Restoration only
			[98007] = "Spirit Link Totem",--id not working; no duration
			[207498] = "Ancestral Protection Totem",
			--[108280] = "Healing Tide",--healing tide gives no buff, cannot be detected
			[79206] = "Spiritwalker's Grace",
			[201633] = "Earthen Wall Totem",
	--Warlock
		--All Specs
		[104773] = "Unending Resolve",
		[108416] = "Dark Pact",
		[212295] = "Nether Ward",
		[221705] = "Casting Circle",
	--Warrior
		--All Specs
			[97463] = "Rallying Cry",
			[18499] = "Berserker Rage",
		--DPS Specs
			[216890] = "Spell Reflection",--DPS
		--Arms
			[227847] = "Bladestorm", --Added because you are immune to cc
			[118038] = "Die by the Sword",
		--Fury
			[46924] = "Bladestorm", --separate fury version
			[184364] = "Enraged Regeneration",
		--Prot
			[23920] = "Spell Reflection",--Prot
			[12975] = "Last Stand",
			[871] = "Shield Wall",
			[213915] = "Spell Reflection", --Mass Spell Reflection
			[223658] = "Safeguard",
			[199038] = "Leave No Man Behind",--not checked
	}
--TODO: Offensive abilities, and give option to pick which filters are applied
--Define Handlers
function f:Event(event, ...)
	--switch by what event has occurred
	if event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
		f:Scan(event, ...)
	elseif event == "ADDON_LOADED" then
		f:Loaded(event, ...)
	end
end
function f:Scan(event, ...)
	--first, fetch all buffs on target
	local unit
	if event == "UNIT_AURA" then
		unit = ...
	else
		unit = "target"
	end
	if unit == "target" then --TODO: (maybe?) only update/active/show for hostile targets, not friendlies
		--this event affects our target, so we want to update now
		--clear out cached values for replacement with fresh ones
		w.targetbuffs = {}
		w.targetstealable = {}
		--store the old values to check when theres new ones
		w.activealerts_old = w.activealerts --creates a reference, not a copy. but it works?
		w.activealerts = {}
		--check all buffs
		for i=1,40 do
			local name,_,_,_,_,expire,_,steal,_,id = UnitAura("target",i,"HELPFUL")
			if id then
				--if buff exists (id is within bounds) then cache it
				w.targetbuffs[i] = {["id"] = id,["expire"] = expire}
				if steal == 1 then
					--buff is stealable so store that too
					w.targetstealable[i] = name
					--this will be used in the future (future version)
				end
			end
		end
		--now, filter for the ones we want
		if w.targetbuffs then
			--if we have buffs on target
			for _,v in pairs(w.targetbuffs) do
				--iterate through the target's cached buffs
				if w.filter_def[v.id] and (v.expire - GetTime()) > 0 then
					--buff is in filter and has non-negative duration -> create alert
					w.activealerts[v.id] = {["name"] = w.filter_def[v.id],["expire"] = v.expire}
				end
				if w.filter_def[v.id] and v.expire == 0 then
					--buff is in filter but has no/permanent duration -> create alert
					w.activealerts[v.id] = {["name"] = w.filter_def[v.id],["expire"] = v.expire}
				end
			end
		end
		--now, check if we had any that matched filter
		if next(w.activealerts) ~= nil then
			--we did match some filters. show the frame (which will start updates)
			if not f:IsShown() then
				f:Show()
			end
		else
			--no alerts to show. hide the frame (which stops updates)
			if f:IsShown() then
				f:Hide()
			end
		end
		for m,_ in pairs(w.activealerts) do
			--we have to iterate to check for new entries
			if not w.activealerts_old[m] then
				--we have new alerts. play sound
				PlaySoundFile("Interface\\Addons\\Teds_PVP_Spelltimers\\media\\BoxingArenaSound.ogg","Master")
			end
		end
	end
end
function f:Update()
	--reset the output text
	w.output = ""
	local duration
	for _,t in pairs(w.activealerts) do
		--iterate through active alerts, adding each to the output text
		if w.output ~= "" then
			w.output = w.output.."\n"
		end
		duration = t.expire - GetTime()
		if duration < 0 then
			duration = 0
		end
		w.output = w.output..string.format("%.1f%s%.1f",duration," - "..t.name.." - ",duration)
	end
	--set the text once we have build the complete string
	f.fontstring:SetText(w.output)
end
function f:Loaded(event, addon)
	--make sure its our addon that loaded
	if addon == "Teds_PvP_Spelltimers" or addon == "Teds_PvP_Spelltimers_Testing" then
		--set local s to the savedvariable
		s = Teds_PVP_Spelltimers_Save
		--check if the frame is in the right spot
		if s.savedpos then
			if f:GetCenter() ~= s.savedpos then
				--its in the wrong spot, so move it
				f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", s.savedpos)
			end
		end
	end
end
function m:Center()
	--get current y position
	local _,y = m:GetCenter()
	--reset and move to center, maintaining y position
	m:ClearAllPoints()
	m:SetPoint("CENTER", UIParent, "BOTTOM", 0, y)
end
function m:Reset()
	--reset and move to default position
	m:ClearAllPoints()
	m:SetPoint("TOP", UIParent, "TOP", 0, -50)
end
function m:Done()
	f:Mover()
end
function f:Mover()
	--check if were already moving
	if not m:IsShown() then
	--we are not moving yet
		--Unregister events so we don't activate while moving
		f:UnregisterEvent("UNIT_AURA")
		f:UnregisterEvent("PLAYER_TARGET_CHANGED")
		--get position to set the mover
		local x,y = f:GetCenter()
		--hide frame
		f:Hide()
		--put the mover in the right spot
		m:ClearAllPoints()
		m:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
		--show the mover
		m:Show()
		--if this is the mover's first load then we also have to set it up
		if not m.loaded then
			--ok, now we're loaded
			m.loaded = true
			--set up dragging
			m:RegisterForDrag("LeftButton")
			m:SetScript("OnDragStart", m.StartMoving)
			m:SetScript("OnDragStop", m.StopMovingOrSizing)
			--set up buttons and handlers
			m.centerbutton:RegisterForClicks("AnyDown")
			m.centerbutton:SetScript("OnClick", m.Center)
			m.resetbutton:RegisterForClicks("AnyDown")
			m.resetbutton:SetScript("OnClick", m.Reset)
			m.donebutton:RegisterForClicks("AnyDown")
			m.donebutton:SetScript("OnClick", m.Done)
		end
	else
	--we are already moving
		--get the mover's position
		local x,y = m:GetCenter()
		--hide the mover
		m:Hide()
		--reset the frame
		f:ClearAllPoints()
		--move the frame to the new spot
		f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
		--reregister events
		f:RegisterEvent("UNIT_AURA")
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		--save the position in case it isnt saved by blizzard
		s.savedpos = f:GetCenter()
	end
end
--testing assignment
T = f
--Assign Handlers
f:SetScript("OnEvent", f.Event)
f:SetScript("OnUpdate", f.Update)
--Register events
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("ADDON_LOADED")
--Define Slash Command Functions
local slash = {}
function slash:move(arg)
	f:Mover()
end
function slash:help(arg)
	print("TPST>Available commands are: /tpst move, /tpst help")
end
--Register Slash Commands
SLASH_TEDSPVPSPELLTIMERS1 = "/tpst"
local function SlashHandler(msg, editbox)
	if msg == "" or msg == nil then
		slash:help()
	else
		local command, arg = msg:match("^(%S*)%s*(.-)$")
		command = string.lower(command)
		if slash[command] then
			slash[command](arg)
		else
			print("TPST>Not a recognized command! Try /tpst help")
		end
	end
end
SlashCmdList["TEDSPVPSPELLTIMERS"] = SlashHandler
--Register Interface Options Panel
--Hook in options frame
c.name = "Ted's PVP Spelltimers"
InterfaceOptions_AddCategory(c)
--move button
function c.movebutton:Click()
	f:Mover()
end
c.movebutton:RegisterForClicks("AnyDown")
c.movebutton:SetScript("OnClick", c.movebutton.Click)
--reset button
function c.resetbutton:Click()
	m:Reset()
end
c.resetbutton:RegisterForClicks("AnyDown")
c.resetbutton:SetScript("OnClick", c.resetbutton.Click)
--testing open when reload
--InterfaceOptionsFrame_OpenToCategory(c)