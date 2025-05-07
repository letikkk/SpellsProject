local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Punch = {}
Punch.__index = Punch

local Duration = SpellsInfo.Punch.Duration
local Anim = ReplicatedStorage.Animations.Punch

function Punch.new(plr: Player)
	local self = setmetatable({}, Punch)
	
	self.Char = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Char:WaitForChild("Humanoid")
	self.Anim = self.Humanoid:LoadAnimation(Anim)
	self.Anim:Play()
	self.OldSpeed = self.Humanoid.WalkSpeed
	self.Humanoid.WalkSpeed = 1
	self.Char:SetAttribute("CanRun", false)
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {self.Char}
	
	
	task.delay(Duration, function()
		self.Hitbox = MuchachoHitbox.CreateHitbox()
		
		self.Destroyed = false
		self.Hitbox.Size = Vector3.new(9, 5, 9)
		self.Hitbox.CFrame = self.Char.HumanoidRootPart.CFrame
		self.Hitbox.Offset = CFrame.new(0,0,-4)
		self.Hitbox.DetectionMode = "HitOnce"
		self.Hitbox.Visualizer = true
		self.Hitbox.OverlapParams = Params
		self.Hitbox.VelocityPrediction = true
		self.Hitbox.VelocityPredictionTime = .2
		self.Hitbox.AutoDestroy = true
		self.Hitbox:Start()
		
		self.Anim:Stop()
		self.Humanoid.WalkSpeed = self.OldSpeed
		
		self.Hitbox.Touched:Connect(function(hit, hum)
			self.Char:SetAttribute("CanRun", true)
				self.Destroyed = true
				
				local Char = hum.Parent

				local Debris = game:GetService("Debris")
				local root = self.Char:FindFirstChild("HumanoidRootPart")

				local targetHRP = Char:FindFirstChild("HumanoidRootPart")
				if not targetHRP then
					warn("Model does not have a HumanoidRootPart")
					return
				end

				local dir = (targetHRP.Position - root.Position).Unit
				local attachment = Instance.new("Attachment", targetHRP)

				local force = Instance.new("VectorForce", targetHRP)
				force.Attachment0 = attachment
				force.Force = (dir + Vector3.new(0,0,0)).Unit * (4500)
				force.RelativeTo = Enum.ActuatorRelativeTo.World

				local rotation = Instance.new("AngularVelocity", targetHRP)
				rotation.Attachment0    = attachment
				rotation.AngularVelocity= Vector3.new(1,1,1) * (15)
				rotation.MaxTorque      = math.huge
				rotation.RelativeTo     = Enum.ActuatorRelativeTo.World

				Debris:AddItem(force, 0.5)
				Debris:AddItem(attachment, 0.5)
				Debris:AddItem(rotation, 0.5)
		end)
	task.delay(0.2 , function()
		if not self.Destroyed then
			self.Hitbox:Destroy()
				self.Char:SetAttribute("CanRun", true)
		end
	end)

	end)
	
	return self
end


return Punch
