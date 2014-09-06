if myHero.charName ~= "Fiora" then return end

require 'VPrediction'
--require 'SOW'

--_G.PredictAnnie = function() PredictAnnie() end
--_G.PredictSyndra = function() PredictSnydra() end
--_G.PredictAmumu = function() PredictAmumu() end

local qReady, wReady, eReady, rReady, flashReady  = false, false, false, false, false
local QRANGE, RRANGE = 600, 400
local levelChart = {SPELL_1, SPELL_2, SPELL_3}
local _Flash = nil
local _Malphite = nil

wList =	{
	["Renekton"] = "RenektonExecute",
	["MissFortune"] = "MissFortuneRicochetShot",
	["Leona"] = "LeonaShieldOfDaybreakAttack",
	["Garen"] = "GarenSlash2",
	["Nasus"] = "NasusQAttack",
	["Shyvana"] = "ShyvanaDoubleAttackHit",
	["Darius"] = "DariusNoxianTacticsONH",
	["Gangplank"] = "Parley",
	["Sivir"] = "RicochetAttack",
	["Talon"] = "TalonNoxianDiplomacyAttack",
	["Jax"] = "jaxrelentlessattack"
		}
rList = {
	["Amumu"] = "CurseoftheSadMummy",
	["Annie"] = "InfernalGuardian",
	["LeeSin"] = "BlindMonkRKick",
	["Sona"] = "SonaR",
	["Syndra"] = "syndrar",
	["Veigar"] = "PrimordialBurst",
	["Brand"] = "Pyroclasm",
	["Malzahar"] = "NetherGrasp",
	["Malphite"] = "UFSlash",
	["Vi"] = "ViR"
	}
function CDHandler()
	qReady = (myHero:CanUseSpell(_Q) == READY)
	wReady = (myHero:CanUseSpell(_W) == READY)
	eReady = (myHero:CanUseSpell(_E) == READY)
	rReady = (myHero:CanUseSpell(_R) == READY)
	flashReady = _Flash and myHero:CanUseSpell(_Flash) == READY or false
	--for _, item in pairs(Items) do
		--item.ready = GetInventoryItemIsCastable(item.id)
	--end
end
  
function GodMode() 
	if Menu.MainCombo.QSettings.UseQ and ts.target ~= nil and ValidTarget(ts.target, 600) then
		CastQ() 
	end
end 
		
function CastQ()
	if GetDistance(ts.target) > Menu.MainCombo.QSettings.QBuffer and qReady then
		CastSpell(_Q, ts.target)
		--if Items.YGB.ready then CastItem(Items.YGB.id) end
	end
end

function CastE()
	nextAA = _G.MMA_NextAttackAvailability
	if nextAA > 0.1 and nextAA < 0.2  and eReady then
		CastSpell(_E)
		_G.MMA_ResetAutoAttack()
	end
	--[[if Menu.MainCombo.GodKey and Menu.MainCombo.ESettings.UseE and ts.target ~= nil and ValidTarget(ts.target, 250) and eReady then
		CastSpell(_E)
	end
	if Menu.MainCombo.GodKey and not eReady and ValidTarget(ts.target, 300) then
		if Items.HYDRA.ready then CastItem(Items.HYDRA.id) end
		if Items.TIAMAT.ready then CastItem(Items.TIAMAT.id) end
	end]]--
end
        
function KSQ()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		if qReady and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
			CastSpell(_Q, enemy)
		end
	end
end

function KSW(unit)
	wDmg = getDmg("W", unit, myHero)
	return unit.health < wDmg and wReady and unit.type == myHero.type and Menu.Misc.KSSettings.KSW
	
end
function PredictAmumu(unit, spell)
	if GetDistance(unit) < 600 and not flashReady then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictAnnie(unit, spell)
	if GetDistance(spell.endPos) < 270 and not flashReady then 
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictBrand(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictLeeSin(unit,spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictMalphite(unit, spell)
	if GetDistance(spell.endPos) < 270 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictMalzahar(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictSona(unit, spell)
	SendChat("/all sona R: "..math.round(spell.endPos.x).." "..math.round(spell.endPos.y).." ".. math.round(spell.endPos.z))
	SendChat("/all fiora: "..math.round(myHero.x).." "..math.round(myHero.y).." "..math.round(myHero.z))
	local myX = myHero.visionPos.x
	local myZ = myHero.visionPos.z

	local sonaX = unit.visionPos.x
	local sonaZ = unit.visionPos.z

	local spellX = spell.endPos.x
	local spellZ = spell.endPos.z

	local distance = math.abs((myZ-sonaZ)*(sonaX-spellX)-(myX-sonaX)*(sonaZ-spellZ))/math.sqrt((myX-sonaX)*(myX-sonaX)+(myZ-sonaZ)*(myZ-sonaZ))
	SendChat("/all Dist from line: "..distance)
	if distance < 70 and (GetDistance(unit) < 1000 and GetDistance(spell.endPos) < 1000) then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictSyndra(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictVeigar(unit, spell)
	if GetDistance(spell.endPos) < 1 then 
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function PredictVi(unit, spell)
	if GetDistance(spell.endPos) < 1000 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastSpell(_R, ts.target)
		end
		ts.range = 600
	end
end

function WPrediction(unit, spell)
	if wReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 50 and Menu.MainCombo.WSettings["w"..unit.charName] and wList[unit.charName] ~= nil and (spell.name:find(wList[unit.charName]) ~= nil) then
		CastSpell(_W)
	end
end

function RPrediction(unit, spell)
	if rReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 10000 and Menu.MainCombo.RSettings.RPrediction[unit.charName] and rList[unit.charName] ~= nil and (spell.name:find(rList[unit.charName]) ~= nil) then
		_ENV["Predict"..unit.charName](unit, spell)
	end
end

function AAPrediction(unit, spell)
	if wReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 10 and (Menu.MainCombo.WSettings["aa"..unit.charName] or KSW(unit)) and (spell.name:find("Attack") ~= nil) then
		CastSpell(_W)
	end
end

function OnProcessSpell(unit, spell)
	--if unit.charName == "Sona" and spell.name:find("Attack") == nil then SendChat("/all "..spell.name.." Dist: "..GetDistance(spell.endPos)) end
	RPrediction(unit, spell)
	WPrediction(unit, spell)
	AAPrediction(unit, spell)
end

function xMenu()
	Menu = scriptConfig("Fiora by seoul", "FioraSeoul")
	
	Menu:addParam("blank", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("version", "Version 0.08", SCRIPT_PARAM_INFO, "")
	
	--Menu:addSubMenu("SOW", "xSOW")
  --  xSOW:LoadToMenu(Menu.xSOW) 
	
	Menu:addSubMenu("MISC", "Misc")
	Menu.Misc:addSubMenu("Draw", "ToDraw")
	Menu.Misc.ToDraw:addParam("DrawQ", "Draw Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.ToDraw:addParam("DrawR", "Draw R", SCRIPT_PARAM_ONOFF, true)  
	--Menu.Misc:addSubMenu("Auto Level", "AutoLevel")
	--Menu.Misc.AutoLevel:addParam("SkillAt2", "Level 2", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
	--Menu.Misc.AutoLevel:addParam("SkillAt3", "Level 3", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
	--Menu.Misc.AutoLevel:addParam("UseAutoLevel", "Use Auto Level", SCRIPT_PARAM_ONOFF, false)
	Menu.Misc:addSubMenu("Kill Steal", "KSSettings")
	Menu.Misc.KSSettings:addParam("KSQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.KSSettings:addParam("KSW", "Use W (Beta)", SCRIPT_PARAM_ONOFF, true)
				
	Menu:addSubMenu("Target Selector", "targetSelector")
	Menu.targetSelector:addTS(ts)
	ts.name = "Focus"
	
	Menu:addSubMenu("Combo Settings", "MainCombo")
	Menu.MainCombo:addSubMenu("Q Settings", "QSettings")
	Menu.MainCombo.QSettings:addParam("QBuffer", "Q Buffer", SCRIPT_PARAM_SLICE, 250, 0, 600, 0)
	Menu.MainCombo.QSettings:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true) 
	Menu.MainCombo:addSubMenu("W Settings", "WSettings")
	Menu.MainCombo.WSettings:addParam("basicAA", "Basic Attacks:", SCRIPT_PARAM_INFO, "")
	
	local aaPredict = false
	for i, enemy in ipairs(GetEnemyHeroes()) do
		Menu.MainCombo.WSettings:addParam("aa"..enemy.charName, " :"..enemy.charName, SCRIPT_PARAM_ONOFF, true)
		aaPredict = true
	end
	if not aaPredict then
		Menu.MainCombo.WSettings:addParam("aaNotSupported","---Not Supported---", SCRIPT_PARAM_INFO, "")
	end

	Menu.MainCombo.WSettings:addParam("blank", "", SCRIPT_PARAM_INFO, "")
	Menu.MainCombo.WSettings:addParam("spellblock", "Spells:", SCRIPT_PARAM_INFO, "")
	
	local wPredict = false
	for champ, spell in pairs(wList) do
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if enemy.charName == champ then
				Menu.MainCombo.WSettings:addParam("w"..enemy.charName, enemy.charName.." - "..spell, SCRIPT_PARAM_ONOFF, true)
				wPredict = true
			end
		end
	end
	if not wPredict then
		Menu.MainCombo.WSettings:addParam("wNotSupported","---Not Supported---", SCRIPT_PARAM_INFO, "")
	end

	--Menu.MainCombo:addSubMenu("E Settings", "ESettings")
	--Menu.MainCombo.ESettings:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Menu.MainCombo:addSubMenu("R Settings", "RSettings")
	Menu.MainCombo.RSettings:addSubMenu("Dodge", "RPrediction")

	local rPredict = false
	for champ, spell in pairs(rList) do
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if enemy.charName == champ then
				Menu.MainCombo.RSettings.RPrediction:addParam(enemy.charName, enemy.charName.." - "..spell, SCRIPT_PARAM_ONOFF, true)
				rPredict = true
			end
		end
	end
	if not rPredict then
		Menu.MainCombo.RSettings.RPrediction:addParam("rNotSupported","Not Supported", SCRIPT_PARAM_INFO, "")
	end

	Menu.MainCombo:addParam("GodKey", "God Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
end

function OnDraw()
	if Menu.Misc.ToDraw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRANGE, 0x111111)
	end
  
	if Menu.Misc.ToDraw.DrawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRANGE, 0x111111)
	end
end

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST, QRANGE)
	vPrd = VPrediction()
	xMenu()		
	--xSOW = SOW(vPrd)
	--xSOW:RegisterAfterAttackCallback(CastE)	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		_Flash = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") then
		_Flash = SUMMONER_2
	else
		_Flash = nil
	end
end

function OnTick()
	if myHero.dead then return end
	--SendChat("/all "..math.round(myHero.x).." "..math.round(myHero.y).." "..math.round(myHero.z))
	ts:update()
	CDHandler()
	
	--SendChat("/all "..GetDistance(_Malphite).."")
	if Menu.Misc.KSSettings.KSQ then KSQ() end
	if Menu.MainCombo.GodKey then GodMode() end
	--if Menu.Misc.AutoLevel.UseAutoLevel then AutoLevel() end
	
end
