--Teds_PVP_Spelltimers.lua by Zendil-The Underbog (US)
--Define locals
local f = Teds_PVP_Spelltimers_Frame
local m = Teds_PVP_Spelltimers_DragFrame
local w = {}
local s
--Set frame as user placed (this might be default? unsure)
f:SetUserPlaced(true)
--Define variables
w.activealerts = {}
--Create list of all defensive cooldowns that alerts will be created for
	--To add a spell, insert a new entry with the buff's spellid as the key and the name (or whatever text should be displayed) as the values
	--To remove a spell just delete or comment out it's line
	--Note when adding your own spells that the mechanism by which spells are tracked is as -BUFFS- on your -TARGET-
		--i.e. if you wanted to track "Marked for Death", it would not work as this creates a -DEBUFF- on the -PLAYER-
--TODO: PvP talents for all classes
w.filter_def = {
	--Demon Hunter
		[188501] = "Spectral Sight",
		[196555] = "Netherwalk",
		[212800] = "Blur",
		[207810] = "Nether Bond",
		[227225] = "Soul Barrier",
		[209426] = "Darkness",
		[218256] = "Empower Wards",
	--Death Knight
		[48792] = "Icebound Fortitude",
		[48707] = "Anti-Magic Shell",
		[55233] = "Vampiric Blood",
		[49028] = "Dancing Rune Weapon", --This might be the wrong id, further testing req
		[212552] = "Wraith Walk",
		[206977] = "Blood Mirror",
		[194679] = "Rune Tap",
		[207319] = "Corpse Shield",
	--Druid
		[1850] = "Dash",
		[22812] = "Barkskin",
		[102342] = "Ironbark",
		[61336] = "Survival Instincts",
		[33891] = "Incarnation: Tree of Life",
		[203727] = "Thorns",
		[106898] = "Stampeding Roar",
	--Hunter
		[186625] = "Aspect of the Turtle",
		[186257] = "Aspect of the Cheetah",
		[109215] = "Posthaste",
		[54216] = "Master's Call",
		[53480] = "Roar of Sacrifice",
	--Mage
		[45438] = "Ice Block",
		[86949] = "Cauterize",
		[198111] = "Temporal Shield",
		[110960] = "Greater Invisibility",
	--Monk
		[115203] = "Fortifying Brew",
		[213664] = "Nimble Brew",
		[116849] = "Life Cocoon",
		[125174] = "Touch of Karma",
		[115176] = "Zen Meditation",
		[122783] = "Diffuse Magic",
		[122278] = "Dampen Harm",
		[116844] = "Ring of Peace",
		[116841] = "Tiger's Lust",
	--Paladin
		[642] = "Divine Shield",
		[498] = "Divine Protection",
		[1022] = "Blessing of Protection",
		[1044] = "Blessing of Freedom",
		[6940] = "Blessing of Sacrifice",
		[31850] = "Ardent Defender",
		[31821] = "Aura Mastery",
		[190784] = "Divine Steed",--need proper buff id here (racial?)
		[86659] = "Guardian of Ancient Kings",
		[204150] = "Aegis of Light",
		[204018] = "Blessing of Spellwarding",
		[210256] = "Blessing of Sanctuary",
		[228049] = "Guardian of the Forgotten Queen",--verify buff spell id
	--Priest
		[81782] = "Power Word: Barrier",
		[47585] = "Dispersion",
		[47788] = "Guardian Spirit",
		[33206] = "Pain Suppression",
		[20711] = "Spirit of Redemption",
		[200183] = "Apotheosis",
		[64901] = "Symbol of Hope",
	--Rogue
		[5277] = "Evasion",
		[31224] = "Cloak of Shadows",
		[31230] = "Cheat Death",
		[76577] = "Smoke Bomb",--need to check buff id
		[2983] = "Sprint",
	--Shaman
		[114052] = "Ascendance", --Restoration only
		--Totems may or may not work; testing required
			[108280] = "Healing Tide",
			[98008] = "Spirit Link",
		[58875] = "Spirit Walk",
		[79206] = "Spiritwalker's Grace",
		[108271] = "Astral Shift",
		[204331] = "Counterstrike Totem",--id might need some work
		[210918] = "Ethereal Form",
		[204336] = "Grounding Totem",--id may need some work
		[108281] = "Ancestral Guidance",
		[207399] = "Ancestral Protection Totem",--id may need some work
		[192077] = "Wind Rush Totem",--id may need some work
	--Warlock
		[104773] = "Unending Resolve",
		[108416] = "Dark Pact",
		[212295] = "Nether Ward",
	--Warrior
		[23920] = "Spell Reflection",
		[12975] = "Last Stand",
		[871] = "Shield Wall",
		[46924] = "Bladestorm", --Added because you are immune to cc
		[114028] = "Spell Reflection", --Mass Spell Reflection
		[46947] = "Safeguard",
		[184364] = "Enraged Regeneration",
	}
--TODO: Offensive abilities, and give option to pick which filters are applied
--Define Handlers
function f:Event(event, ...)
	if event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
		f:Scan(event, ...)
	elseif event == "ADDON_LOADED" then
		f:Loaded(event, ...)
	elseif event == "PLAYER_LOGOUT" then
		f:Save(event, ...)
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
			local name,_,_,_,_,_,expire,_,steal,_,id = UnitAura("target",i,"HELPFUL")
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
	--if its our addon that loaded, assign local s to saved vars
	if addon == "Teds_PvP_Spelltimers" or addon == "Teds_PvP_Spelltimers_Testing" then
		s = Teds_PVP_Spelltimers_Save
	end
function f:Loaded()

end
function f:Save()

end
function Teds_PVP_Spelltimers_DragFrame:Center()
	local _,y = m:GetCenter()
	m:ClearAllPoints()
	m:SetPoint("CENTER", UIParent, "BOTTOM", 0, y)
end
function Teds_PVP_Spelltimers_DragFrame:Reset()
	m:ClearAllPoints()
	m:SetPoint("TOP", UIParent, "TOP", 0, -50)
end
function Teds_PVP_Spelltimers_DragFrame:Done()
	local x,y = m:GetCenter()
	m:Hide()
	f:ClearAllPoints()
	f:SetPoint("CENTER", UIParent, "BOTTOM", x, y)
	f:RegisterEvent("UNIT_AURA")
	f:RegisterEvent("PLAYER_TARGET_CHANGED")
end
function f:Mover()
	f:UnregisterEvent("UNIT_AURA")
	f:UnregisterEvent("PLAYER_TARGET_CHANGED")
	f:Hide()
	m:Show()
	if not m.loaded then
		m.loaded = true
		m:RegisterForDrag("LeftButton")
		m:SetScript("OnDragStart", m.StartMoving)
		m:SetScript("OnDragStop", m.StopMovingOrSizing)
		m.centerbutton:RegisterForClicks("AnyDown")
		m.centerbutton:SetScript("OnClick", m.Center)
		m.resetbutton:RegisterForClicks("AnyDown")
		m.resetbutton:SetScript("OnClick", m.Reset)
		m.donebutton:RegisterForClicks("AnyDown")
		m.donebutton:SetScript("OnClick", m.Done)
	end
end
T = f
--Assign Handlers
f:SetScript("OnEvent", f.Event)
f:SetScript("OnUpdate", f.Update)
--Register events
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
--TODO: Ability to move frame, save position between sessions