if myHero.charName ~= "Fiora" then return end

local qReady, eReady  = false, false
local QRANGE, RRANGE = 600, 400
local levelChart = {SPELL_1, SPELL_2, SPELL_3}
local VP = nil

function CDHandler()
    qReady = (myHero:CanUseSpell(_Q) == READY) 
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
    if GetDistance(ts.target) > 250 and qReady then
       CastSpell(_Q, ts.target)
    end
end

function CastE()
    nextAA = _G.MMA_NextAttackAvailability
			if nextAA > 0.1 and nextAA < 0.2  and eReady then
					CastSpell(_E)
					_G.MMA_ResetAutoAttack()
			end
		
end
        
function KSQ()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        qDmg = getDmg("Q", enemy, myHero)
        if QREADY and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
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

function AutoLevel()
    if player.level == 1 then
        LevelSpell(levelChart[Menu.Misc.AutoLevel.SkillAt1])
    elseif player.level == 2 then
        LevelSpell(levelChart[Menu.Misc.AutoLevel.SkillAt2])
    elseif player.level == 3 then
        LevelSpell(levelChart[Menu.Misc.AutoLevel.SkillAt3])
    elseif player.level == 6 or player.level == 11 or player.level == 16 then
        LevelSpell(SPELL_4)
    end
end

function OnLoad()
    ts = TargetSelector(TARGET_LESS_CAST, QRANGE)
    
    Menu = scriptConfig("Fiora by seoul", "FioraSeoul")
    
		Menu:addParam("blank", "", SCRIPT_PARAM_INFO, "")
		Menu:addParam("version", "Version 0.01", SCRIPT_PARAM_INFO, "")
		
		Menu:addSubMenu("Target Selector", "targetSelector")
			Menu.targetSelector:addTS(ts)
    ts.name = "Focus"
		
		Menu:addSubMenu("MISC", "Misc")
			Menu.Misc:addSubMenu("Draw", "ToDraw")
				Menu.Misc.ToDraw:addParam("DrawQ", "Draw Q", SCRIPT_PARAM_ONOFF, true)
				Menu.Misc.ToDraw:addParam("DrawR", "Draw R", SCRIPT_PARAM_ONOFF, true)  
		
	  Menu.Misc:addSubMenu("Auto Level", "AutoLevel")
      Menu.Misc.AutoLevel:addParam("SkillAt1", "Level 1", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
      Menu.Misc.AutoLevel:addParam("SkillAt2", "Level 2", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
      Menu.Misc.AutoLevel:addParam("SkillAt3", "Level 3", SCRIPT_PARAM_LIST, 1, { "_Q", "_W", "_E"})
      Menu.Misc.AutoLevel:addParam("UseAutoLevel", "Use Auto Level", SCRIPT_PARAM_ONOFF, false)
         	
    Menu:addSubMenu("Combo Settings", "MainCombo")
      Menu.MainCombo:addSubMenu("Q Settings", "QSettings")
				Menu.MainCombo.QSettings:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true) 
      Menu.MainCombo:addSubMenu("E Settings", "ESettings")
        Menu.MainCombo.ESettings:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.MainCombo:addParam("GodKey", "God Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
				
end

function OnTick()
    if myHero.dead then return end
    
		ts:update()
    CDHandler()
    KSQ()
		
		if Menu.MainCombo.GodKey then
        GodMode()
    end
        
    if Menu.Misc.AutoLevel.UseAutoLevel then
            AutoLevel()
    end
end
