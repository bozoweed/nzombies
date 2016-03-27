ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Monkey Bomb"
ENT.Author = "Zet0r"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then
	AddCSLuaFile()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/weapons/w_eq_fraggrenade_thrown.mdl") -- Change later
		self:PhysicsInitSphere(2, "metal_bouncy")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		phys = self:GetPhysicsObject()

		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
end


function ENT:PhysicsCollide(data, physobj)
	if SERVER then
		local vel = physobj:GetVelocity():Length()
		if vel > 100 then
			self:EmitSound("weapons/hegrenade/he_bounce-1.wav", 75, 100)
		end

		local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
		local NewVelocity = physobj:GetVelocity()
		NewVelocity:Normalize()

		LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

		local TargetVelocity = NewVelocity * LastSpeed * 0.6

		physobj:SetVelocity( TargetVelocity )
		self:SetLocalAngularVelocity( AngleRand() )
	end
end

function ENT:SetExplosionTimer( time )

	SafeRemoveEntityDelayed( self, time +1 ) --fallback

	timer.Simple(time, function()
		if IsValid(self) then
			local pos = self:GetPos()
			local owner = self:GetOwner()

			util.BlastDamage(self, owner, pos, 500, 150)

			fx = EffectData()
			fx:SetOrigin(pos)
			fx:SetMagnitude(1)
			util.Effect("Explosion", fx)

			self:Remove()
		end
	end)
end

function ENT:Draw()
	self:DrawModel()
end

-- Add this function to allow this entity to be targeted by zombies

function ENT:WillAttractZombie( z ) -- Whether to attract the zombie or not
	return true -- No condition or fancy distance check, always do
end