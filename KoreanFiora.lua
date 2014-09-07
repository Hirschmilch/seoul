if myHero.charName ~= "Fiora" then return end

local version = 1.00
local AUTOUPDATE = true
local SCRIPT_NAME = "KoreanFiora"
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DONLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/seoul1/seoul/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/seoul1/seoul/master/version/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
RequireI:Add("vPrediction","https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end
local qReady, wReady, eReady, rReady, flashReady  = false, false, false, false, false
local QRANGE, RRANGE, FLASH = 600, 400, nil
local lastSkin = 4

wList =	{
	["Renekton"] = "RenektonExecute",
	["MissFortune"] = "MissFortuneRicochetShot",
	["Leona"] = "LeonaShieldOfDaybreakAttack",
	["Garen"] = "GarenSlash2",
	["Nasus"] = "NasusQAttack",
	["Shyvana"] = "ShyvanaDoubleAttackHit",
	["Darius"] = "DariusNoxianTacticsONHAttack",
	["Gangplank"] = "Parley",
	["Sivir"] = "RicochetAttack",
	["Talon"] = "TalonNoxianDiplomacyAttack",
	["Jax"] = "jaxrelentlessattack"
		}
rList = {
	["Amumu"] = "CurseoftheSadMummy",
	["Annie"] = "InfernalGuardian",
	--["LeeSin"] = "BlindMonkRKick",
	["Sona"] = "SonaR",
	["Syndra"] = "syndrar",
	["Veigar"] = "VeigarPrimordialBurst",
	--["Brand"] = "Pyroclasm",
	--["Malzahar"] = "NetherGrasp",
	["Malphite"] = "UFSlash",
	["Vi"] = "ViR"
	}
Items = {
		Hydra  = {id = 3074, Range = 350, Ready = false},
		Tiamat = {id = 3077, Range = 350, Ready = false},
		Ygb = {id = 3142, Ready = false},
		Botrk = {id = 3153, Range = 450, Ready = false}
	}
function OnTickCheck()
	qReady =  myHero:CanUseSpell(_Q) == READY
	wReady =  myHero:CanUseSpell(_W) == READY
	eReady =  myHero:CanUseSpell(_E) == READY
	rReady =  myHero:CanUseSpell(_R) == READY
	Items.Hydra.Ready = GetInventoryItemIsCastable(Items.Hydra.id)
	Items.Tiamat.Ready = GetInventoryItemIsCastable(Items.Tiamat.id)
	Items.Ygb.Ready = GetInventoryItemIsCastable(Items.Ygb.id)
	Items.Botrk.Ready = GetInventoryItemIsCastable(Items.Botrk.id)
	flashReady = FLASH and myHero:CanUseSpell(FLASH) == READY or false
end
  
function GodMode() 
	if Menu.Combo.QSet.Q and ts.target ~= nil and ValidTarget(ts.target, 600) then
		CastQ() 
	end
	if Menu.Combo.ESet.Mode == 3 and ts.target ~= nil and ValidTarget(ts.target, 250) then
		CastE()
	end
end 

function SeoulTarget()
	if Menu.Misc.Lock and GetTarget() ~= nil then
		return GetTarget()
	else
		return ts.target
	end
end

function CastQ()
	if GetDistance(SeoulTarget()) > Menu.Combo.QSet.QBuffer and qReady then
		if VIP_USER and Menu.Misc.Vip.Packet then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = SeoulTarget().networkID}):send()
		else
			CastSpell(_Q, SeoulTarget())
		end
	end
end

function CastE()
	if eReady then
		if VIP_USER and Menu.Misc.Vip.Packet then
			Packet("S_CAST", {spellId = _E}):send()
		else
			CastSpell(_E)
		end
	end
end

function CastW()
	if VIP_USER and Menu.Misc.Vip.Packet then
		Packet("S_CAST", {spellId = _W}):send()
	else
		CastSpell(_W)
	end
end

function CastR()
	if VIP_USER and Menu.Misc.Vip.Packet then
		Packet("S_CAST", {spellId = _R, targetNetworkId = ts.target.networkID}):send()
	else
		CastSpell(_R, ts.target)
	end
end

function AfterAttack()
	if Menu.Combo.Key and Menu.Combo.ESet.Mode == 2 and ts.target ~= nil and ValidTarget(ts.target, 250) then
		CastE()
	end
	if Items.Hydra.Ready and Menu.Misc.Item.Hydra then
		CastItem(Items.Hydra.id)
	elseif Items.Tiamat.Ready and Menu.Misc.Item.Tiamat then
		CastItem(Items.Tiamat.id)
	end
end

function OnAttack()
	if Items.Ygb.Ready and Menu.Misc.Item.Ygb then
		CastItem(Items.Ygb.id)
	end
	if Items.Botrk.Ready and Menu.Misc.Item.Botrk and ValidTarget(SeoulTarget(), Items.Botrk.Range) then
		CastItem(Items.Botrk.id, SeoulTarget())
	end
end

function KsQ()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		if qReady and enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
			if VIP_USER and Menu.Misc.Vip.Packet then
				Packet("S_CAST", {spellId = _Q, targetNetworkId = ts.target.networkId}):send()
			else
				CastSpell(_Q, ts.target)
			end
		end
	end
end

function KsW(unit)
	wDmg = getDmg("W", unit, myHero)
	return unit.health < wDmg and wReady and unit.type == myHero.type and Menu.Misc.Ks.W
end

function GetFlash()
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") then
		FLASH = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") then
		FLASH = SUMMONER_2
	else
		FLASH = nil
	end
end

function PredictAmumu(unit, spell)
	if GetDistance(unit) < 600 and not flashReady then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictAnnie(unit, spell)
	if ((Menu.Combo.RSet.Flash and not flashReady) or not Menu.Combo.RSet.Flash) then
		if GetDistance(spell.endPos) < 270 and not flashReady then 
			ts.range = 400
			ts:update()
			if ts.target ~= nil and ValidTarget(ts.target, 400) then
				CastR()
			end
			ts.range = 600
		end
	end
end

function PredictBrand(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictLeeSin(unit,spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictMalphite(unit, spell)
	if ((Menu.Combo.RSet.Flash and not flashReady) or not Menu.Combo.RSet.Flash) then
		if GetDistance(spell.endPos) < 270 then
			ts.range = 400
			ts:update()
			if ts.target ~= nil and ValidTarget(ts.target, 400) then
				CastR()
			end
			ts.range = 600
		end
	end
end

function PredictMalzahar(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictSona(unit, spell)
	if ((Menu.Combo.RSet.Flash and not flashReady) or not Menu.Combo.RSet.Flash) then
		local myX = myHero.visionPos.x
		local myZ = myHero.visionPos.z

		local sonaX = unit.visionPos.x
		local sonaZ = unit.visionPos.z

		local spellX = spell.endPos.x
		local spellZ = spell.endPos.z

		local distance = math.abs((myZ-sonaZ)*(sonaX-spellX)-(myX-sonaX)*(sonaZ-spellZ))/math.sqrt((myX-sonaX)*(myX-sonaX)+(myZ-sonaZ)*(myZ-sonaZ))
	
		if distance < 132.5 and (GetDistance(unit) < 1000 and GetDistance(spell.endPos) < 1000) then
			ts.range = 400
			ts:update()
			if ts.target ~= nil and ValidTarget(ts.target) then
				CastR()
			end
			ts.range = 600
		end
	end
end

function PredictSyndra(unit, spell)
	if GetDistance(spell.endPos) < 1 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictVeigar(unit, spell)
	if GetDistance(spell.endPos) < 1 then 
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function PredictVi(unit, spell)
	if GetDistance(spell.endPos) < 1000 then
		ts.range = 400
		ts:update()
		if ts.target ~= nil and ValidTarget(ts.target, 400) then
			CastR()
		end
		ts.range = 600
	end
end

function WPrediction(unit, spell)
	if wReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 50 and Menu.Combo.WSet["w"..unit.charName] and wList[unit.charName] ~= nil and (spell.name:find(wList[unit.charName]) ~= nil) then
		CastW()
	end
end

function RPrediction(unit, spell)
	if rReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 1000 and Menu.Combo.RSet[unit.charName] and rList[unit.charName] ~= nil and (spell.name:find(rList[unit.charName]) ~= nil) then
		_ENV["Predict"..unit.charName](unit, spell)
	end
end

function AAPrediction(unit, spell)
	if wReady and not unit.isMe and unit.type == myHero.type and unit.team ~= myHero.team and GetDistance(spell.endPos) < 10 and (Menu.Combo.WSet["aa"..unit.charName] or KsW(unit)) and (spell.name:find("Attack") ~= nil) then
		CastW()
	end
end

function OnProcessSpell(unit, spell)
	RPrediction(unit, spell)
	WPrediction(unit, spell)
	AAPrediction(unit, spell)
end

function Menu()
	Menu = scriptConfig("Fiora by seoul", "FioraSeoul")
	
	Menu:addParam("blank", "", SCRIPT_PARAM_INFO, "")
	Menu:addParam("version", "Version 1.00", SCRIPT_PARAM_INFO, "")
	
	Menu:addSubMenu("Orbwalker", "sow1")
  sow:LoadToMenu(Menu.sow1) 
	
	Menu:addSubMenu("Misc", "Misc")
	Menu.Misc:addSubMenu("Draw", "Draw")
	Menu.Misc.Draw:addParam("Q", "Draw Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Draw:addParam("R", "Draw R", SCRIPT_PARAM_ONOFF, true)  
	Menu.Misc:addSubMenu("Kill Steal", "Ks")
	Menu.Misc.Ks:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Ks:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc:addSubMenu("Items", "Item")
	Menu.Misc.Item:addParam("Hydra", "Hydra", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Item:addParam("Tiamat", "Tiamat", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Item:addParam("Ygb", "Youmuu's Ghostblade", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Item:addParam("Botrk", "Blade of the ruined King", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc:addSubMenu("VIP", "Vip")
	Menu.Misc.Vip:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	Menu.Misc.Vip:addParam("Skin", "Skin changer", SCRIPT_PARAM_ONOFF, false)
	Menu.Misc.Vip:addParam("Select", "Select Skin", SCRIPT_PARAM_SLICE, 4, 1, 4)
	if VIP_USER and Menu.Misc.Vip.Skin then
		GenModelPacket("Fiora", Menu.Misc.Vip.Select)
		lastSkin = Menu.Misc.Vip.Select
	end
				
	Menu:addSubMenu("Target Selector", "Ts")
	Menu.Ts:addTS(ts)
	ts.name = "Focus"
	
	Menu:addSubMenu("Combo Settings", "Combo")
	Menu.Combo:addSubMenu("Q Settings", "QSet")
	Menu.Combo.QSet:addParam("QBuffer", "Q Buffer", SCRIPT_PARAM_SLICE, 325, 0, 600, 0)
	Menu.Combo.QSet:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true) 
	Menu.Combo:addSubMenu("W Settings", "WSet")
	Menu.Combo.WSet:addParam("basic", "Basic Attacks:", SCRIPT_PARAM_INFO, "")
	
	local aaPredict = false
	for i, enemy in ipairs(GetEnemyHeroes()) do
		Menu.Combo.WSet:addParam("aa"..enemy.charName, "_"..enemy.charName, SCRIPT_PARAM_ONOFF, true)
		aaPredict = true
	end
	if not aaPredict then
		Menu.Combo.WSet:addParam("aaNotSupported","Not Supported", SCRIPT_PARAM_INFO, "")
	end

	Menu.Combo.WSet:addParam("blank", "", SCRIPT_PARAM_INFO, "")
	Menu.Combo.WSet:addParam("spell", "Spells:", SCRIPT_PARAM_INFO, "")
	
	local wPredict = false
	for champ, spell in pairs(wList) do
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if enemy.charName == champ then
				Menu.Combo.WSet:addParam("w"..enemy.charName, enemy.charName.." - "..spell, SCRIPT_PARAM_ONOFF, true)
				wPredict = true
			end
		end
	end
	if not wPredict then
		Menu.Combo.WSet:addParam("wNotSupported","Not Supported", SCRIPT_PARAM_INFO, "")
	end

	Menu.Combo:addSubMenu("E Settings", "ESet")
	Menu.Combo.ESet:addParam("Mode", "E Mode", SCRIPT_PARAM_LIST, 2, {"Never", "After AA", "Always"})
	Menu.Combo:addSubMenu("R Settings", "RSet")
	Menu.Combo.RSet:addParam("dodge", "Dodge:", SCRIPT_PARAM_INFO, "")

	local rPredict = false
	for champ, spell in pairs(rList) do
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
	Menu.Combo.RSet:addParam("blank", "If flash is up:", SCRIPT_PARAM_INFO, "")
	Menu.Combo.RSet:addParam("Flash", "Don't dodge AOE spells", SCRIPT_PARAM_ONOFF, true)
	
	Menu.Combo:addParam("Lock", "Attack selected target", SCRIPT_PARAM_ONOFF, true)
	Menu.Combo:addParam("Key", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
end

function Skin()
	if Menu.Misc.Vip.Select ~= lastSkin and VIP_USER and Menu.Misc.Vip.Skin then
		GenModelPacket("Fiora", Menu.Misc.Vip.Select)
		lastSkin = Menu.Misc.Vip.Select
	end
end

-- Change skin function, made by Shalzuth
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
		DrawCircle(myHero.x, myHero.y, myHero.z, QRANGE, 0x111111)
	end
  
	if Menu.Misc.Draw.R then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRANGE, 0x111111)
	end
end

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST, QRANGE)
	vp = VPrediction()		
	sow = SOW(vp)
	sow:RegisterAfterAttackCallback(AfterAttack)
	sow:RegisterOnAttackCallback(OnAttack)
	Menu()
end

function OnTick()
	if myHero.dead then return end
	ts:update()
	if Menu.Combo.Lock then sow:ForceTarget(GetTarget()) end
	OnTickCheck()
	if Menu.Misc.Ks.Q then KsQ() end
	if Menu.Combo.Key then GodMode() end
	Skin()
end
