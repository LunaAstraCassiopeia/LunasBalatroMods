--- STEAMODDED HEADER
--- MOD_NAME: Luna's Enhancedments
--- MOD_ID: EnhancedEnhancements
--- MOD_AUTHOR: [LunaAstraCassiopeia]
--- MOD_DESCRIPTION: Modified enhancement textures to fit the pattern of changing the material of the cards. Also, changes the high contrast card textures.

----------------------------------------------
------------MOD CODE -------------------------

function SMODS.INIT.EnhancedEnhancements()

    local enhancement_mod = SMODS.findModByID("EnhancedEnhancements")
    local sprite_enhancer = SMODS.Sprite:new("centers", enhancement_mod.path, "Enhancedments.png", 71, 95, "asset_atli")
    local card_contrast = SMODS.Sprite:new("cards_2", enhancement_mod.path, "EnhancedContrast.png", 71, 95, "asset_atli")
    local ui_contrast = SMODS.Sprite:new("ui_2", enhancement_mod.path, "EnhancedUIContrast.png", 18, 18, "asset_atli")
    
    sprite_enhancer:register()
    card_contrast:register()
    ui_contrast:register()
end

----------------------------------------------
------------MOD CODE END----------------------
