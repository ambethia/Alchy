local ADDON, NS = ...
-- local L = NS.L

local currentStep = 0

local TRANSMUTE_BAG_OF_ANCHORS_SPELL_ID = 286547

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local function IsTransmuteBagOfAnchorsAvailable()
  if IsPlayerSpell(TRANSMUTE_BAG_OF_ANCHORS_SPELL_ID) then
    local start, duration = GetSpellCooldown(TRANSMUTE_BAG_OF_ANCHORS_SPELL_ID)
    local resetRemaining = GetQuestResetTime()
    local durationRemaining = ((start == 0 or duration == 0) and 0) or (duration - (GetTime() - start))
    local cooldownRemaining =
      (durationRemaining == 0 and 0) or (durationRemaining < 86400 and resetRemaining) or
      (durationRemaining > 86400 and math.floor(durationRemaining / 86400) * 86400 + resetRemaining)
    print(
      GetSpellLink(TRANSMUTE_BAG_OF_ANCHORS_SPELL_ID) ..
        " (" .. cooldownRemaining .. ") " .. SecondsToTime(cooldownRemaining)
    )
    return cooldownRemaining == 0
  else
    return false
  end
end

local function CreateAlchyButton()
  local button =
    CreateFrame("Button", ADDON .. "ButtonFrame", UIParent, "SecureActionButtonTemplate,ActionButtonTemplate")
  button:SetPoint("CENTER", 0, 0)
  button:SetAttribute("type1", "macro")
  button:SetAttribute("macrotext", "/cast Alchemy")
  button.icon:SetTexture("Interface\\ICONS\\inv_alchemy_70_blue")
  button:SetMovable(true)
  button:EnableMouse(true)
  button:RegisterForDrag("RightButton")
  button:SetScript("OnDragStart", button.StartMoving)
  button:SetScript("OnDragStop", button.StopMovingOrSizing)
  button:Hide()
  return button
end

local Alchy = CreateFrame("Frame", ADDON .. "Frame")

Alchy:SetScript(
  "OnEvent",
  function(self, event, ...)
    if self[event] then
      return self[event](self, ...)
    end
  end
)

Alchy.Update = function()
  if currentStep == 0 then
    Alchy.Button:SetAttribute("macrotext", "/script OpenAllBags()\n/run C_TradeSkillUI.CraftRecipe(286547)")
    currentStep = currentStep + 1
    return
  end

  if currentStep == 1 then
    Alchy.Button.icon:SetTexture("Interface\\ICONS\\inv_misc_coinbag01")
    Alchy.Button:SetAttribute("macrotext", "/use Bag of Anchors")
    currentStep = currentStep + 1
    return
  end

  if currentStep == 2 then
    Alchy.Button.icon:SetTexture("Interface\\ICONS\\inv_letter_22")
    Alchy.Button:SetAttribute(
      "macrotext",
      '/click MailFrameTab2\n/run for b=0,4 do for s=0,GetContainerNumSlots(b) do I=GetContainerItemLink(b,s) if I and I:find("Anchor Weed") then UseContainerItem(b,s) end end end\n/run  SendMail("Torculi", "Anchors", "")'
    )
    currentStep = currentStep + 1
    return
  end

  if currentStep == 3 then
    Alchy.Button.icon:SetTexture("Interface\\ICONS\\inv_pet_exitbattle")
    Alchy.Button:SetAttribute("macrotext", "/camp")
    currentStep = currentStep + 1
    return
  end
end

Alchy.Button = CreateAlchyButton()
Alchy.Button:HookScript(
  "OnClick",
  function(self)
    Alchy.Update()
  end
)

function Alchy:PLAYER_ENTERING_WORLD()
  if IsTransmuteBagOfAnchorsAvailable() then
    Alchy.Button:Show()
  else
    Alchy.Button:Hide()
  end
end
Alchy:RegisterEvent("PLAYER_ENTERING_WORLD")

ldb:NewDataObject(
  ADDON,
  {
    type = "data source",
    icon = "Interface\\Icons\\Spell_Nature_StormReach",
    OnClick = function(clickedframe, button)
      if Alchy.Button:IsVisible() then
        Alchy.Button:Hide()
      else
        Alchy.Button:Show()
      end
    end
  }
)
