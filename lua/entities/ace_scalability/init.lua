DEFINE_BASECLASS("base_wire_entity") -- Required to get the local BaseClass

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
--[[
function ENT:Initialize()

	--Use the half value of the final scale lenght. To define the real lenght in the final result
	--XYZ scale config should depend on what entity we are scaling, since ammos should scale as shown below, guns by caliber, fuels in the same way as ammo, etc...

	local Mode = math.random(1,2)

	local XScale
	local YScale
	local ZScale

	local DefaultSize
	local ModelPath

	local EntityScale

	local id

	if Mode == 1 then -- This will be used by ammocrates and fueltanks

		id = "models/holograms/rcube_thin.mdl" --This will be given depending on the entity class

		XScale = math.random(10,100)
		YScale = math.random(10,100)
		ZScale = math.random(10,100)

		DefaultSize = ACE.ModelData[id].DefaultSize
		EntityScale = Vector(XScale / DefaultSize, YScale / DefaultSize, ZScale / DefaultSize)

		self:SetMaterial("models/props_pipes/GutterMetal01a")

	elseif Mode == 2 then -- Adjust size by caliber.

		id = "models/tankgun/tankgun_100mm.mdl" --This will be given depending on the entity class

		local Caliber = 37--math.random(37,170)

		DefaultSize = ACE.ModelData[id].DefaultSize
		EntityScale = Vector(Caliber / DefaultSize, Caliber / DefaultSize, Caliber / DefaultSize)

	end

	ModelPath	= ACE.ModelData[id].Model

	self:SetModel( ModelPath ) --Make it compatible with ACF-3
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysicsObj = self:GetPhysicsObject()
	self.IsScalable = true

	do

		local Phys = self.PhysicsObj

		if IsValid(Phys) then
			Phys:Wake()
			Phys:SetMass(1000)

			local Mesh = ACE.ModelData[id].CustomMesh or Phys:GetMeshConvexes()

			self.ScaleData = {
				Mesh = Mesh,
				Scale = EntityScale,
				Size = DefaultSize
			}

			self:ACE_SetScale( self.ScaleData )

		end
	end
end
]]
do

	local function NetworkNewScale( Ent, Scale )

		net.Start("ACE_Scalable_Network")
			net.WriteFloat(Scale.x)
			net.WriteFloat(Scale.y)
			net.WriteFloat(Scale.z)
			net.WriteEntity( Ent )
		net.Broadcast()

	end

	function ENT:ACE_SetScale( ScaleData )

		local MeshData = ScaleData.Mesh
		local Scale = ScaleData.Scale
		--local Size = ScaleData.Size
		local PhysMaterial = ScaleData.Material

		MeshData = self:ConvertMeshToScale( MeshData, Scale )

		self:PhysicsInitMultiConvex( MeshData )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:EnableCustomCollisions(true)
		self:DrawShadow(false)

		self.PhysicsObj = self:GetPhysicsObject()

		local Phys = self.PhysicsObj
		if IsValid(Phys) then
			Phys:Wake()
			Phys:SetMass(1000)
			Phys:SetMaterial( PhysMaterial )
		end

		NetworkNewScale( self, ScaleData.Scale )

	end

	net.Receive("ACE_Scalable_Network", function()

		local Ent = net.ReadEntity()

		if not IsValid(Ent) then return end
		if not Ent.IsScalable then return end

		local ScaleData = Ent.ScaleData

		NetworkNewScale( Ent, ScaleData.Scale )

	end)

end

--Brought from the ACF3
do -- AdvDupe2 duped parented ammo workaround
	-- Duped parented scalable entities were uncapable of spawning on the correct position
	-- That's why they're parented AFTER the dupe is done pasting
	-- Only applies for Advanced Duplicator 2

	function ENT:OnDuplicated(EntTable)
		if self.IsScalable then
			local DupeInfo = EntTable.BuildDupeInfo

			if DupeInfo and DupeInfo.DupeParentID then
				self.ParentIndex = DupeInfo.DupeParentID

				DupeInfo.DupeParentID = nil
			end
		end

		BaseClass.OnDuplicated(self, EntTable)
	end

	function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
		if self.IsScalable and self.ParentIndex then
			self.ParentEnt = CreatedEntities[self.ParentIndex]
			self.ParentIndex = nil
		end

		BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
	end

	hook.Add("AdvDupe_FinishPasting", "ACF Parented Scalable Ent Fix", function(DupeInfo)
		local Dupe	= unpack(DupeInfo, 1, 1)
		local Player	= Dupe.Player
		local CanParent = not IsValid(Player) or tobool(Player:GetInfo("advdupe2_paste_parents"))

		if not CanParent then return end

		for _, Entity in pairs(Dupe.CreatedEntities) do
			if not Entity.IsScalable then continue end
			if not Entity.ParentEnt then continue end

			Entity:SetParent(Entity.ParentEnt)

			Entity.ParentEnt = nil
		end
	end)
end
