if myHero.charName ~= "Fiora" or not VIP_USER then return end

require 'VPrediction'
require 'SOW'

local version = 3.00
local seoul, hanq, hanw, hanr, hani = nil, false, false, false, false
local lastSkin = 4

function Han()
    Han_Q()
    Han_Botrk()
    Han_Ult()
end 

function Han_Target()
    ts:update()
    if Menu.Combo.Lock and GetTarget() ~= nil then
        seoul = GetTarget()
    else
        seoul = ts.target
    end
		sow:ForceTarget(seoul)
end

local mousex, mousey, targetx, targety = nil, nil, nil, nil
function Han_Magnet()
    if (Menu.Combo.Key or Menu.Combo.Smuggle) and seoul ~= nil and Menu.Combo.Magnet and GetDistance(seoul) < 127 then
        mousex, mousey, targetx, targety = mousePos.x, mousePos.z, seoul.x, seoul.z
        local distance = (mousex-targetx)^2 + (mousey-targety)^2
        if distance < Menu.Combo.MagnetRange^2 then
            sow:OrbWalk(seoul, myHero)
        end
    end
end

function Han_Botrk()
    local health = myHero.health
    if Menu.Combo.Key and seoul ~= nil and Menu.Misc.Item.Botrk and GetInventoryItemIsCastable(3153) and GetDistanceSqr(seoul) < 202500 and ValidTarget(seoul, 450) and (health <= Menu.Misc.Item.SetBotrk1 or health >= Menu.Misc.Item.SetBotrk2) then
        CastItem(3153, seoul)
    end
end

local tokyo = false
local q1Time = math.huge
function Han_Q()
    if Menu.Combo.Key and not tokyo and hanq and seoul ~= nil and GetDistanceSqr(seoul) >= (Menu.Combo.QSet.QBuffer)^2 and Menu.Combo.QSet.Q then
        Packet("S_CAST", {spellId = _Q, targetNetworkId = seoul.networkID}):send()
        tokyo = true
		q1Time = os.clock() + 4
    elseif Menu.Combo.Key and tokyo and hanq and seoul ~= nil and (Menu.Combo.QSet.Q2Buffer > 250 or not Menu.Combo.QSet.QAfter) and GetDistanceSqr(seoul) >= (Menu.Combo.QSet.Q2Buffer)^2 and os.clock() > (q1Time - 3.65) and Menu.Combo.QSet.Q then
        Packet("S_CAST", {spellId = _Q, targetNetworkId = seoul.networkID}):send()
        tokyo = false
		q1Time = math.huge
    elseif tokyo and os.clock() > q1Time then
        tokyo = false
				q1Time = math.huge
    end
end

function Han_Ult()
    if Menu.Combo.RSet.Help and seoul ~= nil and myHero:CanUseSpell(_R) == READY and ValidTarget(seoul, 400) then
        Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
    end
end

function Han_Smuggle()
  if Menu.Combo.Smuggle and seoul ~= nil then
		sow:OrbWalk(seoul, mousePos)
	elseif Menu.Combo.Smuggle then
		sow:MoveTo(mousePos.x, mousePos.z)
	end
end

local singapore = true
function Han_Smuggle_Combo()
	if singapore then
		if hanw then
			Packet("S_CAST", {spellId = _E}):send()
		end
		if hanq and seoul ~= nil then 
			Packet("S_CAST", {spellId = _Q, targetNetworkId = seoul.networkID}):send()
		end
		singapore = false
	elseif not singapore then
		if hanq and seoul ~= nil then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = seoul.networkID}):send()
		end
		if Menu.Combo.Smuggle and GetInventoryItemIsCastable(3074) and Menu.Misc.Item.Hydra then
        CastItem(3074)
    elseif Menu.Combo.Smuggle and GetInventoryItemIsCastable(3077) and Menu.Misc.Item.Tiamat then
        CastItem(3077)
    end
		singapore = true
	end
end

function Han_After()
		if Menu.Combo.Smuggle then
			Han_Smuggle_Combo()
		end
    if Menu.Combo.Key and Menu.Combo.ESet.E and ValidTarget(seoul, 250) then
        sow:MoveTo(mousePos.x, mousePos.z)
    end

    if Menu.Combo.Key and GetInventoryItemIsCastable(3074) and Menu.Misc.Item.Hydra then
        CastItem(3074)
    elseif Menu.Combo.Key and GetInventoryItemIsCastable(3077) and Menu.Misc.Item.Tiamat then
        CastItem(3077)
    end

	if Menu.Combo.Key and hanq and seoul ~= nil and Menu.Combo.QSet.Q2Buffer <= 250 and Menu.Combo.QSet.QAfter and Menu.Combo.QSet.Q then
        Packet("S_CAST", {spellId = _Q, targetNetworkId = seoul.networkID}):send()
    end
end

function Han_On()
		if Menu.Combo.Smuggle and GetInventoryItemIsCastable(3153) then
			CastItem(3153, seoul)
		end
    if Menu.Combo.Key and GetInventoryItemIsCastable(3142) and Menu.Misc.Item.Ygb then
        CastItem(3142)
    end
end

local FLASH, IGNITE = nil, nil
function Han_Summoner()
    if myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") then
        FLASH = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") then
        FLASH = SUMMONER_2
    else
        FLASH = nil
    end
    if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
        IGNITE = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
        IGNITE = SUMMONER_2
    else
        IGNITE = nil
    end
end

function Han_Kill()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        if Menu.Misc.Ks.Q then
            if hanq and getDmg("Q", enemy, myHero) > enemy.health and GetDistanceSqr(enemy) <= 360000 and ValidTarget(enemy, 600) then
                Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkId}):send()
            end
        end
        if Menu.Misc.Ks.Ignite then
            if hani and getDmg("IGNITE", enemy, myHero) > enemy.health and GetDistanceSqr(enemy) <= 360000 and ValidTarget(enemy, 600) then
                CastSpell(IGNITE, enemy)
            end
        end
    end
end

function Han_Amumu(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) or GetDistance(unit) < 250 then
        if GetDistance(unit) < 600 then
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target, 400) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

function Han_Annie(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) then
        if GetDistance(spell.endPos) < 270 then 
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target, 400) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

local amyx, amyz, ashex, ashez, aspellx, aspellz = nil, nil, nil, nil, nil, nil
function Han_Ashe(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) then
        amyx, amyz, ashex, ashez, aspellx, aspellz = myHero.visionPos.x, myHero.visionPos.z, unit.visionPos.x, unit.visionPos.z, spell.endPos.x, spell.endPos.z
        local distance = math.abs((amyz-ashez)*(ashex-aspellx)-(amyx-ashex)*(ashez-aspellz))/math.sqrt((amyx-ashex)*(amyx-ashex)+(amyz-ashez)*(amyz-ashez))
        if distance < 102.5 and GetDistance(unit) < 1000 then
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

function Han_Brand(unit, spell)
    if GetDistance(spell.endPos) < 1 then
        ts.range = 400
        ts:update()
        if ts.target ~= nil and ValidTarget(ts.target, 400) then
            Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
        end
        ts.range = 600
        Han_Target()
    end
end

function Han_Galio(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) or GetDistance(unit) < 250 then
        if GetDistanceSqr(unit) < 360000 then
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target, 400) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

function Han_Gragas(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) then
        if GetDistance(spell.endPos) < 375 then 
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target, 400) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

function Han_Malphite(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) then
        if GetDistance(spell.endPos) < 270 then
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target, 400) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

local smyx, smyz, sonax, sonaz, sspellx, sspellz = nil, nil, nil, nil, nil, nil
function Han_Sona(unit, spell)
    if ((Menu.Combo.RSet.Flash and not (FLASH and myHero:CanUseSpell(FLASH) == READY or false)) or not Menu.Combo.RSet.Flash) then
        smyx, smyz, sonax, sonaz, sspellx, sspellz = myHero.visionPos.x, myHero.visionPos.z, unit.visionPos.x, unit.visionPos.z, spell.endPos.x, spell.endPos.z
        local distance = math.abs((smyz-sonaz)*(sonax-sspellx)-(smyx-sonax)*(sonaz-sspellz))/math.sqrt((smyx-sonax)*(smyx-sonax)+(smyz-sonaz)*(smyz-sonaz))
        if distance < 132.5 and (GetDistance(unit) < 1000 and GetDistance(spell.endPos) < 1000) then
            ts.range = 400
            ts:update()
            if ts.target ~= nil and ValidTarget(ts.target) then
                Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
            end
            ts.range = 600
            Han_Target()
        end
    end
end

function Han_Syndra(unit, spell)
    if GetDistance(spell.endPos) < 1 then
        ts.range = 400
        ts:update()
        if ts.target ~= nil and ValidTarget(ts.target, 400) then
            Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
        end
        ts.range = 600
        Han_Target()
    end
end

function Han_Tristana(unit, spell)
    if GetDistance(spell.endPos) < 50 then
        ts.range = 400
        ts:update()
        if ts.target ~= nil and ValidTarget(ts.target, 400) then
            Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
        end
        ts.range = 600
        Han_Target()
    end
end

function Han_Veigar(unit, spell)
    if GetDistance(spell.endPos) < 1 then 
        ts.range = 400
        ts:update()
        if ts.target ~= nil and ValidTarget(ts.target, 400) then
            Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
        end
        ts.range = 600
        Han_Target()
    end
end

function Han_Vi(unit, spell)
    if GetDistance(spell.endPos) < 1000 then
        ts.range = 400
        ts:update()
        if ts.target ~= nil and ValidTarget(ts.target, 400) then
            Packet("S_CAST", {spellId = _R, targetNetworkId = seoul.networkID}):send()
        end
        ts.range = 600
        Han_Target()
    end
end

-- Data from VPrediction
projectilespeed = {["Velkoz"]= 2000,["Xerath"] = 2000.0000,["Ziggs"] = 1500.0000,["KogMaw"] = 1800.0000,["Ashe"] = 2000.0000 ,["Soraka"] = 1000.0000 ,["Jinx"] = 2750.0000,["Ahri"] = 1750.0000 ,["Lulu"] = 1450.0000,["Lissandra"] = 2000.0000,["Draven"] = 1700.0000 ,["FiddleSticks"] = 1750.0000 ,["Sivir"] = 1750.0000 ,["Corki"] = 2000.0000 ,["Janna"] = 1200.0000,["Sona"] = 1500.0000,["Caitlyn"] = 2500.0000,["Anivia"] = 1400.0000,["Heimerdinger"] = 1500.0000 ,["Leblanc"] = 1700.0000 ,["Viktor"] = 2300.0000 ,["Orianna"] = 1450.0000 ,["Vladimir"] = 1400.0000 ,["Nidalee"] = 1750.0000 ,["Syndra"] = 1800.0000 ,["Veigar"] = 1100.0000 ,["Twitch"] = 2500.0000 ,["Urgot"] = 1300.0000 ,["Karma"] = 1500.0000 ,["TwistedFate"] = 1500.0000 ,["Varus"] = 2000.0000,["Swain"] = 1600.0000 ,["Vayne"] = 2000.0000,["Quinn"] = 2000.0000,["Brand"] = 2000.0000 ,["Teemo"] = 1300.0000 ,["Annie"] = 1200.0000,["Elise"] = 1600.0000 ,["Nami"] = 1500.0000,["Tristana"] = 2250.0000 ,["Graves"] = 3000.0000 ,["Morgana"] = 1600.0000,["MissFortune"] = 2000.0000,["Cassiopeia"] = 1200.0000,["Lucian"] = 2800.0000,["Kennen"] = 1600.0000 ,["Ryze"] = 2400.0000,["Lux"] = 1600.0000 ,["Ezreal"] = 2000.0000,["Zyra"] = 1700.0000 ,["Karthus"] = 1200.0000 ,["Zilean"] = 1200.0000,["Malzahar"] = 2000.0000}
wlist = {["Renekton"] = "RenektonExecute",["MissFortune"] = "MissFortuneRicochetShot",["Leona"] = "LeonaShieldOfDaybreakAttack",["Garen"] = "GarenSlash2",["Nasus"] = "NasusQAttack",["Shyvana"] = "ShyvanaDoubleAttackHit",["Darius"] = "DariusNoxianTacticsONHAttack",["Gangplank"] = "Parley",["Sivir"] = "RicochetAttack",["Talon"] = "TalonNoxianDiplomacyAttack",["Jax"] = "jaxrelentlessattack"}
rlist = {["Amumu"] = "CurseoftheSadMummy",["Annie"] = "InfernalGuardian",["Ashe"] = "EnchantedCrystalArrow",["Galio"] = "GalioIdolOfDurand",["Gragas"] = "GragasR",["Sona"] = "SonaR",["Syndra"] = "syndrar",["Tristana"] = "BusterShot",["Malphite"] = "UFSlash",["Veigar"] = "VeigarPrimordialBurst",["Vi"] = "ViR"}
local current = nil
local shanghai = nil
ActiveAttacks = {}
Han_Pre = {}
local safecall = true
function Han_W(unit, spell)
    if safecall then
        if GetDistance(spell.endPos) < 50 and not unit.isMe then
            if projectilespeed[unit.charName] ~= nil and (spell.name:find("Attack") ~= nil) and GetDistance(spell.endPos) < 1 and unit.team ~= myHero.team and unit.type == myHero.type and Menu.Combo.WSet["aa"..unit.charName] then
                safecall = false
                local delay = (GetDistance(unit)/(projectilespeed[unit.charName]/1000))*0.9
                current = unit
                shanghai = os.clock()
                local wCalc = {castTime = shanghai+(delay/1000)}
                table.insert(Han_Pre, wCalc)
                table.insert(ActiveAttacks, unit.networkID)
            elseif hanw and (spell.name:find("Attack") ~= nil) and GetDistance(spell.endPos) < 1 and unit.team ~= myHero.team and unit.type == myHero.type and Menu.Combo.WSet["aa"..unit.charName] then
                Packet("S_CAST", {spellId = _W}):send()
            elseif hanw and unit.team ~= myHero.team and Menu.Combo.WSet["w"..unit.charName] and wlist[unit.charName] ~= nil and (spell.name:find(wlist[unit.charName]) ~= nil) then
                Packet("S_CAST", {spellId = _W}):send() 
            end
        end
    end
end

-- ty germansk8er
local cancelled = false
function OnRecvPacket(p)
   if not safecall then
        if p.header == 0x34 then
            p.pos = 1
            if ActiveAttacks[1] == p:DecodeF() then
                p.pos = 9
                if p:Decode1() == 0x11 then
                    cancelled = true
                    table.remove(ActiveAttacks, 1)
                end
            end
        end
    end
end
  
function Han_WTick()
    for i, wCalc in ipairs(Han_Pre) do
        wCalc.castTime = shanghai + ((GetDistance(current)/(projectilespeed[current.charName]/1000))*0.9)/1000
        if os.clock() >= wCalc.castTime and not cancelled and hanw then
            Packet("S_CAST", {spellId = _W}):send()
            shanghai = nil
            table.remove(Han_Pre, 1)
            current = nil
            safecall = true
        elseif os.clock() >= wCalc.castTime and cancelled then
            shanghai = nil
            table.remove(Han_Pre, 1)
            cancelled = false
            current = nil
            safecall = true
        end
    end
end

function Han_R(unit, spell)
    if hanr and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 1000 and Menu.Combo.RSet[unit.charName] and rList[unit.charName] ~= nil and (spell.name:find(rList[unit.charName]) ~= nil) then
        _ENV["Han_"..unit.charName](unit, spell)
    end
end

function OnProcessSpell(unit, spell)
    Han_W(unit, spell)
    Han_R(unit, spell)
end

function Menu()
    Menu = scriptConfig("Han Fiora", "HanFiora")
    
    Menu:addParam("blank", "", SCRIPT_PARAM_INFO, "")
    Menu:addParam("version", "Version "..version, SCRIPT_PARAM_INFO, "")

    Menu:addSubMenu("Orbwalker", "sow1")
    sow:LoadToMenu(Menu.sow1) 
    
    Menu:addSubMenu("Target Selector", "Ts")
    Menu.Ts:addTS(ts)
    ts.name = "Focus"
        
    Menu:addSubMenu("Han Misc", "Misc")
    Menu.Misc:addSubMenu("Draw", "Draw")
    Menu.Misc.Draw:addParam("Q", "Draw Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Draw:addParam("R", "Draw R", SCRIPT_PARAM_ONOFF, true)  
    Menu.Misc:addSubMenu("Kill Steal", "Ks")
    Menu.Misc.Ks:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Ks:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Ks:addParam("Ignite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc:addSubMenu("Items", "Item")
    Menu.Misc.Item:addParam("Hydra", "Hydra", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Item:addParam("Tiamat", "Tiamat", SCRIPT_PARAM_ONOFF, true)
        --Menu.Misc.Item:addParam("Air", "Try to cast mid air q", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Item:addParam("Ygb", "Youmuu's Ghostblade", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Item:addParam("Botrk", "Blade of the ruined King", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc.Item:addParam("SetBotrk1", "Botrk if my HP <= %", SCRIPT_PARAM_SLICE, 20, 0, 100)
    Menu.Misc.Item:addParam("SetBotrk2", "Botrk if enemy HP >= %", SCRIPT_PARAM_SLICE, 60, 0, 100)

    Menu.Misc:addSubMenu("VIP", "Vip")
    Menu.Misc.Vip:addParam("Skin", "Skin changer", SCRIPT_PARAM_ONOFF, false)
    Menu.Misc.Vip:addParam("Select", "Select Skin", SCRIPT_PARAM_SLICE, 4, 1, 4)
    if Menu.Misc.Vip.Skin then
        GenModelPacket("Fiora", Menu.Misc.Vip.Select)
        lastSkin = Menu.Misc.Vip.Select
    end        
    
    Menu:addSubMenu("Han Combo", "Combo")
    Menu.Combo:addSubMenu("Q Settings", "QSet")
    Menu.Combo.QSet:addParam("QBuffer", "1st Q Buffer", SCRIPT_PARAM_SLICE, 325, 0, 600, 0)
    Menu.Combo.QSet:addParam("Q2Buffer", "2nd Q Buffer", SCRIPT_PARAM_SLICE, 325, 0, 600, 0)
		Menu.Combo.QSet:addParam("QAfter", "Q After AA if 2nd Buffer <= 250", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo.QSet:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addSubMenu("W Settings", "WSet")
    Menu.Combo.WSet:addParam("Vip", "Use VIP W", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo.WSet:addParam("blank", "", SCRIPT_PARAM_INFO, "")
  
    local aaPredict = false
    for i, enemy in ipairs(GetEnemyHeroes()) do
        Menu.Combo.WSet:addParam("aa"..enemy.charName, "_"..enemy.charName, SCRIPT_PARAM_ONOFF, true)
        aaPredict = true
    end
    if not aaPredict then
        Menu.Combo.WSet:addParam("aaNotSupported","y u alone here :o", SCRIPT_PARAM_INFO, "")
    end

    Menu.Combo.WSet:addParam("blank1", "", SCRIPT_PARAM_INFO, "")
   
    local wPredict = false
    for champ, spell in pairs(wlist) do
        for i, enemy in ipairs(GetEnemyHeroes()) do
            if enemy.charName == champ then
                Menu.Combo.WSet:addParam("w"..enemy.charName, enemy.charName.." - "..spell, SCRIPT_PARAM_ONOFF, true)
                wPredict = true
            end
        end
    end
    if not wPredict then
        Menu.Combo.WSet:addParam("wNotSupported","No spells supported", SCRIPT_PARAM_INFO, "")
    end

    Menu.Combo:addSubMenu("E Settings", "ESet")
    Menu.Combo.ESet:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addSubMenu("R Settings", "RSet")
    Menu.Combo.RSet:addParam("dodge", "Dodge:", SCRIPT_PARAM_INFO, "")
    
    local rPredict = false
    for champ, spell in pairs(rlist) do
        for i, enemy in ipairs(GetEnemyHeroes()) do
            if enemy.charName == champ then
                Menu.Combo.RSet:addParam(enemy.charName, enemy.charName.." - "..spell, SCRIPT_PARAM_ONOFF, true)
                rPredict = true
            end
        end
    end
    if not rPredict then
        Menu.Combo.RSet:addParam("rNotSupported","Not Supported", SCRIPT_PARAM_INFO, "")
    end
    Menu.Combo.RSet:addParam("blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo.RSet:addParam("blank", "For Evade script users:", SCRIPT_PARAM_INFO, "")
    Menu.Combo.RSet:addParam("Flash", "Prioritize Flash > Ult", SCRIPT_PARAM_ONOFF, false)
    Menu.Combo.RSet:addParam("blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo.RSet:addParam("Help", "Ult Helper", SCRIPT_PARAM_ONKEYDOWN, false, 82)
    Menu.Combo:addParam("Magnet", "Use Magnet", SCRIPT_PARAM_ONOFF, true)
    Menu.Combo:addParam("MagnetRange", "Magnet Radius",SCRIPT_PARAM_SLICE, 75, 0, myHero.range-1 )
    Menu.Combo:addParam("Lock", "Focus left clicked target", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("Smuggle", "Han Smuggle", SCRIPT_PARAM_ONKEYDOWN, false, 86)
    Menu.Combo:addParam("Key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
end

local skinFix = 0
function Skin()
    if Menu.Misc.Vip.Select ~= lastSkin and Menu.Misc.Vip.Skin then
        GenModelPacket("Fiora", Menu.Misc.Vip.Select)
        lastSkin = Menu.Misc.Vip.Select
        skinFix = 1
    end
    if not Menu.Misc.Vip.Skin and skinFix > 0 then
        GenModelPacket("Fiora", 4)
        lastSkin = 4
    end
end

-- Shalzut
function GenModelPacket(champ, skinId)
    p = CLoLPacket(0x97)
    p:EncodeF(myHero.networkID)
    p.pos = 1
    t1 = p:Decode1()
    t2 = p:Decode1()
    t3 = p:Decode1()
    t4 = p:Decode1()
    p:Encode1(t1)
    p:Encode1(t2)
    p:Encode1(t3)
    p:Encode1(bit32.band(t4,0xB))
    p:Encode1(1)--hardcode 1 bitfield
    p:Encode4(skinId)
    for i = 1, #champ do
        p:Encode1(string.byte(champ:sub(i,i)))
    end
    for i = #champ + 1, 64 do
        p:Encode1(0)
    end
    p:Hide()
    RecvPacket(p)
end

function OnDraw()
    if Menu.Misc.Draw.Q then
        DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
    end
  
    if Menu.Misc.Draw.R then
        DrawCircle(myHero.x, myHero.y, myHero.z, 400, 0x111111)
    end
end

function OnLoad()
    ts = TargetSelector(TARGET_LESS_CAST, 600)
    vp = VPrediction()      
    sow = SOW(vp)
    sow:RegisterAfterAttackCallback(Han_After)
    sow:RegisterOnAttackCallback(Han_On)
    Menu()
    Han_Summoner()
    PrintChat("Han Fiora loaded. version 3.00")
end

function Han_Tick()
    hanq =  myHero:CanUseSpell(_Q) == READY
    hanw =  myHero:CanUseSpell(_W) == READY
    hanr =  myHero:CanUseSpell(_R) == READY
    hani = IGNITE and myHero:CanUseSpell(IGNITE) == READY or false
end
  
function OnTick()
    if myHero.dead then return end
    Han_Target()
    Han_Magnet()
    Han_WTick()
    Han_Tick()
    Han()
		Han_Smuggle()
    Han_Kill()
    Skin()
end
