
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local Ragdoll = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Ragdoll"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("EarlyLetGrabGo")
local Grab = {}
Grab.__index = Grab

local Duration = SpellsInfo.Grab.Duration
local Anim = ReplicatedStorage.Animations.Grab
local PLAYER_GRAB_MOVE_SPEED = 100 

function Grab:CleanUpGrab()
	if not self.IsGrabActive then return end 
	self.IsGrabActive = false
	self.Ehum.WalkSpeed = self.WS

	if self.GrabUpdateConnection then
		self.GrabUpdateConnection:Disconnect()
		self.GrabUpdateConnection = nil
	end

	if self.Weld and self.Weld.Parent then
		self.Weld:Destroy()
	end
	self.Weld = nil

	if self.MoveForce then
		self.MoveForce:Destroy()
		self.MoveForce = nil
	end
	if self.MoveAttachment then
		self.MoveAttachment:Destroy()
		self.MoveAttachment = nil
	end

	if self.Anim and self.Anim.IsPlaying then
		self.Anim:Stop()
	end

	local enemyCharacter = self.GrabbedEnemy
	if enemyCharacter and enemyCharacter:FindFirstChild("Humanoid") then
		Ragdoll.ragdoll(enemyCharacter, 4)
	end
	self.GrabbedEnemy = nil

	if not self.Destroyed then
		self.Hitbox:Destroy()
		self.Hitbox = nil
	end
	
	
end

function Grab.new(plr: Player)
	local self = setmetatable({}, Grab)
	
	self.Char = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Char:WaitForChild("Humanoid")
	self.Anim = self.Humanoid:LoadAnimation(Anim)
	
	self.Destroyed = false 
	self.EarlyGo = false  
	self.letgo = false    
	self.IsGrabActive = false 
	self.GrabbedEnemy = nil
	self.Weld = nil
	self.MoveAttachment = nil
	self.MoveForce = nil
	self.GrabUpdateConnection = nil
	
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {self.Char}
	
	self.Hitbox = MuchachoHitbox.CreateHitbox()
	if not self.Hitbox then
		warn("Grab: Failed to create Hitbox")
		if self.Anim then self.Anim:Stop() end 
		return nil
	end
	
	self.Anim:Play()

	self.Hitbox.Visualizer = true
	self.Hitbox.Size = Vector3.new(15, 5, 15)
	self.Hitbox.CFrame = self.Char.HumanoidRootPart.CFrame 
	self.Hitbox.Offset = CFrame.new(0, 0, -4)
	self.Hitbox.OverlapParams = Params
	self.Hitbox.VelocityPrediction = true
	self.Hitbox.VelocityPredictionTime = .2
	self.Hitbox.DetectionMode = "HitOnce"
	self.Hitbox:Start()
	
	self.Hitbox.Touched:Connect(function(hit, hum)
		if self.Destroyed then return end
		
		self.Ehum = hum
		self.Char:SetAttribute("CanRun", false)

		local enemyCharacter = hit.Parent 
		if not enemyCharacter or not enemyCharacter:FindFirstChild("HumanoidRootPart") or not hum then
			return 
		end
		
		self.Destroyed = true
		self.IsGrabActive = true
		self.GrabbedEnemy = enemyCharacter
		self.WS = hum.WalkSpeed
	
		enemyCharacter.HumanoidRootPart.CFrame = self.Char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)
		
		self.Weld = Instance.new("WeldConstraint") 
		self.Weld.Part0 = self.Char.HumanoidRootPart
		self.Weld.Part1 = enemyCharacter.HumanoidRootPart
		self.Weld.Parent = self.Char.HumanoidRootPart
		
		hum.WalkSpeed = 1
		hum.JumpPower = 0
		
		Event.OnServerEvent:Connect(function(player)
			if player == plr then
				self.letgo = true
			end
		end)
		
		

		self.MoveAttachment = Instance.new("Attachment")
		self.MoveAttachment.Parent = self.Char.HumanoidRootPart

		self.MoveForce = Instance.new("LinearVelocity")
		self.MoveForce.Attachment0 = self.MoveAttachment
		self.MoveForce.RelativeTo = Enum.ActuatorRelativeTo.World
		self.MoveForce.MaxAxesForce = Vector3.new(math.huge, 0, math.huge)
		self.MoveForce.VectorVelocity = Vector3.new(0,0,0)
		self.MoveForce.Parent = self.Char.HumanoidRootPart

		self.GrabUpdateConnection = RunService.Heartbeat:Connect(function()
			if not self.IsGrabActive then
				if self.GrabUpdateConnection then
					self.GrabUpdateConnection:Disconnect()
					self.GrabUpdateConnection = nil
				end
				return
			end

			if not self.Weld or not self.Weld.Parent then 
				self.Char:SetAttribute("CanRun", true)
				self:CleanUpGrab()
				return
			end

			if self.MoveForce then
				local lookVector = self.Char.HumanoidRootPart.CFrame.LookVector
				local moveDirection = Vector3.new(lookVector.X, 0, lookVector.Z)
				if moveDirection.Magnitude > 0.001 then 
					self.MoveForce.VectorVelocity = moveDirection.Unit * PLAYER_GRAB_MOVE_SPEED
				else
					self.MoveForce.VectorVelocity = Vector3.new(0,0,0)
				end
			end

			if self.letgo and not self.EarlyGo then
				self.EarlyGo = true 
				self.Char:SetAttribute("CanRun", true)
				self:CleanUpGrab()
			end
		end)
		
		task.delay(Duration, function()
			if self.EarlyGo or not self.IsGrabActive then return end 
			self.Char:SetAttribute("CanRun", true)
			self:CleanUpGrab()
		end)
		
		
	
	end)
	

	task.delay(.2, function()
		if not self.Destroyed then 
			if self.Anim and self.Anim.IsPlaying then self.Anim:Stop() end
			if not self.Destroyed then self.Hitbox:Destroy() self.Hitbox = nil end
			self.IsGrabActive = false 
		end
	end)
	
	return self
end

return Grab


