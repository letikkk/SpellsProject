local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SpellsInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("InfoAboutSpells"):WaitForChild("SpellsInfo"))
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local playerGui = Player.PlayerGui
local SpellsGui = playerGui:WaitForChild("SpellGui")
local plrSpell = Player:WaitForChild("CurrentSpell")
local Cooldown = false

local function GetCooldown()
	for i, v in plrSpell:GetChildren() do
		return SpellsInfo[v.Name].Cooldown
	end
end

local function GetSpellName()
	for i, v in plrSpell:GetChildren() do
		return v.Name
	end
end

if #plrSpell:GetChildren() > 0 then
	SpellsGui.Enabled = true
end
plrSpell.ChildAdded:Connect(function()
	SpellsGui.Enabled = true
end)

UserInputService.InputBegan:Connect(function(input, chat)
	if input.KeyCode ~= Enum.KeyCode.F or chat or Cooldown or GetSpellName() == nil then return end
	
	--Char:WaitForChild("DirMovement").Enabled = false
	task.delay(SpellsInfo[GetSpellName()].Duration + 0.5, function()
		--Char:WaitForChild("DirMovement").Enabled = true
	end)
	local MousePos = UserInputService:GetMouseLocation()
	local MousePos3D = workspace.CurrentCamera:ViewportPointToRay(MousePos.X, MousePos.Y)
	
	ReplicatedStorage.Events.ServerCast:FireServer(GetSpellName(), MousePos3D)
	SpellsGui.SpellFrame.CooldownFrame.Size = UDim2.new(1, 0, 0, 0)
	TweenService:Create(SpellsGui.SpellFrame.CooldownFrame, TweenInfo.new(GetCooldown()), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	
	Cooldown = true
	task.wait(GetCooldown())
	Cooldown = false

	
	
end)