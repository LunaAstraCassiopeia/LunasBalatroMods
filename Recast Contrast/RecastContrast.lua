--- STEAMODDED HEADER
--- MOD_NAME: Luna's Recontrast
--- MOD_ID: RecastContrast
--- MOD_AUTHOR: [LunaAstraCassiopeia]
--- MOD_DESCRIPTION: Modified high-contrast card textures to be more in line with the colors of Sin Jokers.

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.RecastContrast()

    local contrast_mod = SMODS.findModByID("RecastContrast")
    local card_contrast = SMODS.Sprite:new("cards_2", contrast_mod.path, "EnhancedContrast.png", 71, 95, "asset_atli")
    
    card_contrast:register()
end

----------------------------------------------
------------MOD CODE END----------------------
