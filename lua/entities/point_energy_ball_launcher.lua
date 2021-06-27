AddCSLuaFile()
DEFINE_BASECLASS("base_aperture_ent")

ENT.PrintName = "Hight Energy Pellet Launcher"
ENT.IsAperture = true
ENT.IsConnectable = true

balllifetime = 1

function ENT:Draw()
	return false
end

function ENT:KeyValue( key, value )	
	if key == "BallLifetime" then
		balllifetime = value
	end
	
	if ( string.Left( key, 2 ) == "On" ) then
		self:StoreOutput( key, value )
	end	
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Busy")
	self:NetworkVar("Bool", 1, "Enable")
	self:NetworkVar("Bool", 2, "StartEnabled")
	self:NetworkVar("Bool", 3, "Toggle")
	self:NetworkVar("Int", 4, "Time")
end

function ENT:Enable(enable)
	if self:GetEnable() ~= enable then
		if enable then
			self:LaunchBall()
		else
		end

		self:SetEnable(enable)
	end
end

function ENT:EnableEX(enable)
	if self:GetToggle() then
		if enable then
			self:Enable(not self:GetEnable())
		end
		return true
	end

	if self:GetStartEnabled() then
		enable = not enable
	end
	self:Enable(enable)
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		self:SetModel("models/aperture/combine_ball_launcher.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:GetPhysicsObject():EnableMotion(false)
		self:SetBusy(false)

		if self:GetStartEnabled() then
			self:Enable(true)
		end
	end

	if CLIENT then
	end
end

if CLIENT then
	return
end

function ENT:Think()
	if not IsValid(self) then
		return
	end
	self:NextThink(CurTime() + 0.1)
	self.BaseClass.Think(self)

	if not self:GetEnable() then
		return
	end

	if not IsValid(self.LastLaunchedBall) then
		self:LaunchBall()
	end

	return true
end

function ENT:LaunchBall()
	if not IsValid(self) then
		return
	end
	if self:GetBusy() then
		return
	end
	self:SetBusy(true)
	self:PlaySequence("open", 5.0)
	timer.Simple(
		0.1,
		function()
			if not IsValid(self) then
				return
			end
			self:SpawnCombineBall()
			self:TriggerOutput("OnPostSpawnBall")
			sound.Play("TA:BallLaunch", self:LocalToWorld(Vector(30, 0, 0)))
		end
	)
	timer.Simple(
		2,
		function()
			if IsValid(self) then
				self:SetBusy(false)

			end
		end
	)
end

function ENT:SpawnCombineBall()
	local ent = ents.Create("point_combine_ball_launcher")
	if not IsValid(ent) then
		return
	end
	local pos = self:GetPos() + self:GetForward() * 2
	ent:SetKeyValue("minspeed", 200)
	ent:SetKeyValue("maxspeed", 200)
	ent:SetKeyValue("spawnflags", 4096 + 2)
	ent:SetKeyValue("launchconenoise", 0)
	ent:SetPos(pos)
	ent:SetAngles(Angle(0, 0, 0))
	ent:Spawn()
	ent:Activate()
	ent:Fire("LaunchBall")
	ent:Fire("kill", "", 0)

	timer.Simple(
		0.5,
		function()
			if not IsValid(self) then
				return
			end
			local result = ents.FindInSphere(self:GetPos(), 100)
			for k, v in pairs(result) do
				if v:GetClass() == "prop_combine_ball" then
					self.LastLaunchedBall = v
					v.UnFizzable = true
					timer.Simple(
						balllifetime,
						function()
							if IsValid(v) then
								v:Fire("Explode", "", 0)
							end
						end
					)
					break
				end
			end
		end
	)
end

function ENT:AcceptInput(name)	
	if (name == "Enable") then
		self:Enable(true)
	end
	if (name == "Disable") then
		self:Enable(false)
	end
	if (name == "LaunchBall") then
		self:LaunchBall()
	end		
end