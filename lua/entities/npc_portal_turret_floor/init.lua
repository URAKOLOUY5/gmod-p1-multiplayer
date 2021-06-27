AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')

local numOfTurrets = 0
local keyvalueTable = {}

function ENT:Initialize()
	self.BaseClass.Initialize()
	-- Make this object solid, so it can be manipulated when turret spawning fails
	--self:SetMoveType( MOVETYPE_VPHYSICS )
	--self:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetNoDraw(false)
	self.Entity:DrawShadow(false)

	--rotate turret if spawned manually
	if(self.Entity:GetModel() == "models/error.mdl") then
		self.Entity:SetPlayerSpawn(false)

		if(IsMounted(400)) then --if portal is mounted
			self.Entity:SetModel("models/props/turret_01.mdl") --set model to Portal 1 turret.
		end

	else	--if we were spawned via the spawn menu (we have a valid model, so this must be true)

		self.Entity:SetPlayerSpawn(true)

		--rotate turret spawner 180 degrees, so it faces away from the player.
		local SpawnAng = self.Entity:GetAngles()	
		SpawnAng.p = 0
		SpawnAng.y = SpawnAng.y + 180
		self.Entity:SetAngles(SpawnAng)
	end
	
	numOfTurrets = numOfTurrets + 1
	self.Entity:SetTurretNum(numOfTurrets)
	self.Entity:SetFirstFrame(true)
	self.Entity:SetFireDetected(false)
end

--This prints the current MapID of this entity and resets it's failcount so it can attempt to spawn again.
function ENT:Use( ply )
	print(self.Entity:MapCreationID().." also lel")
	failCount = 0
	return
end

--This function sets up variables.
function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "TurretNum" )
	self:NetworkVar( "Entity", 0, "SpawnedTurret" )
	self:NetworkVar( "Entity", 1, "Laser" )
	self:NetworkVar("Bool", 0, "FirstFrame")
	self:NetworkVar("Bool", 1, "PlayerSpawn")
	self:NetworkVar("Bool", 2, "FireDetected")
	self:NetworkVar("Bool", 3, "IsTipped")
	self:NetworkVar("Bool", 4, "IsKnocked") --when a turret is knocked over before OnTipped is called. When turrets say "woah!" or "ow ow ow ow ow!"
	self:NetworkVar("Bool", 5, "IsActor") -- a key flag that disables the turret permenantly. Is taken from Portal 2, increasing compatibility.
	self:NetworkVar("Bool", 6, "Defective") -- this flag will make a turret act like it's defective when true. Not in Portal 2 at all, but removes hardcoded garbage.
	self:NetworkVar("Bool", 7, "Oracle") -- this flag will make a turret say the Oracle turret lines every once in a while. Not in Portal 2, only used to flag our oracle turret.

end

--This accepts inputs. Recieves feedback from the spawned turret, and acts accordingly.
function ENT:AcceptInput(inputName, activator, called, data)
	if(self.Entity:GetIsActor()) then
		return
	end

	--print(inputName)
	if(inputName == "reset") then
		print("turretNum has reset")
		numOfTurrets = 0
	end

	local newTurret = self.Entity:GetSpawnedTurret()
	local pathToSpeak = ""--this is the path to the sound. It's selected based on the if else statements below.

	--print(tostring(newTurret:GetAngles()))
		
	if(newTurret:GetModel() == "models/props/turret_01.mdl" or newTurret:GetModel() == "models/npcs/turret/turret.mdl") then --if is portal 1 turret
		--print("attempting Portal turret "..inputName.." sound")
		pathToSpeak = "npc/turret_floor/turret_"--this is the path to the sound. It's concatenated together below.
	elseif(newTurret:GetModel() == "models/npcs/turret/turret_skeleton.mdl") then --if is defective turret
		--print("attempting defective "..inputName.." sound")
		pathToSpeak = "defective/turretsounds/"--this is the path to the sound. It's concatenated together below.
	end
			
	if(inputName == "tipped") then	
		pathToSpeak = pathToSpeak.."disabled_"..math.random(2, 8)
		pathToSpeak = pathToSpeak..".wav"

		self.Entity:SetIsTipped(true)

		newTurret:EmitSound(pathToSpeak) --call emit sound here because the flag negates the lower command.

		if(IsValid(self.Entity:GetLaser())) then
			self.Entity:GetLaser():Fire("TurnOff")
		end
	elseif(inputName == "pickup") then
		pathToSpeak = pathToSpeak.."pickup_"..math.random(1, 10)

		pathToSpeak = pathToSpeak..".wav"
	elseif(inputName == "dropped") then
		pathToSpeak = pathToSpeak.."autosearch_"..math.random(1, 6)

		pathToSpeak = pathToSpeak..".wav"
	elseif(inputName == "retired") then
		pathToSpeak = pathToSpeak.."retire_"..math.random(1, 7)

		pathToSpeak = pathToSpeak..".wav"
	elseif(inputName == "deployed") then
		if(math.random(0,1) == 0 or self.Entity:GetSpawnedTurret():GetModel() == "models/npcs/turret/turret_skeleton.mdl") then
			pathToSpeak = pathToSpeak.."deploy_"..math.random(1, 6)
		else
			pathToSpeak = pathToSpeak.."active_"..math.random(1, 8)
		end

		pathToSpeak = pathToSpeak..".wav"
		self.Entity:SetIsTipped(false)
		self.Entity:SetIsKnocked(false)

		if(IsValid(self.Entity:GetLaser())) then
			self.Entity:GetLaser():Fire("TurnOn")
		end

		--ent_fire npc_portal_turret_floor_spawnpoint addoutput "Defective 1"
	end
	--
	if(!self.Entity:GetFireDetected() and !self.Entity:GetIsTipped()) then
		newTurret:EmitSound(pathToSpeak)
	end
end


function ENT:Think()
	if(self.Entity:GetFirstFrame()) then
		self.Entity:SetFirstFrame(false)
		SpawnNewTurret(self.Entity, self.Entity:GetPlayerSpawn())
		self:SetName("TurretSpawn"..self:GetTurretNum())
		self.Entity:SetKeyValue("classname","npc_portal_turret_floor_spawnpoint")
		
		turret = self.Entity:GetSpawnedTurret()
		--turret:Fire("addoutput","\"OnTipped !player,ignite, 0,1\"")
		--This code configures the turret to output when tipped.
		--turret:SetKeyValue("OnTipped",self.Entity:GetName()..",lol,1,0,1")
		turret:SetKeyValue("OnTipped",self:GetName()..",tipped")
		turret:SetKeyValue("OnDeploy",self:GetName()..",deployed")
		turret:SetKeyValue("OnRetire",self:GetName()..",retired")
		turret:SetKeyValue("OnPhysGunPickup",self:GetName()..",pickup")
		turret:SetKeyValue("OnPhysGunDrop",self:GetName()..",dropped")
	
		if(self.Entity:GetOracle()) then
			timer.Create( "OracleLines"..self.Entity:GetName(), 10, 0, function() 
				randNum = math.random(1,11)
				if(randNum > 9) then
					self.Entity:GetSpawnedTurret():EmitSound("npc/turret/different_turret"..randNum..".wav") 
				else
					self.Entity:GetSpawnedTurret():EmitSound("npc/turret/different_turret0"..randNum..".wav") 
				end
			end)
		end
		--print(self.Entity:GetName())
	else
		if(!IsValid(self.Entity:GetSpawnedTurret())) then --If linked turret has been removed...
			self.Entity:Remove() --kill ourselves
			--return
		elseif(self.Entity:GetSpawnedTurret():IsOnFire() and !self.Entity:GetFireDetected()) then --If we're on fire and it wasn't detected yet...
			--print("turret is on fire")
			self.Entity:GetSpawnedTurret():Fire("SelfDestruct") --blow ourselves up
			if(self.Entity:GetSpawnedTurret():GetModel() == "models/combine_turrets/floor_turret.mdl") then

			elseif(!(self.Entity:GetSpawnedTurret():GetModel() == "models/npcs/turret/turret_skeleton.mdl")) then 
				local randNum = math.random(1, 10)
				if(randNum == 10) then
					self.Entity:GetSpawnedTurret():EmitSound("npc/turret/turretshotbylaser10.wav")
				else
					self.Entity:GetSpawnedTurret():EmitSound("npc/turret/turretshotbylaser0"..randNum..".wav")
				end
			elseif(!self.Entity:GetIsActor()) then
				self.Entity:GetSpawnedTurret():EmitSound("defective/explode/"..math.random(1, 15)..".wav")
			end
			self.Entity:SetFireDetected(true) --prevent this from running every frame
		--this if statement sets crap turrets on fire when tipped (they don't output the "OnTipped" output, so this needs to be done manually.
		elseif(self.Entity:GetDefective() and (self.Entity:GetSpawnedTurret():GetAngles().z > 59 or self.Entity:GetSpawnedTurret():GetAngles().z < -59) and !self.Entity:GetFireDetected()) then
			self.Entity:GetSpawnedTurret():Fire("ignite")
			self.Entity:GetSpawnedTurret():Fire("SelfDestruct") --blow ourselves up
			if(self.Entity:GetSpawnedTurret():GetModel() == "models/npcs/turret/turret_skeleton.mdl") then
				self.Entity:GetSpawnedTurret():EmitSound("defective/explode/"..math.random(1, 15)..".wav")
			end
			self.Entity:SetFireDetected(true) --prevent this from running every frame
		elseif((self.Entity:GetSpawnedTurret():GetAngles().z > 59 or self.Entity:GetSpawnedTurret():GetAngles().z < -59) and !(self.Entity:GetSpawnedTurret():GetModel() == "models/npcs/turret/turret_skeleton.mdl" or self.Entity:GetSpawnedTurret():GetModel() == "models/combine_turrets/floor_turret.mdl" or self.Entity:GetIsActor()) and !self.Entity:GetIsKnocked()) then
			self.Entity:SetIsKnocked(true)

			local num = math.random(1,4)
			if(num == 1) then
				self.Entity:GetSpawnedTurret():EmitSound("npc/turret_floor/turret_tipped_2.wav")
			elseif(num == 2) then
				self.Entity:GetSpawnedTurret():EmitSound("npc/turret_floor/turret_tipped_4.wav")
			elseif(num == 3) then
				self.Entity:GetSpawnedTurret():EmitSound("npc/turret_floor/turret_tipped_5.wav")
			elseif(num == 4) then
				self.Entity:GetSpawnedTurret():EmitSound("npc/turret_floor/turret_tipped_6.wav")
			end
		end
	end
	--print("wut")
	
end


--This spawns a turret at our location. Key values are passed on to the spawned turret, as well as name, model and position.
function SpawnNewTurret( turretSpawner, wasSpawned)
	--This generates an HL2 turret entity and ensures that it spawned properly. Then it saves it and set's it's position to match ours.
	local newTurret = ents.Create( "npc_turret_floor" ) --make a turret entity
	turretSpawner:SetSpawnedTurret(newTurret)

	if ( !IsValid( newTurret ) ) then  --If turret is invalid, return and print an error, otherwise run normally.
		print("turret failed to spawn at "..tostring(turretSpawner:GetPos()).." with angles "..tostring(turretSpawner:GetAngles()))
		failCount = failCount + 1
		return;
	end

	--print("passed turret validity test")

	newTurret:SetName(turretSpawner:GetName().."turret"..turretSpawner:GetTurretNum())

	newTurret:SetPos(turretSpawner:GetPos()) --set new turret to our position
	newTurret:SetAngles(turretSpawner:GetAngles()) --set the new turrets angles to our current angles

-----------------------------------------------------------------------------------
--This sets the keyvalues for the turret. Due to lua api bugs this isn't quite accurate, but it helps.
-----------------------------------------------------------------------------------
	local keyValues = turretSpawner:GetKeyValues() --retrieve current key values

	for k, v in pairs(keyValues) do	--copy key values over to new turret
		newTurret:SetKeyValue(k,tostring(v))
	end

	newTurret:SetSaveValue("m_bNoAlarmSounds", true)
-----------------------------------------------------------------------------------
--This sets the broken turrets in escape_01 up so that they can't fire (works around a bug where keyvalues don't work). Also does the same to defective turrets.
-----------------------------------------------------------------------------------
	if(game.GetMap() == "escape_01") then
		if(turretSpawner:MapCreationID() == 1521 or turretSpawner:MapCreationID() == 1525 or turretSpawner:MapCreationID() == 1523) then
			print("Setting broken turrets")
			newTurret:Fire( "DepleteAmmo" )
		end
	end
	
	if(turretSpawner:GetDefective()) then
		newTurret:Fire( "DepleteAmmo" )
	end

--------------------------------------------------------------------------------------------------------------------------------------
--This disables Actor turrets. Only used in Portal 2 levels and the Oracle Turret.
--------------------------------------------------------------------------------------------------------------------------------------
	if(turretSpawner:GetIsActor()) then
		newTurret:Fire("disable")
	end

--------------------------------------------------------------------------------------------------------------------------------------
--This sets the turrets model. Takes its' model from the spawner.
--------------------------------------------------------------------------------------------------------------------------------------

	if(file.Exists(turretSpawner:GetModel(), "GAME")) then --if the model we're using exists...
		newTurret:SetModel(turretSpawner:GetModel()) --set the turret to use it.
	end
	
-----------------------------------------------------------------------------------
--This part makes the turret talk when newly spawned from the Spawn Menu.
-----------------------------------------------------------------------------------
	local pathToSpawnSpeak = ""--this is the path to the sound. It's selected based on the if else statements below.

	--play turret spawning sound if spawned via spawnmenu. Based on which kind of turret it is.
	if(!wasSpawned or (turretSpawner:GetIsActor() and !turretSpawner:GetOracle())) then
	
	elseif(turretSpawner:GetOracle()) then
		randNum = math.random(1,11)
			if(randNum > 9) then
				newTurret:EmitSound("npc/turret/different_turret"..randNum..".wav") 
			else
				newTurret:EmitSound("npc/turret/different_turret0"..randNum..".wav") 
			end
	elseif(newTurret:GetModel() == "models/props/turret_01.mdl") then --if spawned via spawnmenu and is portal 1 model...
		--print("attempting Portal 1 spawn sound")
		pathToSpawnSpeak = "npc/turret_floor/turret_"--this is the path to the sound. It's concatenated together below.
		local spawnSpeakType = math.random(0, 3)--this says which type of speech to choose first (autosearch, deploy, etc)
				
		if(spawnSpeakType == 0) then
			pathToSpawnSpeak = pathToSpawnSpeak.."active_"..math.random(1, 8)
		elseif(spawnSpeakType == 1) then
			pathToSpawnSpeak = pathToSpawnSpeak.."deploy_"..math.random(1, 6)
		elseif(spawnSpeakType == 2) then
			pathToSpawnSpeak = pathToSpawnSpeak.."autosearch_"..math.random(1, 6)
		elseif(spawnSpeakType == 3) then
			pathToSpawnSpeak = pathToSpawnSpeak.."search_"..math.random(1, 4)
		end

		pathToSpawnSpeak = pathToSpawnSpeak..".wav"

	elseif(newTurret:GetModel() == "models/npcs/turret/turret.mdl") then --if spawned via spawnmenu and is portal 2 model...
		--print("attempting Portal 2 spawn sound")
		pathToSpawnSpeak = "npc/turret_floor/turret_"--this is the path to the sound. It's concatenated together below.
		local spawnSpeakType = math.random(0, 3)--this says which type of speech to choose first (autosearch, deploy, etc)
				
		if(spawnSpeakType == 0) then
			pathToSpawnSpeak = pathToSpawnSpeak.."active_"..math.random(1, 8)
		elseif(spawnSpeakType == 1) then
			pathToSpawnSpeak = pathToSpawnSpeak.."deploy_"..math.random(1, 6)
		elseif(spawnSpeakType == 2) then
			pathToSpawnSpeak = pathToSpawnSpeak.."autosearch_"..math.random(1, 6)
		elseif(spawnSpeakType == 3) then
			pathToSpawnSpeak = pathToSpawnSpeak.."search_"..math.random(1, 4)
		end

		pathToSpawnSpeak = pathToSpawnSpeak..".wav"

	elseif(newTurret:GetModel() == "models/npcs/turret/turret_skeleton.mdl") then --if spawned via spawnmenu and is defective model...
		--print("attempting Defective spawn sound")
		pathToSpawnSpeak = "defective/"--this is the path to the sound. It's concatenated together below.
		local spawnSpeakType = math.random(1, 14)--this says which type of speech to choose.
		
		pathToSpawnSpeak = pathToSpawnSpeak.."defective_turret ("..spawnSpeakType..").wav"

	elseif(newTurret:GetModel() == "models/npcs/turret/turret_boxed.mdl" or newTurret:GetModel() == "models/npcs/turret/turret_backwards.mdl") then --if spawned via spawnmenu and is defective model...
		--print("attempting boxed spawn sound")
		pathToSpawnSpeak = "npc/"--this is the path to the sound. It's concatenated together below.
		local spawnSpeakType = math.random(1, 11)--this says which type of speech to choose.
		
		if(spawnSpeakType == 1) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/sp_sabotage_factory_good_fail01.wav"
		elseif(spawnSpeakType == 2) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/sp_sabotage_factory_good_fail03.wav"
		elseif(spawnSpeakType == 3) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretlightbridgeblock02.wav"
		elseif(spawnSpeakType == 4) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretshotbylaser10.wav"
		elseif(spawnSpeakType == 5) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretsquashed03.wav"
		elseif(spawnSpeakType == 6) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretsquashed05.wav"
		elseif(spawnSpeakType == 7) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretwitnessdeath09.wav"
		elseif(spawnSpeakType == 8) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretwitnessdeath10.wav"
		elseif(spawnSpeakType == 9) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret/turretwitnessdeath11.wav"
		elseif(spawnSpeakType == 10) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret_floor/turret_pickup_5.wav"
		elseif(spawnSpeakType == 11) then
			pathToSpawnSpeak = pathToSpawnSpeak.."turret_floor/turret_pickup_10.wav"
		end
	end

	turretSpawner:EmitSound(pathToSpawnSpeak)	--play the spawn sound.
-----------------------------------------------------------------------------------
--End of spawn sound code
-----------------------------------------------------------------------------------

	newTurret:Spawn() --spawn the new turret
	
	if(!(newTurret:GetModel() == "models/npcs/turret/turret_skeleton.mdl") and !(newTurret:GetModel() == "models/npcs/turret/turret_boxed.mdl") and !(newTurret:GetModel() == "models/npcs/turret/turret_backwards.mdl")) then
--This spawn a laser target
		local laserp = ents.Create( "info_target" ) --make an entity
		--laserp:SetModel("models/props/turret_01.mdl")
		laserp:SetPos(newTurret:GetPos() + newTurret:GetForward() * 10000)-- + newTurret:GetUp() * 37)
		laserp:SetAngles(newTurret:GetAngles())
		laserp:Fire("DisableCollision")
		laserp:Fire("SetParent", newTurret:GetName())
		laserp:Fire("SetParentAttachmentMaintainOffset","eyes",0)
		laserp:SetName(newTurret:GetName().."laserpoint")
	
		laserp:Spawn()

--this spawns a laser object
		local laser = ents.Create( "env_laser" ) --make an entity
--universal keyvalues
		laser:SetKeyValue("texture", "sprites/laserbeam.spr")
		laser:SetKeyValue("rendercolor", "255, 47, 47, 50")
		laser:SetKeyValue("spawnflags", 1)
		laser:SetKeyValue("damage", 1)
--beam values
		--laser:SetKeyValue("BoltWidth", 1)
		--laser:SetKeyValue("LightningStart", laserp:GetName())
		--laser:SetKeyValue("LightningEnd", newTurret:GetName())
		--laser:SetKeyValue("life", 0)
		--laser:SetKeyValue("TextureScroll", 40)
--laser values
		laser:SetKeyValue("width", 1)
		laser:SetKeyValue("LaserTarget", laserp:GetName())
		laser:SetKeyValue("dissolvetype", "None")
--set positions and stuff and spawn
		laser:SetPos(newTurret:GetPos() + newTurret:GetForward() * 15.8 + newTurret:GetUp() * 37 )
		laser:SetAngles(newTurret:GetAngles())
		laser:Fire("SetParent", newTurret:GetName())
		--laser:Fire("SetParentAttachmentMaintainOffset","eyes",0)
		laser:Spawn()

		laser:SetKeyValue("LaserTarget", laserp:GetName())

		turretSpawner:SetLaser(laser)
	end	
	
end


--Read all keyvalues. Used to store outputs and set important variables.
function ENT:KeyValue( k, v )
	--store outputs
	-- 99% of all outputs are named 'OnSomethingHappened'.
	--if ( string.Left( k, 2 ) == "On" ) then
	--	self:StoreOutput( k, v )
	--	--print(k.." "..v.." for launcher "..self.Entity:GetUniqueNumber())
	--end

	
	print(k..v)

	if(k == "UsedAsActor" and v == "1") then
		self.Entity:SetIsActor(true)
	end
	
	if(k == "Oracle" and v == "1") then
		self.Entity:SetOracle(true)
	end

	if(k == "Defective" and v == "1") then
		self.Entity:SetDefective(true)

		if(IsValid(self.Entity:GetSpawnedTurret())) then
			if(self.Entity:GetDefective()) then
				self.Entity:GetSpawnedTurret():Fire( "DepleteAmmo" )
			end
		end
	end
end

function ENT:OnRemove()
	if(IsValid(self.Entity:GetSpawnedTurret())) then
		self.Entity:GetSpawnedTurret():Remove()
	end
	
	if(self.Entity:GetOracle()) then
		timer.Remove("OracleLines"..self.Entity:GetName())
	end
end