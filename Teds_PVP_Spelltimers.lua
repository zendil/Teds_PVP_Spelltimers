--Teds_PVP_Spelltimers.lua v1.0 by Zendil-The Underbog (US)
--Last updated WoW patch 6.2.4 (60200) %% 28 March 2016
local frame = Teds_PVP_Spelltimers_Frame
--Define variables
frame.activealerts = {}
--Create list of all defensive cooldowns that alerts will be created for
        --To add a spell, insert a new entry with the buff's spellid as the key and the name (or whatever text should be displayed) as the values
        --To remove a spell just delete or comment out it's line
        --Note when adding your own spells that the mechanism by which spells are tracked is as -BUFFS- on your -TARGET-
                --i.e. if you wanted to track "Marked for Death", it would not work as this creates a -DEBUFF- on the -PLAYER-
frame.filter_def = {
        --Demon Hunter
                [188501] = "Spectral Sight",
                [196555] = "Netherwalk",
                [198589] = "Blur",
                [207810] = "Nether Bond",
                [227225] = "Soul Barrier",
                [196718] = "Darkness",
                [218256] = "Empower Wards",
        --Druid
                [22812] = "Barkskin",
                [102342] = "Ironbark",
                [61336] = "Survival Instincts",
                [33891] = "Incarnation: Tree of Life",
        --Death Knight
                [48792] = "Icebound Fortitude",
                [48707] = "Anti-Magic Shell",
                [49039] = "Lichborne",
                [96268] = "Death's Advance",
                [115018] = "Desecrated Ground",
                [55233] = "Vampiric Blood",
                [171039] = "Rune Tap",
        --Hunter
                [19263] = "Deterrence",
                [109215] = "Posthaste",
                [54216] = "Master's Call",
                [53480] = "Roar of Sacrifice",
        --Mage
                [45438] = "Ice Block",
                [110909] = "Alter Time",
                [157913] = "Evanesce",
                [110960] = "Greater Invisibility",
        --Monk
                [115203] = "Fortifying Brew",
                [137562] = "Nimble Brew",
                [115308] = "Elusive Brew",
                [116849] = "Life Cocoon",
                --[122470] = "Touch of Karma", --This is the buff that goes on the target, not the monk
                [125174] = "Touch of Karma",
                [115176] = "Zen Meditation",
                [122783] = "Diffuse Magic",
                [122278] = "Dampen Harm",
                [116844] = "Ring of Peace",
                [116841] = "Tiger's Lust",
        --Paladin
                [642] = "Divine Shield",
                [498] = "Divine Protection",
                [1022] = "Hand of Protection",
                [1044] = "Hand of Freedom",
                [6940] = "Hand of Sacrifice",
                [31850] = "Ardent Defender",
                [31821] = "Devotion Aura",
                [85499] = "Speed of Light",
        --Priest
                [81782] = "Power Word: Barrier",
                [47585] = "Dispersion",
                [47788] = "Guardian Spirit",
                [33206] = "Pain Suppression",
                [20711] = "Spirit of Redemption",
        --Rogue
                [5277] = "Evasion",
                [1966] = "Feint",
                [31224] = "Cloak of Shadows",
                [108212] = "Burst of Speed",
                [31230] = "Cheat Death",
                [76577] = "Smoke Bomb",
        --Shaman
                [114052] = "Ascendance", --Restoration only
                --Totems may or may not work; testing required
                        [108280] = "Healing Tide",
                        [8143] = "Tremor Totem",
                        [98008] = "Spirit Link",
                [58875] = "Spirit Walk",
                [79206] = "Spiritwalker's Grace",
                [108271] = "Astral Shift",
                [30884] = "Nature's Guardian",
                [30823] = "Shamanistic Rage",
        --Warlock
                [48020] = "Soulburn Teleport",
                [111397] = "Blood Horror",
                [110913] = "Dark Bargain",
                [108359] = "Dark Regeneration",
        --Warrior
                [23920] = "Spell Reflection",
                [12975] = "Last Stand",
                [97462] = "Rallying Cry",
                [871] = "Shield Wall",
                [46924] = "Bladestorm", --Added because you are immune to cc
                [114028] = "Spell Reflection", --Mass Spell Reflection
                [114030] = "Vigilance",
                [46947] = "Safeguard",
}
--TODO: Offensive abilities, and give option to pick which filters are applied
--Define Handlers
local function event(self, event, ...)
        if event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
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
                        self.targetbuffs = {}
                        self.targetstealable = {}
                        --store the old values to check when theres new ones
                        self.activealerts_old = self.activealerts --creates a reference, not a copy. but it works?
                        self.activealerts = {}
                        --check all buffs
                        for i=1,40 do
                                local name,_,_,_,_,_,expire,_,steal,_,id = UnitAura("target",i,"HELPFUL")
                                if id then
                                        --if buff exists (id is within bounds) then cache it
                                        self.targetbuffs[i] = {["id"] = id,["expire"] = expire}
                                        if steal == 1 then
                                                --buff is stealable so store that too
                                                self.targetstealable[i] = name
                                                --this will be used in the future (future version)
                                        end
                                end
                        end
                        --now, filter for the ones we want
                        if self.targetbuffs then
                                --if we have buffs on target
                                for _,v in pairs(self.targetbuffs) do
                                        --iterate through the target's cached buffs
                                        if self.filter_def[v.id] and (v.expire - GetTime()) > 0 then
                                                --buff is in filter and has non-negative duration -> create alert
                                                self.activealerts[v.id] = {["name"] = self.filter_def[v.id],["expire"] = v.expire}
                                        end
                                end
                        end
                        --now, check if we had any that matched filter
                        if next(self.activealerts) ~= nil then
                                --we did match some filters. show the frame (which will start updates)
                                if not self:IsShown() then
                                        self:Show()
                                end
                        else
                                --no alerts to show. hide the frame (which stops updates)
                                if self:IsShown() then
                                    self:Hide()
                                end
                        end
                        for m,_ in pairs(self.activealerts) do
                                --we have to iterate to check for new entries
                                if not self.activealerts_old[m] then
                                        --we have new alerts. play sound
                                        PlaySoundFile("Interface\\Addons\\Teds_PVP_Spelltimers\\media\\BoxingArenaSound.ogg","Master")
                                end
                        end
                end
        end
end
local function update(self)
        --reset the output text
        self.output = ""
        local duration
        for _,t in pairs(self.activealerts) do
                --iterate through active alerts, adding each to the output text
                if self.output ~= "" then
                        self.output = self.output.."\n"
                end
                duration = t.expire - GetTime()
                if duration < 0 then
                        duration = 0
                end
                self.output = self.output..string.format("%.1f%s%.1f",duration," - "..t.name.." - ",duration)
        end
        --set the text once we have build the complete string
        self.fontstring:SetText(self.output)
end
--Assign Handlers
frame:SetScript("OnEvent", event)
frame:SetScript("OnUpdate", update)
--Register events
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
--TODO: Ability to move frame, save position between sessions