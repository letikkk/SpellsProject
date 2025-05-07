local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local Ragdoll = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Ragdoll"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Wall = {}
Wall.__index = Wall

local Duration = SpellsInfo.Wall.Duration
local Anim = ReplicatedStorage.Animations.Grab
local Distance = 10 


local WALL_WIDTH_STUDS = 18
local WALL_HEIGHT_STUDS = 10
local BRICK_BUILD_SPEED = 0.04 

local BRICK_DIM_X = 2 
local BRICK_DIM_Y = 2 
local BRICK_DIM_Z = 1 

local function placeBrick(cf, pos, color, playerHrpPosition)
	local brick = Instance.new("Part")
	brick.Size = Vector3.new(BRICK_DIM_X, BRICK_DIM_Y, BRICK_DIM_Z)
	brick.BrickColor = color
	brick.Material = Enum.Material.Plastic
	brick.Anchored = true


	local brickCenterInWallLocalSpace = pos + brick.Size / 2 
	local brickWorldCFrameOriginal = cf * CFrame.new(brickCenterInWallLocalSpace)
	local brickWorldPosition = brickWorldCFrameOriginal.Position

	if playerHrpPosition then
		brick.CFrame = CFrame.lookAt(brickWorldPosition, playerHrpPosition)
	else

		brick.CFrame = brickWorldCFrameOriginal
	end

	brick.Parent = game.Workspace
	return brick, pos + brick.Size 
end


local function buildWall(cf, playerHrpPosition)
	local color = BrickColor.random()
	local bricks = {}

	assert(WALL_WIDTH_STUDS > 0, "Wall width must be positive")

	local currentY = 0
	while currentY < WALL_HEIGHT_STUDS do
		local p_for_y_update
		local currentX = -WALL_WIDTH_STUDS / 2
		while currentX < WALL_WIDTH_STUDS / 2 do
			local brick
			brick, p_for_y_update = placeBrick(cf, Vector3.new(currentX, currentY - 2, 0), color, playerHrpPosition)

			currentX = currentX + BRICK_DIM_X 
			table.insert(bricks, brick)

			task.wait(BRICK_BUILD_SPEED)
		end
		currentY = currentY + BRICK_DIM_Y 
	end
	return bricks
end


function Wall.new(plr: Player)
	local self = setmetatable({}, Wall)

	self.Char = plr.Character or plr.CharacterAdded:Wait()
	self.Humanoid = self.Char:WaitForChild("Humanoid")
	local hrp = self.Char:WaitForChild("HumanoidRootPart")

	local animator = self.Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		self.AnimTrack = animator:LoadAnimation(Anim)
		self.AnimTrack:Play()
	end

	self.LookPos = hrp.CFrame.LookVector * Distance 

	local forwardVec = hrp.CFrame.LookVector
	local upVec = hrp.CFrame.UpVector
	local rightVec = hrp.CFrame.RightVector

	local wallFootPrintCenter = (hrp.Position - Vector3.new(0, hrp.Size.Y / 2, 0)) + forwardVec * (Distance + BRICK_DIM_Z / 2)

	local wallBuildOriginCF = CFrame.fromMatrix(wallFootPrintCenter, rightVec, upVec, forwardVec)

	local builtBricks = buildWall(wallBuildOriginCF, hrp.Position)

	task.delay(0.2, function()
		if self.AnimTrack and self.AnimTrack.IsPlaying then
			self.AnimTrack:Stop()
		end
	end)

	task.delay(Duration, function()
		for _, brick in builtBricks do
			if brick and brick.Parent then
				brick:Destroy()
			end
		end
	end)

	return self
end

return Wall
