local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Dash = {}
Dash.__index = Dash

local Duration = SpellsInfo.Dash.Duration
local Anim = ReplicatedStorage.Animations.Dash
local Distance = 50000
local Speed = 120
local Velocity = Speed * 60
local lifeTime = Distance / Velocity

function Dash.new(plr: Player)
	local self = setmetatable({}, Dash)
	
	self.Char = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Char:WaitForChild("Humanoid")
	self.Anim = self.Humanoid:LoadAnimation(Anim)
	self.Anim:Play()
	self.Connection = nil
	
	self.LinearVelocity = Instance.new("LinearVelocity")
	self.LinearVelocity.Parent = self.Char.HumanoidRootPart
	self.LinearVelocity.MaxForce = math.huge
	self.LinearVelocity.Attachment0 = self.Char.HumanoidRootPart.RootAttachment
	self.LinearVelocity.VectorVelocity = self.Char.HumanoidRootPart.CFrame.LookVector * 40
	
	self.Connection = RunService.Heartbeat:Connect(function()
		if not self.LinearVelocity or not self.Char then self.Connection:Disconnect()
			return
		end
		self.LinearVelocity.VectorVelocity = self.Char.HumanoidRootPart.CFrame.LookVector * 40
	end)
	
	task.delay(Duration, function()
		self.LinearVelocity:Destroy()
	end)
	
	return self
end


return Dash
