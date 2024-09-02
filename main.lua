-- This addon lets you set your goals for daily grind (number of items) and informs when its reached.

-- Global variable so other addons / scripts could adress main code
GrindGoals = GrindGoals or {}
-- Create variable for information storage.
GrindGoalsDB = GrindGoalsDB or {}
-- This global is for saving which frame displays on top
GrindGoalsTopmostFrame = nil

-- Function that checks how many of certan item player has in his bags
local function countItemsInBags(itemID)
    if itemID == nil then
        return nil
    end
    local count = 0
    for bag = 0, 5 do -- Loop through all bags
        for slot = 1, C_Container.GetContainerNumSlots(bag) do -- Loop through all slots in the bag
            local id = C_Container.GetContainerItemID(bag, slot)
            if id == itemID then
                count = count + C_Container.GetContainerItemInfo(bag, slot).stackCount
            end
        end
    end
    return count
end

--Create main frame for addon
GrindGoals.mainFrame = CreateFrame("Frame", "GrindGoalsMainFrame", UIParent, "BasicFrameTemplateWithInset")
GrindGoals.mainFrame:SetSize(400, 250)
GrindGoals.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
GrindGoals.mainFrame.TitleBg:SetHeight(30)
GrindGoals.mainFrame.title = GrindGoals.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.mainFrame.title:SetPoint("TOP", GrindGoals.mainFrame.TitleBg, "CENTER", 0, 10)
GrindGoals.mainFrame.title:SetText("GrindGoals")
GrindGoals.mainFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
GrindGoals.mainFrame:Hide() -- Frame is hidden by default
-- Making frame movable
GrindGoals.mainFrame:EnableMouse(true)
GrindGoals.mainFrame:SetMovable(true)
GrindGoals.mainFrame:RegisterForDrag("LeftButton")
GrindGoals.mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
GrindGoals.mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Display frame on top if interracted with
GrindGoals.mainFrame:SetScript("OnMouseDown", function(self)
    if GrindGoalsTopmostFrame then
        GrindGoalsTopmostFrame:SetFrameLevel(1)  -- Reset the previous top frame's level
    end
    self:SetFrameStrata("HIGH")  -- Adjust this as needed
    self:SetFrameLevel(100)  -- Push the current frame to the top
    GrindGoalsTopmostFrame = self  -- Set this frame as the new topmost
end)

-- Adding frame to WoW special list to make it closeable by Esc
table.insert(UISpecialFrames, "GrindGoalsMainFrame")

-- Making frame resizable
local resizeHandle = CreateFrame("Frame", "ResizeHandle", GrindGoals.mainFrame)
resizeHandle:SetSize(16, 16)
resizeHandle:SetPoint("BOTTOMRIGHT", GrindGoals.mainFrame, "BOTTOMRIGHT", -4, 4)
local isResizing = false
local function OnMouseDown(self, button)
    if button == "LeftButton" then
        isResizing = true
        self:GetParent()._resizeStartWidth = self:GetParent():GetWidth()
        self:GetParent()._resizeStartHeight = self:GetParent():GetHeight()
        self:GetParent()._resizeStartX, self:GetParent()._resizeStartY = GetCursorPosition()
    end
end

local function OnMouseUp(self, button)
    if button == "LeftButton" then
        isResizing = false
        self:GetParent():StopMovingOrSizing()
    end
end

local function OnUpdate(self)
    if isResizing then
        local x, y = GetCursorPosition()
        local scale = self:GetParent():GetEffectiveScale()
        local dx = (x - self:GetParent()._resizeStartX) / scale
        local dy = (y - self:GetParent()._resizeStartY) / scale
        local newWidth = self:GetParent()._resizeStartWidth + dx
        local newHeight = self:GetParent()._resizeStartHeight - dy
        
        self:GetParent():SetSize(math.max(100, newWidth), math.max(100, newHeight))
    end
end

resizeHandle:SetScript("OnMouseDown", OnMouseDown)
resizeHandle:SetScript("OnMouseUp", OnMouseUp)
resizeHandle:SetScript("OnUpdate", OnUpdate)

-- Making addon recognize slash commands.
SLASH_GRINDGOALS1 = "/g"
SLASH_GRINDGOALS2 = "/grind"
SlashCmdList["GRINDGOALS"] = function(msg)
    if msg == "" then
        if GrindGoals.mainFrame:IsShown() then
            GrindGoals.mainFrame:Hide()
        else
            GrindGoals.mainFrame:Show()
        end
    elseif msg == "settings" then
        -- If the 'settings' argument is provided, open the settings
        SlashCmdList["MYADDONSETTINGS"]()
    else
        -- If invalid argument is provided
        print("Invalid command usage.")
    end
end


GrindGoals.mainFrame:SetScript("OnHide", function() -- On hide.
    PlaySound(808)
end)
GrindGoals.mainFrame:SetScript("OnShow", function() -- On show.
    PlaySound(808)
end)

--                                         !!! Content of main frame !!!

GrindGoals.mainFrame.boxString = GrindGoals.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.mainFrame.boxString:SetPoint("TOPLEFT", GrindGoals.mainFrame, "TOPLEFT", 15, -35)
GrindGoals.mainFrame.boxString:SetText("Item to grind:")

-- Create box for item player wants to farm
local itemBox = CreateFrame("EditBox", "ItemBox", GrindGoals.mainFrame, "InputBoxTemplate")
itemBox:SetSize(300, 50)
itemBox:SetPoint("TOPLEFT", GrindGoals.mainFrame.boxString, "TOPLEFT", 0, 0)
itemBox:SetMaxLetters(200)
itemBox:SetAutoFocus(false)
itemBox:SetText("")
-- Tooltip
itemBox:SetScript("OnEnter", function(self)  
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if GrindGoals.itemOfInterestID then
        GameTooltip:SetItemByID(GrindGoals.itemOfInterestID) -- Show item tooltip
    else
        GameTooltip:SetText("Link item you want to farm", nil, nil, nil, nil, true) --Else show message
    end
end)    
itemBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.mainFrame.itemCountString = GrindGoals.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.mainFrame.itemCountString:SetPoint("TOPLEFT", itemBox, "TOPLEFT", 0, -40)
GrindGoals.mainFrame.itemCountString:SetText("Number in bags: " .. (countItemsInBags(GrindGoals.itemOfInterestID) or 0))

-- Script for updating mainFrame when it is opened
itemBox:SetScript("OnShow", function()
    GrindGoals.mainFrame.itemCountString:SetText("Number in bags: " .. (countItemsInBags(GrindGoals.itemOfInterestID) or 0))
end)


--                                               !!! EVENTS !!! 

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "GrindGoalsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

    -- Handle linking item into item box
    if  event == "GLOBAL_MOUSE_UP"  and IsShiftKeyDown() and GrindGoals.mainFrame:IsShown() and itemBox:HasFocus() then
        local frame = GetMouseFoci()[1] -- Get frame under the mouse position
        if (
                frame and frame:GetParent() and frame:GetParent():GetName() 
                and string.match(frame:GetParent():GetName(), "ContainerFrame") -- If frame is slot in bag
            ) then 
            local bagID = frame:GetParent():GetID()     -- Get the bag ID from the parent frame
            local slot = frame:GetID()                  -- Get the slot ID from the frame itself
            if bagID and slot then
                local itemID = C_Container.GetContainerItemID(bagID, slot)
                if itemID then
                    local _, itemlink = C_Item.GetItemInfo(itemID)
                    itemBox:SetText("")
                    itemBox:Insert(itemlink)  -- Insert item link into item box
                    StackSplitFrame:Hide() -- Hide WoW API frame for splitting stacks on Shift+LClick
                    GrindGoals.itemOfInterestID = itemID -- Saving itemID to global
                end
            end
        elseif frame and frame:GetParent() and frame:GetParent():GetName() then
            print("----------")
            print("Frame Name: " .. frame:GetName())
        end
    end


    if GrindGoals.mainFrame:IsShown() then
        GrindGoals.mainFrame.itemCountString:SetText("Number in bags: " .. (countItemsInBags(GrindGoals.itemOfInterestID) or 0))
    end

end




eventListenerFrame:RegisterEvent("GLOBAL_MOUSE_UP")
eventListenerFrame:SetScript("OnEvent", eventHandler)



GrindGoals.mainFrame:Show()
