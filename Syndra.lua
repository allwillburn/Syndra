local ver = "0.17"


if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end


if GetObjectName(GetMyHero()) ~= "Syndra" then return end


require("DamageLib")
require("Deftlib")
require("OpenPredict")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Syndra/master/Syndra.lua', SCRIPT_PATH .. 'Syndra.lua', function() PrintChat('<font color = "#00FFFF"> Syndra Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Syndra/master/Syndra.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local SyndraQ = {delay = .0, range = 800, width = 50, speed = 1500}
 
local SyndraMenu = Menu("Syndra", "Syndra")

SyndraMenu:SubMenu("Combo", "Combo")

SyndraMenu.Combo:Boolean("Q", "Use Q in combo", true)
SyndraMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
SyndraMenu.Combo:Boolean("W", "Use W in combo", true)
SyndraMenu.Combo:Boolean("E", "Use E in combo", true)
SyndraMenu.Combo:Boolean("R", "Use R in combo", true)
SyndraMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)




SyndraMenu:SubMenu("AutoMode", "AutoMode")
SyndraMenu.AutoMode:Boolean("Level", "Auto level spells", false)
SyndraMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
SyndraMenu.AutoMode:Boolean("Q", "Auto Q", false)
SyndraMenu.AutoMode:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
SyndraMenu.AutoMode:Boolean("W", "Auto W", false)
SyndraMenu.AutoMode:Boolean("E", "Auto E", false)
SyndraMenu.AutoMode:Boolean("R", "Auto R", false)

SyndraMenu:SubMenu("LaneClear", "LaneClear")
SyndraMenu.LaneClear:Boolean("Q", "Use Q", true)
SyndraMenu.LaneClear:Boolean("W", "Use W", true)
SyndraMenu.LaneClear:Boolean("E", "Use E", true)


SyndraMenu:SubMenu("Harass", "Harass")
SyndraMenu.Harass:Boolean("Q", "Use Q", true)
SyndraMenu.Harass:Boolean("W", "Use W", true)

SyndraMenu:SubMenu("KillSteal", "KillSteal")
SyndraMenu.KillSteal:Boolean("Q", "KS w Q", true)
SyndraMenu.KillSteal:Boolean("W", "KS w W", true)
SyndraMenu.KillSteal:Boolean("E", "KS w E", true)
SyndraMenu.KillSteal:Boolean("R", "KS w R", true)

SyndraMenu:SubMenu("AutoFarm", "AutoFarm")
SyndraMenu.AutoFarm:Boolean("Q", "Auto Q", false)
SyndraMenu.Farm:Boolean("AA", "AutoAA", true)

SyndraMenu:SubMenu("AutoIgnite", "AutoIgnite")
SyndraMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

SyndraMenu:SubMenu("Drawings", "Drawings")
SyndraMenu.Drawings:Boolean("DQ", "Draw Q Range", true)

SyndraMenu:SubMenu("SkinChanger", "SkinChanger")
SyndraMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
SyndraMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()
        local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
        local Gunblade = GetItemSlot(myHero, 3146)
        local BOTRK = GetItemSlot(myHero, 3153)
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)
        local SyndraQ = {delay = .0, range = 800, width = 50, speed = 1500}
		Balls = {}
		
	

	--AUTO LEVEL UP
	if SyndraMenu.AutoMode.Level:Value() then

			spellorder = {_E, _W, _Q, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
          if Mix:Mode() == "Harass" then
          
           if SyndraMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 925) then
				CastTargetSpell(target, _W)
            end 
                    
            if SyndraMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 800) then
				if target ~= nil then 
                                      CastTargetSpell(target, _Q)
                                end
            end          
          end

	--COMBO
	  if Mix:Mode() == "Combo" then
    
            
			 if SyndraMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 800) then
                local QPred = GetPrediction(target,SyndraQ)
                       if QPred.hitChance > (SyndraMenu.Combo.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
                end
			if SyndraMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 700) then
			 CastSkillShot(_E, target)
	    end
             
    
            if SyndraMenu.Combo.W:Value() and ValidTarget(target, 925) then        
           for _,Ball in pairs(Balls) do
            if GetDistance(Ball) <= 925 then
            CastSkillShot(_W,GetOrigin(Ball))
            end
          end	  
          for i,mobs in pairs(minionManager.objects) do
	    if GetDistance(mobs) <= 925 then
	    CastSkillShot(_W,GetOrigin(mobs))
	    end
	  end
end
              
		if SyndraMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 800) then
		     if target ~= nil then 
                         CastTargetSpell(target, _Q)
                     end
            end	
            	
             	   	    
            if SyndraMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 675) and (EnemiesAround(myHeroPos(), 675) >= SyndraMenu.Combo.RX:Value()) then
			CastTargetSpell(target, _R)
            end

          end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 800) and SyndraMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         if target ~= nil then 
                                      CastTargetSpell(target, _Q)
		         end
                end 
			
		if IsReady(_W) and ValidTarget(enemy, 925) and SyndraMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("W",enemy) then
		                      CastTargetSpell(target, _W)
  
                end

                if IsReady(_E) and ValidTarget(enemy, 700) and SyndraMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastSkillShot(_E, target)
  
                end
			
		if IsReady(_R) and ValidTarget(enemy, 675) and SyndraMenu.KillSteal.R:Value() and GetHP(enemy) < getdmg("R",enemy) then
		                      CastTargetSpell(target, _R)
  
                end	
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if SyndraMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 800) then
	        	CastTargetSpell(closeminion, _Q)
                end

                if SyndraMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 925) then
	        	CastTargetSpell(closeminion,_W)
	        end

                if SyndraMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 700) then
	        	 CastSkillShot(_E, closeminion)
	        end

               
	
		
          end
      end
        --AutoMode
         	 if SyndraMenu.AutoMode.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
                local QPred = GetPrediction(target,SyndraQ)
                       if QPred.hitChance > (SyndraMenu.AutoMode.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q,QPred.castPos)
                       end
                end
        if SyndraMenu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 925) then
	  	      CastTargetSpell(target, _W)
          end
        end
        if SyndraMenu.AutoMode.E:Value() then        
	  if Ready(_E) and ValidTarget(target, 700) then
		      CastSkillShot(_E, target)
	  end
        end
        if SyndraMenu.AutoMode.R:Value() then        
	  if Ready(_R) and ValidTarget(target, 675) then
		      CastTargetSpell(target, _R)
	  end
        end
		
		--Auto on minions
          for _, minion in pairs(minionManager.objects) do
      			
      			   	
              if SyndraMenu.AutoFarm.Q:Value() and Ready(_Q) and ValidTarget(minion, 800) and GetCurrentHP(minion) < CalcDamage(myHero,minion,QDmg,Q) then
                  CastTargetSpell(minion, _Q)
              end
			
		if SyndraMenu.Farm.AA:Value() and ValidTarget(minion, 500) and GetCurrentHP(minion) < CalcDamage(myHero,minion,AADmg,AA) then
            AttackUnit(minion)
        end		
	end		
		
                
	--AUTO GHOST
	if SyndraMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if SyndraMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 800, 0, 200, GoS.Black)
	end

end)




local function SkinChanger()
	if SyndraMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Syndra</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')





