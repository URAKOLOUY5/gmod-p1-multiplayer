AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

AccessorFunc( ENT, "CoreType", "CoreType" )

CoreType = 0

curiositySound = 1
curiositySoundDelay = 1

crazySound = 1
crazySoundDelay = 4.7
crazySoundStartWith = "Portal.Glados_core.Crazy_0"

agressiveSound = 0
agressiveSoundDelay = 1.22
agressiveSoundStartWith = "Portal.Glados_core.Aggressive_0"

function ENT:KeyValue( key, value )	
	if key == "CoreType" then
		CoreType = value
	end
	
	if ( string.Left( key, 2 ) == "On" ) then
		self:StoreOutput( key, value )
	end	
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
		
	ent:Spawn()
	ent:Activate()
		
	return ent
	
end

function ENT:Initialize()
	self:SetModel( "models/props_bts/glados_ball_reference.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetNWBool( "isWoke", false )
	
	if CoreType == "0" then
		self:SetSkin(1)
		//self.Entity:ResetSequence("look_02")
	elseif CoreType == "1" then
		self:SetSkin(2)
		//self.Entity:ResetSequence("look_03")		
	elseif CoreType == "2" then
		self:SetSkin(3)
		//self.Entity:ResetSequence("look_04")		
	else
		self:SetSkin(4)
		//self.Entity:ResetSequence("turn")		
	end

	if self:GetSkin() ~= 2 then
		self:GetPhysicsObject():Wake()
	end
	
	local phys = self:GetPhysicsObject()
end

function ENT:OnRemove()
end

 
function ENT:Use( activator, caller )
	//return
end
 
function ENT:Think()
	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.
	//return true -- Apply NextThink call

	if (self:IsPlayerHolding()) then
		self:SetNWBool( "isWoke", true )
	end
	
	if self:IsPlayerHolding() then
		self:TriggerOutput("OnPlayerPickup")
	end
	
	if self:GetPhysicsObject():IsMotionEnabled() then
		self:TriggerOutput("OnMotionEnabled")
	end

	if (self:WaterLevel() > 0) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 10)
		local effectdata = EffectData()
	
		effectdata:SetOrigin( self.Entity:GetPos() )

 		util.Effect( "Explosion", effectdata, true, true )
		self.Entity:Remove()
	end
	
	-- if !(self:GetNWBool( "isWoke" )) then
		-- curiositySound = 1
		-- curiositySoundDelay = 1

		-- crazySound = 1
		-- crazySoundDelay = 4.7
		-- crazySoundStartWith = "Portal.Glados_core.Crazy_0"
		
		-- agressiveSound = 0
		-- agressiveSoundDelay = 1.22
		-- agressiveSoundStartWith = "Portal.Glados_core.Aggressive_0"		
	-- end	

	if (self:GetNWBool( "isWoke" )) then
		if self:GetSkin() == 1 then
			self.Entity:ResetSequence("look_02")
			
			if not timer.Exists("PlayCuriosityLines" .. self:EntIndex()) then
				timer.Create(
					"PlayCuriosityLines" .. self:EntIndex(),
					curiositySoundDelay,
					1,
					function()
					end
				)
				curiositySoundFull = "Portal.Glados_core.Curiosity_" .. curiositySound 
				self:EmitSound(curiositySoundFull)
				curiositySound = curiositySound + 1		
				-- Yandere dev moment
				if (curiositySoundFull == "Portal.Glados_core.Curiosity_1") then
					curiositySoundDelay = 1.5
				end

				if (curiositySoundFull == "Portal.Glados_core.Curiosity_5") then
					curiositySoundDelay = 2
				end
				
				if (curiositySoundFull == "Portal.Glados_core.Curiosity_8") then
					curiositySoundDelay = 1
				end			
				
				if (curiositySoundFull == "Portal.Glados_core.Curiosity_10") then
					curiositySoundDelay = 3
				end
				
				if (curiositySoundFull == "Portal.Glados_core.Curiosity_11") then
					curiositySoundDelay = 1
				end

				if (curiositySoundFull == "Portal.Glados_core.Curiosity_13") then
					curiositySoundDelay = 2				
					curiositySound = 15
				end
				
				if (curiositySoundFull == "Portal.Glados_core.Curiosity_16") then
					curiositySoundDelay = 2
				end			

				if (curiositySoundFull == "Portal.Glados_core.Curiosity_17") then
					curiositySoundDelay = 4
					curiositySound = 1
				end
				
				--print("Curret Delay for Curiosity Core : " .. curiositySoundDelay)
				--print("Curret Sound for Curiosity Core : " .. curiositySoundFull)
			end
		end
		
		if self:GetSkin() == 3 then
			self.Entity:ResetSequence("look_04")
			
			if not timer.Exists("PlayCrazyLines" .. self:EntIndex()) then
				timer.Create(
					"PlayCrazyLines" .. self:EntIndex(),
					crazySoundDelay,
					1,
					function()
					end
				)
				crazySoundFull = crazySoundStartWith .. crazySound 
				self:EmitSound(crazySoundFull)
				crazySound = crazySound + 1		
				-- Yandere dev moment

				if (crazySoundFull == "Portal.Glados_core.Crazy_01") then
					crazySoundDelay = 4
				end
				
				if (crazySoundFull == "Portal.Glados_core.Crazy_02") then
					crazySoundDelay = 2.64
				end			

				if (crazySoundFull == "Portal.Glados_core.Crazy_03") then
					crazySoundDelay = 4.23
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_04") then
					crazySoundDelay = 2.89
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_05") then
					crazySoundDelay = 3.48
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_06") then
					crazySoundDelay = 2
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_07") then
					crazySoundDelay = 2.48
				end
				
				if (crazySoundFull == "Portal.Glados_core.Crazy_08") then
					crazySoundDelay = 1.25
				end			
				
				if (crazySoundFull == "Portal.Glados_core.Crazy_09") then
					crazySoundStartWith = "Portal.Glados_core.Crazy_"
					crazySoundDelay = 1.28
				end			

				if (crazySoundFull == "Portal.Glados_core.Crazy_10") then
					crazySoundDelay = 1.76
				end
				
				if (crazySoundFull == "Portal.Glados_core.Crazy_11") then
					crazySoundDelay = 1.4
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_12") then
					crazySoundDelay = 1.88
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_13") then
					crazySoundDelay = 2.14
				end
				
				if (crazySoundFull == "Portal.Glados_core.Crazy_14") then
					crazySoundDelay = 5.9
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_15") then
					crazySoundDelay = 4.53
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_16") then
					crazySoundDelay = 1.7
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_17") then
					crazySoundDelay = 1.58
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_18") then
					crazySoundDelay = 3.16
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_19") then
					crazySoundDelay = 2.28
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_20") then
					crazySoundDelay = 3.25
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_21") then
					crazySoundDelay = 1.63
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_22") then
					crazySoundDelay = 3.72
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_23") then
					crazySoundDelay = 2.07
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_24") then
					crazySoundDelay = 4.61
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_25") then
					crazySoundDelay = 2.46
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_26") then
					crazySoundDelay = 3.15
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_27") then
					crazySoundDelay = 3.3
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_28") then
					crazySoundDelay = 4
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_29") then
					crazySoundDelay = 3.44
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_30") then
					crazySoundDelay = 1.8
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_31") then
					crazySoundDelay = 5.16
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_32") then
					crazySoundDelay = 3
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_33") then
					crazySoundDelay = 3
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_34") then
					crazySoundDelay = 3
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_35") then
					crazySoundDelay = 3
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_36") then
					crazySoundDelay = 2.04
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_37") then
					crazySoundDelay = 1.8
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_38") then
					crazySoundDelay = 1.29
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_39") then
					crazySoundDelay = 7.57
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_40") then
					crazySoundDelay = 3.66
				end

				if (crazySoundFull == "Portal.Glados_core.Crazy_41") then
					crazySoundStartWith = "Portal.Glados_core.Crazy_0"
					crazySoundDelay = 4.7
					crazySound = 1
				end
				--print("Curret Delay for Crazy Core : " .. crazySoundDelay)
				--print("Curret Sound for Crazy Core : " .. crazySoundFull)
			end
		end
		
		if self:GetSkin() == 2 then
			self.Entity:ResetSequence("look_03")
			
			if not timer.Exists("PlayAgressiveSounds" .. self:EntIndex()) then
				timer.Create(
					"PlayAgressiveSounds" .. self:EntIndex(),
					agressiveSoundDelay,
					1,
					function()
					end
				)						
				agressiveSoundFull = agressiveSoundStartWith .. agressiveSound 
				self:EmitSound(agressiveSoundFull)
				agressiveSound = agressiveSound + 1
				
				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_00") then
					agressiveSoundDelay = 1.54
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_01") then
					agressiveSoundDelay = 0.9
				end
				
				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_02") then
					agressiveSoundDelay = 1.03
				end
				
				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_03") then
					agressiveSoundDelay = 0.62
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_04") then
					agressiveSoundDelay = 1.09
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_05") then
					agressiveSoundDelay = 0.93
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_06") then
					agressiveSoundDelay = 0.65
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_07") then
					agressiveSoundDelay = 1
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_08") then
					agressiveSoundDelay = 0.60
				end
				
				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_09") then
					agressiveSoundStartWith = "Portal.Glados_core.Aggressive_"
					agressiveSoundDelay = 0.81
				end				

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_10") then
					agressiveSoundDelay = 1.14
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_11") then
					agressiveSoundDelay = 0.83
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_12") then
					agressiveSoundDelay = 0.54
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_13") then
					agressiveSoundDelay = 1.37
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_14") then
					agressiveSoundDelay = 0.81
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_15") then
					agressiveSoundDelay = 0.78
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_16") then
					agressiveSoundDelay = 0.77
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_17") then
					agressiveSoundDelay = 0.69
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_18") then
					agressiveSoundDelay = 0.87
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_19") then
					agressiveSoundDelay = 1.04
				end
				
				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_20") then
					agressiveSoundDelay = 0.8
				end

				if (agressiveSoundFull == "Portal.Glados_core.Aggressive_20") then
					agressiveSound = 0
					agressiveSoundDelay = 1.22
					agressiveSoundStartWith = "Portal.Glados_core.Aggressive_0"
				end
				
				--print("Curret Delay for Aggressive Core : " .. agressiveSoundDelay)
				--print("Curret Sound for Aggressive Core : " .. agressiveSoundFull)				
			end
		end
	end
	return true
end	

function ENT:AcceptInput(name)
	if (name == "Panic") then
		if self:GetSkin() == 1 or self:GetSkin() == 3 then
			self:EmitSound("Portal.Glados_core.Curiosity_18")		
		elseif self:GetSkin() == 2 then
			self:EmitSound("Portal.Glados_core.Aggressive_panic_0" .. math.Rand(1,2))
		end
	end		
end