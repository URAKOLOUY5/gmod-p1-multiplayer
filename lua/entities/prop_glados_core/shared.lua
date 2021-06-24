AddCSLuaFile()



DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Glados Core"
ENT.Author = "URAKOLOUY5"
ENT.Information = ""
ENT.Category = "Portal"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = false

if SERVER then
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
	//self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )  
        local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
function ENT:Think()
	if (self:WaterLevel() > 0) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 10)
		local effectdata = EffectData()

		effectdata:SetOrigin( self.Entity:GetPos() )

 		util.Effect( "Explosion", effectdata, true, true )
		self.Entity:Remove()
		RunConsoleCommand("stopsound", "");
	end
	self.Entity:NextThink(1)
end	
end