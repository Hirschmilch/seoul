if myHero.charName ~= "Fiora" then return end

require 'VPrediction'
require 'SOW'

local qReady, eReady  = false, false
local QRANGE, RRANGE = 600, 400
local levelChart = {SPELL_1, SPELL_2, SPELL_3}
local champio = nil

function CDHandler()
	qReady = (myHero:CanUseSpell(_Q) == READY)
	wReady = (myHero:CanUseSpell(_W) == READY)
	eReady = (myHero:CanUseSpell(_E) == READY)
end
  
function GodMode() 
	if Menu.MainCombo.QSettings.UseQ and ts.target ~= nil and ValidTarget(ts.target, 600) then
		CastQ() 
	end
  
	if Menu.MainCombo.ESettings.UseE and ts.target ~= nil and ValidTarget(ts.target, 250) then
		CastE()
	end
end 

function CastQ()
	if GetDistance(ts.target) > Menu.MainCombo.QSettings.QBuffer and qReady then
		CastSpell(_Q, ts.target)
	end
end

function CastE()
	xSOW:RegisterAfterAttackCallback(function() CastSpell(_E) end)
	if _G.MMA_Loaded then
		nextAA = _G.MMA_NextAttackAvailability
		if nextAA > 0.1 and nextAA < 0.2  and eReady then
			CastSpell(_E)
			_G.MMA_ResetAutoAttack()
		end
	end
	
end
        
function KSQ()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		if qReady and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
			CastSpell(_Q, enemy)
		end
	end
end

function OnDraw()
	if Menu.Misc.ToDraw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRANGE, 0x111111)
	end
  
	if Menu.Misc.ToDraw.DrawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRANGE, 0x111111)
	end
end

function KSW(unit)
	wDmg = getDmg("W", unit, myHero)
	return unit.health < wDmg and wReady and unit.type == myHero.type and Menu.Misc.KSSettings.KSW
end

function OnProcessSpell(unit, spell)
	--if not unit.isMe and unit.type == myHero.type then
		--SendChat("/all "..spell.name..", DistanceFromMe: "..GetDistance(spell.endPos))
	--end
	
	--[[if (spell.name:find("Attack") ~= nil) and not unit.isMe and unit.type == myHero.type and GetDistance(spell.endPos) < 1 then
		if Menu.MainCombo.WSettings[unit.charName] then
			CastSpell(_W)
		end
	end]]--
	if not unit.isMe and GetDistance(spell.endPos) < 1 then
		SendChat(spell.name.."")
		wDmg = getDmg("W", unit, myHero)
		if (spell.name:find("Attack") ~= nil) and KSW(unit) then
			CastSpell(_W)
		end
		if (spell.name:find("Attack") ~= nil) and wReady and unit.type == myHero.type and Menu.MainCombo.WSettings[unit.charName] then
			CastSpell(_W)
		end
	end
end

function AutoLevel()
	if myHero.level == 2 then
		LevelSpell(levelChart[Menu.Misc.AutoLevel.SkillAt2])
	end
	if myHero.level == 3 then
		LevelSpell(levelChart[Menu.Misc.AutoLevel.SkillAt3])
	end
	if myHero.level == 6 or myHero.level == 11 or myHero.level == 16 then
			LevelSpell(SPELL_4)
	end
end

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST, QRANGE)
  
	vPrd = VPrediction()
	xSOW = SOW(vPrd)
	
	Menu = scriptConfig("Fiora by seoul", "FioraSeoul")
		Menu:addParam("blank", "", SCRIPT_PARAM_INFO, "")
		Menu:addParam("version", "Version 0.08", SCRIPT_PARAM_INFO, "")
		
		
		Menu:addSubMenu("SOW", "xSOW")
    xSOW:LoadToMenu(Menu.xSOW) 
		Menu:addSubMenu("MISC", "Misc")
			Menu.Misc:addSubMenu("Draw", "ToDraw")
				Menu.Misc.ToDraw:addParam("DrawQ", "Draw Q", SCRIPT_PARAM_ONOFF, true)
				Menu.Misc.ToDraw:addParam("DrawR", "Draw R", SCRIPT_PARAM_ONOFF, true)  
			Menu.Misc:addSubMenu("Auto Level", "AutoLevel")
				Menu.Misc.AutoLevel:addParam("SkillAt2", "Level 2", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
				Menu.Misc.AutoLevel:addParam("SkillAt3", "Level 3", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
				Menu.Misc.AutoLevel:addParam("UseAutoLevel", "Use Auto Level", SCRIPT_PARAM_ONOFF, false)
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
		
		for i, enemy in ipairs(GetEnemyHeroes()) do
			Menu.MainCombo.WSettings:addParam(enemy.charName, "  "..enemy.charName, SCRIPT_PARAM_ONOFF, true)
		end
		
		--[[Menu.MainCombo.WSettings:addParam("blank", "", SCRIPT_PARAM_INFO, "")
		Menu.MainCombo.WSettings:addParam("spellblock", "Spells:", SCRIPT_PARAM_INFO, "")
		
		local added = false
		for champ, spell in pairs(parryList) do
			for i, enemy in ipairs(GetEnemyHeroes()) do
				if enemy.charName == champ then
					added = true
					Menu.MainCombo.WSettings:addParam(champ..spell, champ.." - "..spell, SCRIPT_PARAM_ONOFF, true)
				end
			end
		end
		]]--
			Menu.MainCombo:addSubMenu("E Settings", "ESettings")
				Menu.MainCombo.ESettings:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
			Menu.MainCombo:addParam("GodKey", "God Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
			
end

function OnTick()
	if myHero.dead then return end

	ts:update()
	CDHandler()
	
	if Menu.Misc.KSSettings.KSQ then KSQ() end
	if Menu.MainCombo.GodKey then GodMode() end
	if Menu.Misc.AutoLevel.UseAutoLevel then AutoLevel() end
	
end
