--[[
    Fiora The Legspreader by Lillgoalie & ELSN
]]

if myHero.charName ~= "Fiora" then return end

require 'VPrediction'
require 'SOW'

local QREADY, WREADY, EREADY, RREADY  = false, false, false, false
local VP = nil
local qRange = 600
local rRange = 400
local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3} 

local Spots = { 
        { x = 1297, y = 51, z = 8113}
}

function OnLoad()
    VP = VPrediction()
    ts = TargetSelector(TARGET_LESS_CAST, qRange)
    Orbwalker = SOW(VP)
    SendChat("cussss")
    Menu = scriptConfig("Fiora Seoul", "FioraTLS")
    Menu:addParam("autocarry", "GOD MODE", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		
    Menu:addSubMenu("["..myHero.charName.." - Target Selector]", "targetSelector")
    Menu.targetSelector:addTS(ts)
    ts.name = "Focus"
           
    Menu:addSubMenu("Drawings", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		
		--PrintChat("cussss")
		
		if _G.MMA_NextAttackAvailability==1 then
			SendChat("oi")
		end
		--PrintChat("<font color = \"#33CCCC\">Fiora The Legspreader by</font> <font color = \"#fff8e7\">Lillgoalie</font> <font color = \"#33CCCC\">&</font> <font color = \"#fff8e7\">ELSN</font>")
end

function OnTick()
    if myHero.dead then return end
    ts:update()
    CDHandler()
		
    if Menu.autocarry then
        ComboMode()
    end
end

function AutoLevel()
    local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
    if qL + wL + eL + rL < player.level then
        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
        local level = { 0, 0, 0, 0 }
        for i = 1, player.level, 1 do
            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
        end
        for i, v in ipairs({ qL, wL, eL, rL }) do
        if v < level[i] then LevelSpell(spellSlot[i]) end
        end
    end
end

function CDHandler()
    QREADY = (myHero:CanUseSpell(_Q) == READY) 
    WREADY = (myHero:CanUseSpell(_W) == READY)
    EREADY = (myHero:CanUseSpell(_E) == READY)
    RREADY = (myHero:CanUseSpell(_R) == READY)
end
    
function ComboMode() 
    if _G.MMA_GetTarget(600) ~= nil then
        Qcast() 
    end
      
    if _G.MMA_GetTarget(200) ~= nil then
        Ecast()
    end
end 

function Qcast()
    if GetDistance(_G.MMA_Target) > 270 and QREADY then
        CastSpell(_Q, _G.MMA_Target)
    end
end

function Ecast()
    if EREADY then
        if _G.MMA_NextAttackAvailability<0.5 then
					CastSpell(_E)
					_G.MMA_ResetAutoAttack()
				end
    end
end

function Rcast()
    CastSpell(_R, ts.target)
end

-- Credit HeX for AutoParry
function OnProcessSpell(unit, spell)
    
        if unit ~= nil and unit.type == "obj_AI_Hero" and GetDistance(spell.endPos) <= 50 and unit.team ~= myHero.team and not unit.isMe then
            for i=1, #Abilities do
                if (spell.name == Abilities[i] or spell.name:find(Abilities[i]) ~= nil) then
                    if WREADY and (getDmg("AD", myHero, unit) >= (myHero.maxHealth*0.06) or getDmg("AD", myHero, unit) >= (myHero.health*0.04)) then
                        CastSpell(_W)
                    else
                        if WREADY then
                            CastSpell(_W)
                        end
                    end
                end
            end
        end
    end


Abilities = {
"GarenSlash2", "SiphoningStrikeAttack", "LeonaShieldOfDaybreakAttack", "RenektonExecute", "ShyvanaDoubleAttackHit", "DariusNoxianTacticsONHAttack", "TalonNoxianDiplomacyAttack", "Parley", "MissFortuneRicochetShot", "RicochetAttack", "jaxrelentlessattack", "Attack"
}

function ManaCheck(unit, ManaValue)
    if unit.mana > (unit.maxMana * (ManaValue/100))
        then return true
    else
        return false
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
        
function KSR()
    for i, enemy in ipairs(GetEnemyHeroes()) do
        rDmg = getDmg("R", enemy, myHero)
                
        if RREADY and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < rDmg then
            CastSpell(_R, enemy)
        end
    end
end

-- Credit Feez for isFacing
function isFacing(source, target, lineLength)
    local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
    local sourcePos = Vector(source.x, source.z)
    sourceVector = (sourceVector-sourcePos):normalized()
    sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
    return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

function OnDraw()
    if Menu.drawings.drawCircleAA then
        DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(0, 0, 0, 0))
    end

    if Menu.drawings.drawCircleQ then
        DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x111111)
    end
  
    if Menu.drawings.drawCircleR then
        DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x111111)
    end
  
end
