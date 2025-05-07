local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Throw = {}
Throw.__index = Throw

local Duration = SpellsInfo.Throw.Duration
local Anim = ReplicatedStorage.Animations.Throw
local Distance = 50000
local Speed = 120
local Velocity = Speed * 60
local lifeTime = Distance / Velocity

function Throw.new(plr: Player)
	local self = setmetatable({}, Throw)
	
	self.Char = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Char:WaitForChild("Humanoid")
	self.Anim = self.Humanoid:LoadAnimation(Anim)
	self.Anim:Play()
	self.Connection = nil
	
	
	task.delay(Duration, function()
		self.Anim:Stop()
		
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(1,1,1)
		Part.Parent = workspace
		Part.Anchored = true
		Part.CFrame = self.Char.HumanoidRootPart.CFrame + self.Char.HumanoidRootPart.CFrame.LookVector * 4
		
		local Destroyed = false
		local Hitbox = MuchachoHitbox.CreateHitbox()
		Hitbox.CFrame = Part
		Hitbox.Visualizer = true
		Hitbox.Size = Part.Size * 1.5
		Hitbox:Start()
		
		Hitbox.Touched:Connect(function(hit)
			hit.Parent:SetAttribute("CanRun", false)
			Destroyed = true
			task.delay(Duration, function()
				hit.Parent:SetAttribute("CanRun", true)
			end)
		end)
		
		
		self.Connection = RunService.Heartbeat:Connect(function(dt)
			if not Part then self.Connection:Disconnect() return end
			Part.Position = Part.Position + Part.CFrame.LookVector * Speed * dt
		end)
		game.Debris:AddItem(Part, lifeTime)
		task.delay(0.2, function()
			if not Destroyed then
				Hitbox:Destroy()
			end
		end)
	end)
	
	return self
end


return Throw
