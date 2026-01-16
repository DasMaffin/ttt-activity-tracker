local keysDown = {}
local function checkKey(key)
    if input.IsButtonDown(key) and not keysDown[key] then
        keysDown[key] = true
        hook.Run("keyPressed", key)
    elseif not input.IsButtonDown(key) then
        keysDown[key] = false
        hook.Run("keyReleased", key)
    end
end

hook.Add("Think", "InputManagerActivityTracker", function()
    if ULib and ulx and LocalPlayer():IsSuperAdmin() then
        checkKey(KEY_F2)
    end
end)

hook.Add("keyPressed", "OnKeyPressedActivityTracker", function(key)
    local switch = {
        [KEY_F2] = function() 
            ActivityTracker:TogglePanel()
        end
    }
    if switch[key] then
        switch[key]()
    end
end)

hook.Add("keyReleased", "InputManager_Debug", function(key)
    
end)