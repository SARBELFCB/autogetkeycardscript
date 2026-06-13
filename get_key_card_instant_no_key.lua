local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local function GetKeycard()
    local backpack  = LocalPlayer:FindFirstChildOfClass("Backpack")
    local character = LocalPlayer.Character

    -- Backpack and Character are checked together because a Tool migrates
    -- from Backpack to Character when equipped, so both containers must be
    -- searched to get a reliable presence result
    local existing = (backpack  and backpack:FindFirstChild("Key card"))
                  or (character and character:FindFirstChild("Key card"))

    if existing then
        -- Cloning the in-inventory instance rather than the original preserves
        -- any runtime state mutations that may have occurred since the game started
        local clone = existing:Clone()
        clone.Parent = backpack or LocalPlayer:WaitForChild("Backpack")
        return
    end

    -- Falling back to ReplicatedStorage guarantees we always work from a
    -- pristine, server-authoritative copy on the very first execution
    local original = ReplicatedStorage:FindFirstChild("Tools")
                     and ReplicatedStorage.Tools:FindFirstChild("Key card")

    if not original then
        warn("[Keycard] Source not found in ReplicatedStorage.Tools")
        return
    end

    -- Clone inherits all children (LocalScripts, RemoteEvents, values, meshes)
    -- because Clone() performs a deep copy of the entire instance tree
    local clone = original:Clone()
    clone.Parent = backpack or LocalPlayer:WaitForChild("Backpack")
end

-- CharacterAdded fires after the engine destroys the previous character and
-- constructs a fresh one, which also resets the Backpack, so re-granting here
-- covers every respawn without any extra death-detection logic
LocalPlayer.CharacterAdded:Connect(function()
    -- A brief yield lets the engine finish parenting the new Backpack instance
    -- before GetKeycard attempts to resolve it
    task.wait(0.5)
    GetKeycard()
end)

GetKeycard()
