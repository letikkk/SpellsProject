local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local SuperSpeed = {}
SuperSpeed.__index = SuperSpeed

local Duration = SpellsInfo.SuperSpeed.Duration
local Anim = ReplicatedStorage.Animations.DoubleJump

function SuperSpeed.new(plr: Player)
	local self = setmetatable({}, SuperSpeed)
	
	self.Character = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.OldSpeed = self.Humanoid.WalkSpeed
	self.LoadedAnim = self.Humanoid.Animator:LoadAnimation(Anim)
	self.LoadedAnim:Play()
	
	ReplicatedStorage.Events.DoubleJump:FireClient(plr)

	task.delay(0.8, function()
		self.Humanoid.WalkSpeed = self.OldSpeed + 10
		self.LoadedAnim:Stop()
		self.Anim2 = ReplicatedStorage.Animations.SuperSpeed
		self.LoadedAnim2 = self.Humanoid.Animator:LoadAnimation(self.Anim2)
		self.LoadedAnim2:Play()
		task.delay(Duration, function()
			self.LoadedAnim2:Stop()
		self.Humanoid.WalkSpeed = 16
		end)
	end)
	return self
end


return SuperSpeed
