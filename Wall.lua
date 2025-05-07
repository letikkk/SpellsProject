local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local Ragdoll = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Ragdoll"))
local MuchachoHitbox = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MuchachoHitbox"))
local Wall = {}
Wall.__index = Wall

local Duration = SpellsInfo.Wall.Duration
local Anim = ReplicatedStorage.Animations.Grab -- Assuming this animation is intended
local Distance = 10 


local WALL_WIDTH_STUDS = 18
local WALL_HEIGHT_STUDS = 10
local BRICK_BUILD_SPEED = 0.04 

local BRICK_DIM_X = 2 
local BRICK_DIM_Y = 2 
local BRICK_DIM_Z = 1 

-- Modified placeBrick to accept playerHrpPosition
local function placeBrick(cf, pos, color, playerHrpPosition)
	local brick = Instance.new("Part")
	brick.Size = Vector3.new(BRICK_DIM_X, BRICK_DIM_Y, BRICK_DIM_Z)
	brick.BrickColor = color
	brick.Material = Enum.Material.Plastic
	brick.Anchored = true

	-- Calculate the world position where the center of the brick should be
	local brickCenterInWallLocalSpace = pos + brick.Size / 2 -- brick.Size is (BRICK_DIM_X, BRICK_DIM_Y, BRICK_DIM_Z)
	local brickWorldCFrameOriginal = cf * CFrame.new(brickCenterInWallLocalSpace)
	local brickWorldPosition = brickWorldCFrameOriginal.Position

	-- Set the CFrame to be at brickWorldPosition and look at the playerHrpPosition
	if playerHrpPosition then
		brick.CFrame = CFrame.lookAt(brickWorldPosition, playerHrpPosition)
	else
		-- Fallback if playerHrpPosition is not provided, though it should be
		brick.CFrame = brickWorldCFrameOriginal
	end

	brick.Parent = game.Workspace
	return brick, pos + brick.Size -- Returns the brick and the top-right-far corner relative to cf's local space for next placement calculation
end

-- Modified buildWall to accept and pass playerHrpPosition
local function buildWall(cf, playerHrpPosition)
	local color = BrickColor.random()
	local bricks = {}

	assert(WALL_WIDTH_STUDS > 0, "Wall width must be positive")

	local currentY = 0
	while currentY < WALL_HEIGHT_STUDS do
		local p_for_y_update -- Stores the Vector3 (pos + brick.Size) from placeBrick, used to update currentY and currentX
		local currentX = -WALL_WIDTH_STUDS / 2
		while currentX < WALL_WIDTH_STUDS / 2 do
			local brick
			-- Pass playerHrpPosition to placeBrick
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

	if not (self.Humanoid and hrp) then
		warn("Wall.new: Humanoid or HumanoidRootPart not found for player: " .. plr.Name)
		return self 
	end

	local animator = self.Humanoid:FindFirstChildOfClass("Animator")
	if animator then
		self.AnimTrack = animator:LoadAnimation(Anim)
		self.AnimTrack:Play()
	else
		warn("Wall.new: Animator not found on Humanoid for player: " .. plr.Name)
		self.AnimTrack = nil 
	end

	self.LookPos = hrp.CFrame.LookVector * Distance 

	local forwardVec = hrp.CFrame.LookVector
	local upVec = hrp.CFrame.UpVector
	local rightVec = hrp.CFrame.RightVector

	local wallFootPrintCenter = (hrp.Position - Vector3.new(0, hrp.Size.Y / 2, 0)) + forwardVec * (Distance + BRICK_DIM_Z / 2)

	local wallBuildOriginCF = CFrame.fromMatrix(wallFootPrintCenter, rightVec, upVec, forwardVec)

	-- Pass hrp.Position to buildWall
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
