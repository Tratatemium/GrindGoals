-- This is the file for Grind Goals addon item selection frame

--Create item selection frame for addon
GrindGoals.frames.itemSelectionFrame = CreateFrame("Frame", "GrindGoalItemSelectionFrame", GrindGoals.frames.mainFrame, "BasicFrameTemplateWithInset")
GrindGoals.frames.itemSelectionFrame:SetSize(400, 250)
GrindGoals.frames.itemSelectionFrame:SetPoint("CENTER", GrindGoals.frames.mainFrame, "CENTER", 40, -40)
GrindGoals.frames.itemSelectionFrame.TitleBg:SetHeight(30)
GrindGoals.frames.itemSelectionFrame.title = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.frames.itemSelectionFrame.title:SetPoint("TOP", GrindGoals.frames.itemSelectionFrame.TitleBg, "CENTER", 0, 10)
GrindGoals.frames.itemSelectionFrame.title:SetText("GrindGoals Item Selection")
GrindGoals.frames.itemSelectionFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
GrindGoals.frames.itemSelectionFrame:Hide() -- Frame is hidden by default
GrindGoals.frames.itemSelectionFrame:EnableMouse(true)

table.insert(UISpecialFrames, "GrindGoalItemSelectionFrame") -- Frame can be closed by ESC

GrindGoals.frames.itemSelectionFrame:SetScript("OnMouseDown", GrindGoals.functions.setFrameOnTop)

GrindGoals.frames.itemSelectionFrame:SetScript("OnHide", function() -- On hide.
    PlaySound(808)
end)
GrindGoals.frames.itemSelectionFrame:SetScript("OnShow", function() -- On show.
    PlaySound(808)
    GrindGoals.functions.setFrameOnTop(GrindGoals.frames.itemSelectionFrame)
end)

--                                         !!! Content of item selection frame !!!

GrindGoals.frames.itemSelectionFrame.boxString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.boxString:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame, "TOPLEFT", 15, -35)
GrindGoals.frames.itemSelectionFrame.boxString:SetText("Item to grind:")

-- Create box for item player wants to farm
local itemBox = CreateFrame("EditBox", "ItemBox", GrindGoals.frames.itemSelectionFrame, "InputBoxTemplate")
itemBox:SetSize(300, 50)
itemBox:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame.boxString, "TOPLEFT", 0, 0)
itemBox:SetMaxLetters(200)
itemBox:SetAutoFocus(true)
itemBox:SetText("")
-- Tooltip
itemBox:SetScript("OnEnter", function(self)  
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    if GrindGoals.itemOfInterestID then
        GameTooltip:SetItemByID(GrindGoals.itemOfInterestID) -- Show item tooltip
    else
        GameTooltip:SetText("Link here item you want to farm\nby using Shift + L_Click on item", nil, nil, nil, nil, true) --Else show message
    end
end)    
itemBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
itemBox:SetScript("OnTextChanged", function(self)
    local text = self:GetText()               -- delete itemID if no text in the item box
    if text == "" then
        GrindGoals.itemOfInterestID = nil
    end
    GrindGoals.frames.itemSelectionFrame.itemCountString:SetText(
        "Number in bags: " .. (GrindGoals.functions.countItemsInBags(GrindGoals.itemOfInterestID) or 0)     -- Number in bags
    )
end)

-- "Number in bags" string
GrindGoals.frames.itemSelectionFrame.itemCountString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.itemCountString:SetPoint("TOPLEFT", itemBox, "TOPLEFT", 0, -40)
GrindGoals.frames.itemSelectionFrame.itemCountString:SetText(
    "Number in bags: " .. (GrindGoals.functions.countItemsInBags(GrindGoals.itemOfInterestID) or 0)     -- Number in bags
)

-- "Select" button
local lockInItemButton = CreateFrame("Button", "lockInItemButton", GrindGoals.frames.itemSelectionFrame, "UIPanelButtonTemplate")
lockInItemButton:SetPoint("LEFT", GrindGoals.frames.itemSelectionFrame.itemCountString, "LEFT", -0, -30)
lockInItemButton:SetSize(100, 40)
lockInItemButton:SetText("Select")
lockInItemButton:SetNormalFontObject("GameFontNormalLarge")
lockInItemButton:SetHighlightFontObject("GameFontHighlightLarge")
lockInItemButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -10, 10)
    GameTooltip:SetText("Lock in item you want to farm.", nil, nil, nil, nil, true)
end)
lockInItemButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
lockInItemButton:SetScript("OnClick", function() -- script on clicking button
    GrindGoalsDB.itemToFarmID = GrindGoals.itemOfInterestID
    GrindGoals.frames.itemSelectionFrame:Hide()
    GrindGoals.functions.updateMainframe()
    print("Check!")
end)

-- Script for updating item box when it is opened
itemBox:SetScript("OnShow", function()
    GrindGoals.frames.itemSelectionFrame.itemCountString:SetText("Number in bags: " .. 
        (GrindGoals.functions.countItemsInBags(GrindGoals.itemOfInterestID) or 0)         -- Number in bags
    )
end)




--                                               !!! EVENTS !!! 

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "GrindGoalsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

    -- Handle linking item into item box
    if  event == "GLOBAL_MOUSE_UP"  and IsShiftKeyDown() and GrindGoals.frames.itemSelectionFrame:IsShown() and itemBox:HasFocus() then
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
        end
    end


    if GrindGoals.frames.itemSelectionFrame:IsShown() then
        GrindGoals.frames.itemSelectionFrame.itemCountString:SetText("Number in bags: " .. (
            GrindGoals.functions.countItemsInBags(GrindGoals.itemOfInterestID) or 0) -- Number in bags
        )
    end

end




eventListenerFrame:RegisterEvent("GLOBAL_MOUSE_UP")
eventListenerFrame:SetScript("OnEvent", eventHandler)