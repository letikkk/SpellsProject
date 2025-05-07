local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local SuperJump = {}
SuperJump.__index = SuperJump

local Duration = SpellsInfo.SuperJump.Duration
local Anim = ReplicatedStorage.Animations.SuperJump

function SuperJump.new(plr: Player)
	local self = setmetatable({}, SuperJump)
	self.Character = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.OldJumpPower = self.Humanoid.JumpHeight

	self.LoadedAnim = self.Humanoid.Animator:LoadAnimation(Anim)
	self.LoadedAnim:Play()
	
	task.delay(Duration,function()
		self.Humanoid.JumpHeight = 40
		self.Humanoid.Jump = true
		task.delay(0.2 , function()
			self.LoadedAnim:Stop()
			self.Humanoid.JumpHeight = self.OldJumpPower
		end)
	end)
	return self
end


return SuperJump
