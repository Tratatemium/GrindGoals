-- This is the file for Grind Goals addon item selection frame

--Create item selection frame for addon
GrindGoals.frames.itemSelectionFrame = CreateFrame("Frame", "GrindGoalItemSelectionFrame", GrindGoals.frames.mainFrame, "BasicFrameTemplateWithInset")
GrindGoals.frames.itemSelectionFrame:SetSize(350, 300)
GrindGoals.frames.itemSelectionFrame:SetPoint("CENTER", GrindGoals.frames.mainFrame, "CENTER", 40, -40)
GrindGoals.frames.itemSelectionFrame.TitleBg:SetHeight(30)
GrindGoals.frames.itemSelectionFrame.title = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.frames.itemSelectionFrame.title:SetPoint("TOP", GrindGoals.frames.itemSelectionFrame.TitleBg, "CENTER", 0, 10)
GrindGoals.frames.itemSelectionFrame.title:SetText("GrindGoals Item Selection")
GrindGoals.frames.itemSelectionFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
GrindGoals.frames.itemSelectionFrame:Hide() -- Frame is hidden by default
GrindGoals.frames.itemSelectionFrame:EnableMouse(true)

table.insert(UISpecialFrames, "GrindGoalItemSelectionFrame") -- Frame can be closed by ESC

GrindGoals.frames.itemSelectionFrame:SetScript("OnMouseDown", function(self)
    if not GrindGoals.frames.wrongItemFrame:IsShown() then
        GrindGoals.functions.setFrameOnTop(self)
    end
end)

GrindGoals.frames.itemSelectionFrame:SetScript("OnHide", function() -- On hide.
    PlaySound(808)
end)


--[[ 
    **************************************************
    * SECTION: selectionFrame contents
    **************************************************
--]]


GrindGoals.frames.itemSelectionFrame.itemSelectString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.itemSelectString:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame, "TOPLEFT", 15, -35)
GrindGoals.frames.itemSelectionFrame.itemSelectString:SetText("Choose an Item you want to farm \nby using one of theese methods:")

-- *** Item Id Checkbox ***

local itemIDCheckbox = CreateFrame("CheckButton", "itemIDCheckbox", GrindGoals.frames.itemSelectionFrame, "UIRadialButtonTemplate")
itemIDCheckbox:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame, "TOPLEFT", 15, -75)

GrindGoals.frames.itemSelectionFrame.itemIDString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.itemIDString:SetPoint("LEFT", itemIDCheckbox, "CENTER", 15, 0)
GrindGoals.frames.itemSelectionFrame.itemIDString:SetText("Item ID:")

local itemIDEditbox = CreateFrame("EditBox", "itemIDEditbox", GrindGoals.frames.itemSelectionFrame, "InputBoxTemplate")
itemIDEditbox:SetSize(80, 20)
itemIDEditbox:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame.itemIDString, "TOPLEFT", 0, -20)
itemIDEditbox:SetMaxLetters(10)
itemIDEditbox:SetScript("OnEnter", function(self)     -- * Tooltip *
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    GameTooltip:SetText("Type here item ID of the item you want to farm.", nil, nil, nil, nil, true)
end)
itemIDEditbox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end) 

-- *** Item Link Checkbox ***

local itemLinkCheckbox = CreateFrame("CheckButton", "itemLinkCheckbox", GrindGoals.frames.itemSelectionFrame, "UIRadialButtonTemplate")
itemLinkCheckbox:SetPoint("TOPLEFT", itemIDCheckbox, "TOPLEFT", 0, -50)

GrindGoals.frames.itemSelectionFrame.itemLinkString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.itemLinkString:SetPoint("LEFT", itemLinkCheckbox, "CENTER", 15, 0)
GrindGoals.frames.itemSelectionFrame.itemLinkString:SetText("Item Link:")

local itemLinkEditbox = CreateFrame("EditBox", "itemLinkEditbox", GrindGoals.frames.itemSelectionFrame, "InputBoxTemplate")
itemLinkEditbox:SetSize(250, 20)
itemLinkEditbox:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame.itemLinkString, "TOPLEFT", 0, -20)
itemLinkEditbox:SetMaxLetters(200)
itemLinkEditbox:SetScript("OnEnter", function(self)     -- * Tooltip *
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    GameTooltip:SetText("Paste here Link for the item you want to farm\nOR\nlink it here from the inventory by using Shift + L_Click on item\n*** may not work with all inventory addons!", nil, nil, nil, nil, true)
end)
itemLinkEditbox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- TODO : *** Item Name Checkbox ***

local itemNameCheckbox = CreateFrame("CheckButton", "itemNameCheckbox", GrindGoals.frames.itemSelectionFrame, "UIRadialButtonTemplate")
itemNameCheckbox:SetPoint("TOPLEFT", itemLinkCheckbox, "TOPLEFT", 0, -50)

GrindGoals.frames.itemSelectionFrame.itemNameString = GrindGoals.frames.itemSelectionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.itemSelectionFrame.itemNameString:SetPoint("LEFT", itemNameCheckbox, "CENTER", 15, 0)
GrindGoals.frames.itemSelectionFrame.itemNameString:SetText("Item Name (Not working):")

local itemNameEditbox = CreateFrame("EditBox", "itemIDEditbox", GrindGoals.frames.itemSelectionFrame, "InputBoxTemplate")
itemNameEditbox:SetSize(250, 20)
itemNameEditbox:SetPoint("TOPLEFT", GrindGoals.frames.itemSelectionFrame.itemNameString, "TOPLEFT", 0, -20)
itemNameEditbox:SetMaxLetters(200)
itemNameEditbox:SetScript("OnEnter", function(self)     -- * Tooltip *
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    GameTooltip:SetText("Type here name... Actually, don't.", nil, nil, nil, nil, true)
end)
itemNameEditbox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

--  *** Checkbox switching ***

local itemCheckboxes = {                                    -- This table helps with cwitching boxes on/off when one of them is pressed
    {
        checkboxName = itemIDCheckbox,
        editboxName = itemIDEditbox,
    },
    {
        checkboxName = itemLinkCheckbox,
        editboxName = itemLinkEditbox,
    },
    {
        checkboxName = itemNameCheckbox,
        editboxName = itemNameEditbox,
    },
}

local function checked(self)                               -- Function to toogle off other check boxed and editboxes
    for _, itemCheckbox in pairs(itemCheckboxes) do
        if itemCheckbox.checkboxName ~= self then
            itemCheckbox.checkboxName:SetChecked(false)
            itemCheckbox.editboxName:Disable()
            itemCheckbox.editboxName:SetText("")
        else
            itemCheckbox.checkboxName:SetChecked(true)     -- Maintain toogle on and cursor focus on the one clicked
            itemCheckbox.editboxName:Enable()
            itemCheckbox.editboxName:SetFocus()
        end        
    end
end

GrindGoals.frames.itemSelectionFrame:SetScript("OnShow", function ()  -- On showing Item Selection Frame
    PlaySound(808)
    GrindGoals.functions.setFrameOnTop(GrindGoals.frames.itemSelectionFrame)   -- Put it on top

    for _, itemCheckbox in pairs(itemCheckboxes) do  -- Reset checkboxes and editboxes

        itemCheckbox.editboxName:Disable()
        itemCheckbox.editboxName:SetText("")

        itemCheckbox.checkboxName:SetChecked(false)
        itemCheckbox.checkboxName:SetScript("OnClick", function(self)
            PlaySound(808)
            checked(self)
        end)
        itemCheckbox.editboxName:SetScript("OnMouseUp", function()  -- Switching also works on klicking the editBox
            PlaySound(808)
            checked(itemCheckbox.checkboxName)
        end)
    end    
end)

-- *** Error Frame ***

GrindGoals.frames.wrongItemFrame = CreateFrame("Frame", "GrindGoals.frames.wrongItemFrame", GrindGoals.frames.itemSelectionFrame, "BackdropTemplate") -- Frame to show wrong number message
GrindGoals.frames.wrongItemFrame:SetSize(270, 110)
GrindGoals.frames.wrongItemFrame:SetPoint("CENTER", GrindGoals.frames.itemSelectionFrame, "CENTER", 0, 0) 
GrindGoals.frames.wrongItemFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
GrindGoals.frames.wrongItemFrame:SetBackdropColor(0, 0, 0, 1) 
GrindGoals.frames.wrongItemFrame.errorString = GrindGoals.frames.wrongItemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.wrongItemFrame.errorString:SetPoint("CENTER", GrindGoals.frames.wrongItemFrame, "CENTER", 0, 20)
GrindGoals.frames.wrongItemFrame:SetScript("OnShow", function (self)
    GrindGoals.functions.setFrameOnTop(self)
    PlaySound(850)
end)

local wrongItemOkButton = CreateFrame("Button", "wrongItemOkButton", GrindGoals.frames.wrongItemFrame, "UIPanelButtonTemplate") -- OK button
wrongItemOkButton:SetPoint("CENTER", GrindGoals.frames.wrongItemFrame, "CENTER", 0, -15)
wrongItemOkButton:SetSize(125, 35)
wrongItemOkButton:SetText("OK")
wrongItemOkButton:SetNormalFontObject("GameFontNormalLarge")
wrongItemOkButton:SetHighlightFontObject("GameFontHighlightLarge")
wrongItemOkButton:SetScript("OnClick", function()
    PlaySound(808)
    GrindGoals.frames.wrongItemFrame:Hide()
    for _, itemCheckbox in pairs(itemCheckboxes) do
        if itemCheckbox.checkboxName:GetChecked() then  -- if error is wrong input set cursor and highlight wrong text
            itemCheckbox.editboxName:HighlightText()
            itemCheckbox.editboxName:SetFocus()
        end
    end
end)
GrindGoals.frames.wrongItemFrame:Hide()

-- *** "Select" button ***

local lockInItemButton = CreateFrame("Button", "lockInItemButton", GrindGoals.frames.itemSelectionFrame, "UIPanelButtonTemplate")
lockInItemButton:SetPoint("BOTTOMLEFT", GrindGoals.frames.itemSelectionFrame, "BOTTOMLEFT", 20, 20)
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
lockInItemButton:SetScript("OnClick", function()            -- script on clicking button
    if itemIDCheckbox:GetChecked() then                     -- if item ID is selected        
        local itemID = itemIDEditbox:GetText()
        if C_Item.GetItemInfoInstant(itemID) ~= nil then    -- check if the item ID is correct
            GrindGoalsDB.itemToFarmID = tonumber(itemID)
            GrindGoals.frames.itemSelectionFrame:Hide()
            GrindGoals.functions.updateMainframe()
        elseif itemID == "" then
            GrindGoals.frames.wrongItemFrame.errorString:SetText("You must choose the item first!")
            GrindGoals.frames.wrongItemFrame:Show()
        else
            GrindGoals.frames.wrongItemFrame.errorString:SetText("Can't match this ID with any item!")
            GrindGoals.frames.wrongItemFrame:Show()
        end
    elseif itemLinkCheckbox:GetChecked() then               -- if item Link is selected 
        local itemLink = itemLinkEditbox:GetText()
        if C_Item.GetItemInfoInstant(itemLink) ~= nil then   -- try to get ID from correct link
            local itemID = C_Item.GetItemInfoInstant(itemLink)
            GrindGoalsDB.itemToFarmID = tonumber(itemID)
            GrindGoals.frames.itemSelectionFrame:Hide()
            GrindGoals.functions.updateMainframe()
        elseif itemLink == "" then                            -- check if input is empty
            GrindGoals.frames.wrongItemFrame.errorString:SetText("You must choose the item first!")
            GrindGoals.frames.wrongItemFrame:Show()
        elseif itemLink:match("|A:Professions-") ~= nil then          -- if it is a link to profession item with quality tier
                local itemName = itemLink:match("%[(.-)%s*|A:")   -- get item name
                -- Check if itemName ends with any extra characters and trim if needed
                if itemName then
                    itemName = itemName:match("^[^|]*")  -- Ensure we only get text before any remaining pipe character
                end
                if itemName then
                    itemName = itemName:match("^[%s]*(.-)[%s]*$") -- trim whitespaces
                end
                local qualityTier = itemLink:match("Quality%-Tier(%d)")  -- get quality tier
                if itemName and qualityTier and C_Item.GetItemInfoInstant(itemName) ~= nil then
                    local _, itemLinkCached = C_Item.GetItemInfo(itemName)     -- get item from cache by name (can be another item with same name)
                    local qualityTierCached = itemLinkCached:match("Quality%-Tier(%d)")
                    local itemIDCached = C_Item.GetItemInfoInstant(itemName)  -- get ID from cache
                    local qualityDiff = tonumber(qualityTier) - tonumber(qualityTierCached) -- calculate difference in quality tier
                    GrindGoalsDB.itemToFarmID = tonumber(itemIDCached) + qualityDiff  -- modify ID (IDs go one after another by quality tiers for crafting items)
                    GrindGoals.frames.itemSelectionFrame:Hide()
                    GrindGoals.functions.updateMainframe()
                end
        elseif itemLink:match("%[(.-)%]") and C_Item.GetItemInfoInstant(itemLink:match("%[(.-)%]")) ~= nil then --try to get ID from item name
            local itemID = C_Item.GetItemInfoInstant(itemLink:match("%[(.-)%]"))
            GrindGoalsDB.itemToFarmID = tonumber(itemID)
            GrindGoals.frames.itemSelectionFrame:Hide()
            GrindGoals.functions.updateMainframe()
        else
            GrindGoals.frames.wrongItemFrame.errorString:SetText("Can't match this Link with any item!")
            GrindGoals.frames.wrongItemFrame:Show()
        end
    elseif itemNameCheckbox:GetChecked() then               -- TODO : if item Name is selected 
        GrindGoals.frames.wrongItemFrame.errorString:SetText("This feature is not added yet :(")
        GrindGoals.frames.wrongItemFrame:Show()
    else
        GrindGoals.frames.wrongItemFrame.errorString:SetText("You must choose the item first!")
        GrindGoals.frames.wrongItemFrame:Show()
    end
end)




--[[ 
    **************************************************
    * SECTION: selectionFrame events
    **************************************************
--]]

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "GrindGoalsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

    -- Handle linking item into item box
    if  event == "GLOBAL_MOUSE_UP"  and IsShiftKeyDown() and GrindGoals.frames.itemSelectionFrame:IsShown() and itemLinkCheckbox:GetChecked() then
        local frame = GetMouseFoci()[1] -- Get frame under the mouse position
        if (
                frame and frame:GetParent() 
                and not string.match(frame:GetParent():GetName() or "", "MultiBar") -- If frame is not a action bar slot
            ) then 
            local bagID = frame:GetParent():GetID()     -- Get the bag ID from the parent frame
            local slot = frame:GetID()                  -- Get the slot ID from the frame itself
            if bagID and slot then
                local itemID = C_Container.GetContainerItemID(bagID, slot)
                if itemID then
                    local _, itemlink = C_Item.GetItemInfo(itemID)
                    itemLinkEditbox:SetText("")
                    itemLinkEditbox:Insert(itemlink)  -- Insert item link into item box
                    StackSplitFrame:Hide() -- Hide WoW API frame for splitting stacks on Shift+LClick
                end
            end
        end
    end
end

eventListenerFrame:RegisterEvent("GLOBAL_MOUSE_UP")
eventListenerFrame:SetScript("OnEvent", eventHandler)