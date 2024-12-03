--- STEAMODDED HEADER
--- MOD_NAME: The Dread Jokers
--- MOD_ID: FearJokers
--- PREFIX: tma
--- MOD_AUTHOR: [LunaAstraCassiopeia]
--- MOD_DESCRIPTION: Some Jokers inspired by the Magnus Archives podcast
--- BADGE_COLOR: 56A786
--- VERSION: 1.1.1
--- DEPENDENCIES: [Talisman>=2.0.0-beta5]

----------------------------------------------
------------MOD CODE -------------------------



    SMODS.Atlas({
        key = 'tma_tarot',
        path = 'Tarots.png',
        px = 71,
        py = 95
    })
    SMODS.Atlas({
        key = 'tma_joker',
        path = 'Jokers.png',
        px = 71,
        py = 95
    })
    SMODS.Atlas({
        key = 'modicon',
        path = 'modicon.png',
        px = '34',
        py = '34'
    })
    

    local function forced_message(message, card, color, delay, juice)
        if delay == true then
            delay = 0.7 * 1.25
        elseif delay == nil then
            delay = 0
        end
    
        G.E_MANAGER:add_event(Event({trigger = 'before', delay = delay, func = function()
    
            if juice then card:juice_up(0.7) end
    
            card_eval_status_text(
                card,
                'extra',
                nil, nil, nil,
                {message = message, colour = color, instant = true}
            )
            return true
        end}))
    end

    -- Adding Jokers
    local card_add_deck = Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        if not self.added_to_deck then
            if self.ability.name == 'j_tma_Piper' then
                G.hand:change_size(self.ability.extra.h_size)
            end
        end
        return card_add_deck(self, from_debuff)
    end
    -- Losing Jokers
    local card_remove_deck = Card.remove_from_deck
    function Card:remove_from_deck(from_debuff)
        if self.added_to_deck then
            if self.ability.name == 'j_tma_Piper' then
                G.hand:change_size(-self.ability.extra.h_size)
            end
            if not from_debuff then
                for k, v in pairs(G.jokers.cards) do
                    if v.ability.name == 'j_tma_Mannequin' and self.ability.name ~= 'j_tma_Mannequin' then 
                        v.ability.extra.last_sold = self
                    end
                end
                if self.ability.set == "Joker" or self.ability.set == "Statement" then 
                    G.GAME.last_sold_joker = self
                end
            end
            if self.ability.set == "Statement" then
                if self.ability.extra.active and self.ability.name == "c_tma_glimmer" then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    for k, v in ipairs(self.ability.extra.enhancedjokers) do
                        v:set_edition(nil, true)
                    end
                    return true end }))
                end
                
            end
        end
        return card_remove_deck(self, from_debuff)
    end

    -- Cool Straights :))))
    local cool_get_straight = get_straight
    function get_straight(hand)
        local wildrank = false
	if G.consumeables then
        for i=1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.name == "c_tma_morph" and G.consumeables.cards[i].ability.extra.active then
                wildrank = true
            end
        end
	end
        if not next(SMODS.find_card("j_tma_Boneturner")) and not wildrank then return cool_get_straight(hand) end
        local ret = {}
        local four_fingers = next(SMODS.find_card('Four Fingers'))
        if #hand > 5 or #hand < (5 - (four_fingers and 1 or 0)) then return ret else
        local t = {}
        local IDS = {}
        local face_replace = next(SMODS.find_card('j_tma_Boneturner'))
        local wildIDS = {}
        local wilds = 0
        for i=1, #hand do
            local id = hand[i]:get_id()
            if id > 1 and id < 15 then
                if hand[i].ability.effect == "Wild Card" and not hand[i].ability.debuff and wildrank then
                    if wildIDS[id] then
                        wildIDS[id][#wildIDS[id]+1] = hand[i]
                        wilds = wilds + 1
                        print("Wilds", wilds)
                    else
                        wildIDS[id] = {hand[i]}
                        wilds = wilds + 1
                        print("Wilds", wilds)
                    end
                else
                    if IDS[id] then
                        IDS[id][#IDS[id]+1] = hand[i]
                    else
                        IDS[id] = {hand[i]}
                    end
                end
            end
        end
        local templatewilds = wilds
        local straight_length = 0
        local straight = false
        local can_skip = next(SMODS.find_card('Shortcut')) 
        local skipped_rank = false
        for j = 1, 14 do
        if IDS[j == 1 and 14 or j] then
            straight_length = straight_length + 1
            skipped_rank = false
            for k, v in ipairs(IDS[j == 1 and 14 or j] or {}) do
                t[#t+1] = v
            end
        elseif (j >= 11 and j <= 13 and (IDS[11] or IDS[12] or IDS[13]) and face_replace) then
            straight_length = straight_length + 1
            skipped_rank = false
            for k, v in ipairs(IDS[j == 1 and 14 or j] or {}) do
                t[#t+1] = v
            end
        elseif can_skip and not skipped_rank and j ~= 14 then
            skipped_rank = true
        elseif templatewilds > 0 and straight_length > 0 then
            straight_length = straight_length + 1
            skipped_rank = false
            templatewilds = templatewilds -1
        else
            straight_length = 0
            templatewilds = wilds
            skipped_rank = false
            if not straight then t = {} end
            if straight then break end
            end
            if straight_length >= (5 - (four_fingers and 1 or 0) - templatewilds) then straight = true end 
        end
        if straight then
            for j = 1, 14 do
                if wildIDS[j == 1 and 14 or j] then
                    for k, v in ipairs(wildIDS[j == 1 and 14 or j] or {}) do
                        t[#t+1] = v
                    end
                end
            end
        end
        if not straight then return ret end
        table.insert(ret, t)
        return ret
        end
    end

    local local_generate_UIBox_ability_table = Card.generate_UIBox_ability_table
    function Card:generate_UIBox_ability_table()
        local card_type, hide_desc = self.ability.set or "None", nil
        local loc_vars = nil
        local main_start, main_end = nil,nil
        local no_badge = nil
        if not next(SMODS.find_card("j_tma_Distortion")) then return local_generate_UIBox_ability_table(self) end
        if card_type == 'Default' or card_type == 'Enhanced' then
            if ((self.ability.bonus or 0)  + (self.ability.perma_bonus or 0)) > 0 then
                loc_vars = { playing_card = not not self.base.colour, value = self.base.value, suit = self.base.suit, colour = self.base.colour,
                            nominal_chips = '???',
                            bonus_chips = '???' }
            else 
                loc_vars = { playing_card = not not self.base.colour, value = self.base.value, suit = self.base.suit, colour = self.base.colour,
                            nominal_chips = '???',
                            bonus_chips = nil }
            end
            local badges = {}
            if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
                badges.card_type = card_type
            end
            if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
                badges.force_rarity = true
            end
            if self.edition then
                if self.edition.type == 'negative' and self.ability.consumeable then
                    badges[#badges + 1] = 'negative_consumable'
                else
                    badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
                end
            end
            if self.seal then badges[#badges + 1] = string.lower(self.seal)..'_seal' end
            if self.ability.eternal then badges[#badges + 1] = 'eternal' end
            if self.ability.perishable then
                loc_vars = loc_vars or {}; loc_vars.perish_tally=self.ability.perish_tally
                badges[#badges + 1] = 'perishable'
            end
            if self.ability.rental then badges[#badges + 1] = 'rental' end
            if self.pinned then badges[#badges + 1] = 'pinned_left' end
            if self.sticker or ((self.sticker_run and self.sticker_run~='NONE') and G.SETTINGS.run_stake_stickers)  then loc_vars = loc_vars or {}; loc_vars.sticker=(self.sticker or self.sticker_run) end
    
            return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end)
        else
            return local_generate_UIBox_ability_table(self)
        end
    end

    local local_chip_bonus = Card.get_chip_bonus
    function Card:get_chip_bonus()
        if self.debuff then return 0 end
        if next(SMODS.find_card("j_tma_Distortion")) then
            local temp_Chips = pseudorandom('Distortion', (0 + ((self.ability.bonus or 0) + (self.ability.perma_bonus or 0))/2), (30 + 2*((self.ability.bonus or 0) + (self.ability.perma_bonus or 0))))
            return temp_Chips
        else 
            return local_chip_bonus(self)
        end
    end

    -- cool x of a kindsss :D
    local cool_get_X_same = get_X_same
    function get_X_same(num, hand, or_more)
        local wildrank = false
	if G.consumeables then
        for i=1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.name == "c_tma_morph" and G.consumeables.cards[i].ability.extra.active then
                wildrank = true
            end
        end
	end
        if not next(SMODS.find_card("j_tma_Boneturner")) and not wildrank then return cool_get_X_same(num, hand, or_more) end
        local face_replace = next(SMODS.find_card('j_tma_Boneturner'))
        local vals = {}
        for i = 1, SMODS.Rank.max_id.value do
            vals[i] = {}
        end
        local wilds = {}
        local wildsOnly = true
        for i=#hand, 1, -1 do
            if hand[i].ability.effect == "Wild Card" and not hand[i].ability.debuff and i ~= j and wildrank then
                table.insert(wilds, hand[i])
            end
        end
        local highest = {}
        for i=#hand, 1, -1 do
            if not (hand[i].ability.effect == "Wild Card" and not hand[i].ability.debuff and wildrank) then
                wildsOnly = false
                local curr = {}
                table.insert(curr, hand[i])
                for j=1, #hand do
                    if hand[i]:get_id() == hand[j]:get_id() and i ~= j and not (hand[j].ability.effect == "Wild Card" and not hand[i].ability.debuff) then
                        table.insert(curr, hand[j])
                    elseif hand[i]:get_id() >= 11 and hand[i]:get_id() <= 13 and hand[j]:get_id() >= 11 and hand[j]:get_id() <= 13 and i ~= j and not (hand[j].ability.effect == "Wild Card" and not hand[i].ability.debuff) and face_replace then
                        table.insert(curr, hand[j])
                    end
                end
                if #highest < #curr then
                    highest = curr
                end
                if or_more and (#curr >= num) or (#curr == num) then
                    if curr[1]:get_id() >= 11 and curr[1]:get_id() <= 13 and face_replace then
                        vals[13] = curr
                    else
                        vals[curr[1]:get_id()] = curr
                    end
                end
            end
        end
        for i=1, #wilds do
            table.insert(highest, wilds[i])
        end
        if (or_more and (#wilds >= num) or (#wilds == num)) and wildsOnly then
            vals[20] = wilds
        end
        if (or_more and (#highest >= num) or (#highest == num)) then
            vals[highest[1]:get_id()] = highest
        end
        local ret = {}
        for i=#vals, 1, -1 do
            if next(vals[i]) then table.insert(ret, vals[i]) end
        end
        return ret
    end

    local referencedollars = ease_dollars
    function ease_dollars(mod, instant)
	if G.consumeables then
        for i=1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.name == "c_tma_paradise" and G.consumeables.cards[i].ability.extra.active and mod >=0 then
                mod = mod*2
            end
        end
	end
        return referencedollars(mod, instant)
    end

    --NowhereToGo
    SMODS.Joker({
        key = 'NowhereToGo', atlas = 'tma_joker', pos = {x = 0, y = 0}, rarity = 2, cost = 7, blueprint_compat = true, 
        config = {
            extra = {
                percent_chips = 0.1,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.percent_chips*100}
            }
        end,
        calculate = function(self,card,context)
            if context.individual and context.cardarea == G.play and context.other_card:is_suit("Spades") and not context.other_card.debuff then
                G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.2,func = function()
                    G.GAME.blind.chips = math.floor(G.GAME.blind.chips * (1-card.ability.extra.percent_chips))
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

                    local chips_UI = G.hand_text_area.blind_chips
                    G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                    G.HUD_blind:recalculate() 
                    chips_UI:juice_up()
            
                    if not silent then play_sound('chips1') end
                    return true end }))
                return {
                    extra = {message = localize('k_dig_ex'), colour = HEX("7a5830"), focus = card},
                    colour = HEX("7a5830"),
                    card = context.card
                }
            end
        end
    })
    
    -- Plague Doctor
    SMODS.Joker({
        key = 'PlagueDoctor', atlas = 'tma_joker', pos = {x = 1, y = 0}, rarity = 2, cost = 5, blueprint_compat = false, 
        calculate = function(self,card,context)
            if context.ending_shop and not context.blueprint then
                for k, v in ipairs(G.consumeables.cards) do
                    if v.ability.set == 'Tarot' and v.key ~= "c_tma_the_rot" then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.3,
                            func = (function()
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_rotten_ex'), colour = G.C.PURPLE, card = v})
                                v:juice_up(0.8, 0.8)
                                card:juice_up()
                                v:set_ability(G.P_CENTERS["c_tma_the_rot"])
                                return true
                            end)
                        }))
                    elseif v.ability.set == 'Planet' and v.key ~= "c_tma_colony" then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.3,
                            func = (function()
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_rotten_ex'), colour = G.C.PURPLE, card = v})
                                v:juice_up(0.8, 0.8)
                                card:juice_up()
                                v:set_ability(G.P_CENTERS["c_tma_colony"])
                                return true
                            end
                        )}))
                    elseif v.ability.set == 'Spectral' and v.key ~= "c_tma_decay" then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.3,
                            func = (function()
                                card_eval_status_text(v, 'extra', nil, nil, nil, {message = localize('k_rotten_ex'), colour = G.C.PURPLE, card = v})
                                v:juice_up(0.8, 0.8)
                                card:juice_up()
                                v:set_ability(G.P_CENTERS["c_tma_decay"])
                                return true
                            end
                        )}))
                    end 
                end
                return
            end
        end
    })
    --Blind Sun 
    SMODS.Joker({
        key = 'BlindSun', atlas = 'tma_joker', pos = {x = 2, y = 0}, rarity = 2, cost = 8, blueprint_compat = true, 
        name = 'tma_BlindSun',
        config = {
            name = 'tma_BlindSun',
            mult = 20,
            extra = {
                odds = 7,
                card_list = {}
            }
        },
        loc_vars = function(self,info_queue,card)
            local vars
            if G.GAME and G.GAME.probabilities.normal then
                vars = {G.GAME.probabilities.normal, card.ability.extra.odds, card.ability.mult}
            else
                vars = {1, card.ability.extra.odds, card.ability.mult}
            end
            return {vars = vars}
        end,
        calculate = function(self, card, context)
            if context.stay_flipped and not context.blueprint then
                card:juice_up(0.3)
            end
            if context.play_cards then
                card.ability.extra.card_list = {}
                for i = 1, #G.hand.highlighted do
                    if G.hand.highlighted[i].facing == 'back' then
                        table.insert(card.ability.extra.card_list, G.hand.highlighted[i])
                    end
                end
            end
            if context.individual and context.cardarea == G.play and context.other_card and not context.other_card.debuff then
                for i = 1, #card.ability.extra.card_list do
                    local flipped_card = card.ability.extra.card_list[i]
                    if context.other_card == flipped_card then
                        return {
                            mult = card.ability.mult,
                            card = card
                        }
                    end
                end
            end
        end
    })
    
    -- Lightless Flame
    SMODS.Joker({
        key = 'LightlessFlame', atlas = 'tma_joker', pos = {x = 3, y = 0}, rarity = 1, cost = 4, blueprint_compat = true, perishable_compat = false,
        config = {
            mult_mod = 0,
            extra = {
                bonus_mult = 2,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.mult_mod, card.ability.extra.bonus_mult}
            }
        end,
        calculate = function(self,card,context)
            if context.setting_blind and not card.getting_sliced and not context.blueprint then
                for k, v in ipairs(G.consumeables.cards) do
                    G.GAME.consumeable_buffer = 0
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.3,
                        func = function()
                        G.GAME.consumeable_buffer = 0
                        card:juice_up(0.8, 0.8)
                        v:start_dissolve()
                    return true end }))
                    card.ability.mult_mod = card.ability.mult_mod + card.ability.extra.bonus_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.mult_mod}}, colour = G.C.RED, no_juice = true, card = card})
                end
                return
            end
            if context.joker_main and card.ability.mult_mod > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.mult_mod}},
                    mult_mod = card.ability.mult_mod
                }
            end
        end
    })

    -- Last Laugh
    SMODS.Joker({
        key = 'LastLaugh', atlas = 'tma_joker', pos = {x = 4, y = 0}, rarity = 2, cost = 6, blueprint_compat = true, 
        config = {
            extra = {
                woah_x_mult = 20
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.woah_x_mult}
            }
        end,
        calculate = function(self,card,context)
            if context.joker_main and #G.deck.cards == 0 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.woah_x_mult}},
                    Xmult_mod = card.ability.woah_x_mult
                }
            end
        end
    })

    -- Extinction
    SMODS.Joker({
        key = 'Extinction', atlas = 'tma_joker', pos = {x = 4, y = 1}, rarity = 1, cost = 3, blueprint_compat = true, 
        config = {
            extra = {
                cool_x_mult = 5
            }
        },
        loc_vars = function(self,info_queue,card)
            return {vars = {card.ability.extra.cool_x_mult, (G.GAME.starting_deck_size or 52)/2}}
        end,
        calculate = function(self,card,context)
            if context.joker_main and ((G.GAME.starting_deck_size)/2 - #G.playing_cards) > 0 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.cool_x_mult}},
                    Xmult_mod = card.ability.extra.cool_x_mult
                }
            end
        end
    })

    -- Panopticon
    SMODS.Joker({
        key = 'Panopticon', atlas = 'tma_joker', pos = {x = 5, y = 0}, rarity = 3, cost = 7, blueprint_compat = true, perishable_compat = false,
        config = {
            extra = {
                chips = 0,
                chips_mod = 40
            }
        },
        loc_vars = function(self,info_queue,card)
            local spectrals_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Spectral' then spectrals_used = spectrals_used + 1 end end
            return {vars = {card.ability.extra.chips_mod, spectrals_used*card.ability.extra.chips_mod}}
        end,
        calculate = function(self,card,context)
            if context.joker_main then
                local spectrals_used = 0
                for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Spectral' then spectrals_used = spectrals_used + 1 end end
                if spectrals_used > 0 then
                    return {
                        message = localize{type='variable',key='a_chips',vars={spectrals_used*card.ability.extra.chips_mod}},
                        chips_mod = spectrals_used*card.ability.extra.chips_mod
                    }
                end
            end
        end
    })

    -- Boneturner
    SMODS.Joker({
        key = 'Boneturner', atlas = 'tma_joker', pos = {x = 6, y = 0}, rarity = 3, cost = 8, blueprint_compat = false
    })

    -- Hunter
    SMODS.Joker({
        key = 'Hunter', atlas = 'tma_joker', pos = {x = 3, y = 1}, rarity = 2, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                money = 3
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.money}
            }
        end,
        calculate = function(self,card,context)
            if context.individual and context.cardarea == G.play and context.other_card:get_seal() then
                G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.money
                G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                return {
                    dollars = card.ability.extra.money,
                    card = card
                }
            end
        end
    })
    
    -- Lonely Joker
    SMODS.Joker({
        key = 'Lonely', atlas = 'tma_joker', pos = {x = 8, y = 0}, rarity = 1, cost = 5, blueprint_compat = true, perishable_compat = false,
        config = {
            mult_mod = 0,
            extra = {
                mult_bonus = 2
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.mult_bonus, card.ability.mult_mod, localize('High Card', 'poker_hands')}
            }
        end,
        calculate = function(self,card,context)
            if context.before and not context.blueprint and context.scoring_name == 'High Card' then
                card.ability.mult_mod = card.ability.mult_mod + card.ability.extra.mult_bonus
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED,
                    card = card
                }
            end
            if context.joker_main and card.ability.mult_mod > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.mult_mod}},
                    mult_mod = card.ability.mult_mod
                }
            end
        end
    })
    
    -- Piper
    SMODS.Joker({
        key = 'Piper', atlas = 'tma_joker', pos = {x = 5, y = 1}, rarity = 2, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                h_size = 2,
                discard_rand = 2
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.h_size, card.ability.extra.discard_rand}
            }
        end,
        calculate = function(self,card,context)
            if context.before then
                G.E_MANAGER:add_event(Event({ func = function()
                    local any_selected = nil
                    local _cards = {}
                    for k, v in ipairs(G.hand.cards) do
                        _cards[#_cards+1] = v
                    end
                    for i = 1, 2 do
                        if G.hand.cards[i] then 
                            local selected_card, card_key = pseudorandom_element(_cards, pseudoseed('hook'))
                            G.hand:add_to_highlighted(selected_card, true)
                            table.remove(_cards, card_key)
                            any_selected = true
                            play_sound('card1', 1)
                        end
                    end
                    card:juice_up()
                    if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
                return true end }))
            end
        end
    })

    -- Distortion
    SMODS.Joker({
        key = 'Distortion', atlas = 'tma_joker', pos = {x = 9, y = 0}, rarity = 1, cost = 4, blueprint_compat = false
    })

    -- Nikola Orsinov
    SMODS.Joker({
        key = 'Nikola', atlas = 'tma_joker', pos = {x = 0, y = 1}, soul_pos = {x = 1, y = 1}, rarity = 4, cost = 20, blueprint_compat = true,
        calculate = function(self,card,context)
            if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 3 and context.other_card ~= card then
            return {
              message = localize('k_again_ex'),
              repetitions = 1,
              card = card
            }
          end
        end
    })

    -- Fallen Titan
    SMODS.Joker({
        key = 'FallenTitan', atlas = 'tma_joker', pos = {x = 7, y = 0}, rarity = 2, cost = 7, blueprint_compat = true, enhancement_gate = 'm_stone',
        config = {
            extra = {
                bonus_chips = 50
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.bonus_chips}
            }
        end,
        calculate = function(self,card,context)
            if not context.end_of_round and context.individual and context.cardarea == G.hand and context.other_card.ability.name == "Stone Card" then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    return {
                        card = card,
                        chips = card.ability.extra.bonus_chips
                    }
                end
            end
        end
    })

    -- Mr Spider
    SMODS.Joker({
        key = 'MrSpider', atlas = 'tma_joker', pos = {x = 2, y = 1}, rarity = 2, cost = 7, blueprint_compat = true, perishable_compat = false,
        config = {
            x_mult = 1,
            extra = {
                bonus_mult = 0.25,
                rank = 'Jack'
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.bonus_mult, card.ability.x_mult, localize(card.ability.extra.rank, 'ranks')}
            }
        end,
        set_ability = function(self, card)
            if G.playing_cards and #G.playing_cards > 0 then
                local ranks_in_deck = {}
                for _, v in ipairs(G.playing_cards) do
                    table.insert(ranks_in_deck, v)
                end
                card.ability.extra.rank = pseudorandom_element(ranks_in_deck, pseudoseed('mrspider')).base.value
            end
        end,
        calculate = function(self,card,context)
            if context.end_of_round and not context.repetition and not context.individual then
                local ranks_in_deck = {}
                for _, v in ipairs(G.playing_cards) do
                    table.insert(ranks_in_deck, v)
                end
                card.ability.extra.rank = pseudorandom_element(ranks_in_deck, pseudoseed('mrspider')).base.value
            end
            if context.joker_main and card.ability.x_mult > 1 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                    Xmult_mod = card.ability.x_mult
                }
            end
            if context.destroying_card and not context.blueprint and (context.full_hand[1].base.value == card.ability.extra.rank or ((context.full_hand[1].base.value == 'Jack' or context.full_hand[1].base.value == 'Queen' or context.full_hand[1].base.value == 'King') and next(find_joker('j_tma_Boneturner')) and card.ability.extra.rank == 'Jack' or card.ability.extra.rank == 'Queen' or card.ability.extra.rank == 'King') or (next(SMODS.find_card('c_tma_morph')) and SMODS.find_card('c_tma_morph')[1].ability.extra.active and context.full_hand[1].ability.effect == "Wild Card")) and #context.full_hand == 1 then
                local playcard = context.full_hand[1]
                card.ability.x_mult = card.ability.x_mult + card.ability.extra.bonus_mult
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.x_mult}}, colour = G.C.RED, card = card})
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					func = function()
						playcard:start_dissolve()
					return true
				end}))
                return true
            end
        end
    })

    -- Coffin
    SMODS.Joker({
        key = 'Coffin', atlas = 'tma_joker', pos = {x = 6, y = 1}, rarity = 1, cost = 1, blueprint_compat = false, eternal_compat = false,
        config = {
            extra = {
                dollars = 20,
                my_pos = nil
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.dollars}
            }
        end,
        add_to_deck = function(self, card, from_debuff)
            if not from_debuff then 
                ease_dollars(card.ability.extra.dollars)
            end
            local eval = function(card) return not card.REMOVED end
            juice_card_until(card, eval, true)
        end,
        calculate = function(self,card,context)
            if context.setting_blind and not context.blueprint then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
            end
            if context.selling_self and not context.blueprint then 
                local jokers = {}
                for i=1, #G.jokers.cards do 
                    if G.jokers.cards[i] ~= card then
                        jokers[#jokers+1] = G.jokers.cards[i]
                    end
                end
                if not from_debuff and #jokers > 0 then 
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_buried_ex')})
                    local chosen_joker = ((G.jokers.cards[1]))
                    if not chosen_joker.ability.eternal then
                        chosen_joker.getting_sliced = true
                        G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                            G.GAME.joker_buffer = 0
                            chosen_joker:start_dissolve({HEX("7a5830")}, nil, 1.6)
                            play_sound('slice1', 0.96+math.random()*0.08)
                        return true end }))
                    end
                end
            end
        end
    })

    -- Syringe
    SMODS.Joker({
        key = 'Syringe', atlas = 'tma_joker', pos = {x = 7, y = 1}, rarity = 2, cost = 5, blueprint_compat = false, eternal_compat = false,
        calculate = function(self,card,context)
            if context.selling_self and G.GAME.blind then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function()
                    ease_hands_played((1-G.GAME.current_round.hands_left), nil, true)
                    G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.2)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

                    local chips_UI = G.hand_text_area.blind_chips
                    G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
                    G.HUD_blind:recalculate() 
                    chips_UI:juice_up()
            
                    if not silent then play_sound('chips2') end
                return true end }))
            end
        end
    })

    -- Shadow Puppet
    SMODS.Joker({
        key = 'ShadowPuppet', atlas = 'tma_joker', pos = {x = 8, y = 1}, rarity = 3, cost = 8, blueprint_compat = true,
        config = {
            extra = {
                active = false
            }
        },
        calculate = function(self,card,context)
            if context.first_hand_drawn then
                if not card.ability.extra.active then
                    card.ability.extra.active = true
                    local eval = function() return card.ability.extra.active end
                    juice_card_until(card, eval, true)
                end
            end
            if context.using_consumeable and card.ability.extra.active and context.consumeable.ability.set == 'Tarot' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,func = function ()
                        local copy
                        card.ability.extra.active = false
                        copy = copy_card(context.consumeable)
                        copy:set_edition({negative = true}, true)
                        copy:set_cost(1)
                        copy:add_to_deck()
                        G.consumeables:emplace(copy)
                    return true
                end}))
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
            end
        end
    })

    -- Wildfire 
    SMODS.Joker({
        key = 'Wildfire', atlas = 'tma_joker', pos = {x = 9, y = 1}, rarity = 2, cost = 5, blueprint_compat = true, enhancement_gate = 'm_wild',
        config = {
            extra = {
                odds = 6
            }
        },
        loc_vars = function(self,info_queue,card)
            local vars
            if G.GAME and G.GAME.probabilities.normal then
                vars = {G.GAME.probabilities.normal, card.ability.extra.odds}
            else
                vars = {1, card.ability.extra.odds}
            end
            return {vars = vars}
        end,
    })

    -- Gunslinger
    SMODS.Joker({
        key = 'Gunslinger', atlas = 'tma_joker', pos = {x = 0, y = 2}, rarity = 2, cost = 6, blueprint_compat = false,
        config = {
            extra = {
                hand = 'Two Pair'
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {localize(card.ability.extra.hand, 'poker_hands')}
            }
        end,
        set_ability = function(self, card)
            local _poker_hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible then _poker_hands[#_poker_hands+1] = k end
            end
            local old_hand = card.ability.extra.hand
            card.ability.extra.hand = nil
    
            while not card.ability.extra.hand do
                card.ability.extra.hand = pseudorandom_element(_poker_hands, pseudoseed((card.area and card.area.config.type == 'title') and 'false_to_do' or 'to_do'))
            end
        end,
        calculate = function(self,card,context)
            if context.after and not context.blueprint and context.scoring_name == 'tma_dead' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4,
                    func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_blam_ex'), colour = G.C.RED, card = card})
                        G.hand_text_area.blind_chips:juice_up()
                        G.hand_text_area.game_chips:juice_up()
                        play_sound('tarot1')
                        card:start_dissolve()
                        return true
                    end
                })) 
                return true
            end
        end
    })

    -- Mechanical Joker
    SMODS.Joker({
        key = 'MechanicalJoker', atlas = 'tma_joker', pos = {x = 1, y = 2}, rarity = 3, cost = 8, blueprint_compat = true,
        calculate = function(self, card, context)
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    if context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 1 and context.other_card ~= card and (context.other_card == G.jokers.cards[i+1] or context.other_card == G.jokers.cards[i-1]) then
                    return {
                      message = localize('k_again_ex'),
                      repetitions = 1,
                      card = card
                    }
                    end
                end        
            end
        end
    })

    -- Archivist Joker
    SMODS.Joker({
        key = 'Archivist', atlas = 'tma_joker', pos = {x = 2, y = 2}, rarity = 1, cost = 5, blueprint_compat = true, perishable_compat = false,
        config = {
            extra = {
                chips = 0
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.chips, card.ability.extra.gold}
            }
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then 
                for k, v in ipairs(G.consumeables.cards) do
                    card.ability.extra.chips = card.ability.extra.chips + 4*v.sell_cost
                    v:juice_up()
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}}}); return true
            end
            if context.joker_main then
                return {
                    message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                    chips_mod = card.ability.extra.chips
                }
            end
        end
    })

    -- Heartbeat
    SMODS.Joker({
        key = 'Heartbeat', atlas = 'tma_joker', pos = {x = 3, y = 2}, rarity = 2, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                repetitions = 1,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.repetitions}
            }
        end,
        calculate = function(self, card,context)
            if  context.repetition then
                if context.cardarea == G.play then
                    if context.other_card:is_suit("Hearts") then
                            return {
                                message = localize('k_again_ex'),
                                repetitions = card.ability.extra.repetitions,
                                card = card
                            }
                    end
                end
            end
        end
    })
    
    --Lost City
    SMODS.Joker({
        key = 'LostCity', atlas = 'tma_joker', pos = {x = 4, y = 2}, rarity = 2, cost = 5, blueprint_compat = false, enhancement_gate = 'm_gold',
        config = {
            d_size = -1,
            extra = {
                discard_gain = 1
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {card.ability.d_size, card.ability.extra.discard_gain}
            }
        end,
        add_to_deck = function(self, card, from_debuff)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.d_size
            ease_discard(card.ability.d_size)
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.d_size
            ease_discard(-card.ability.d_size)
        end,
        calculate = function(self, card, context) 
            if context.discard and context.other_card == context.full_hand[#context.full_hand] and not context.blueprint then
                local gold = 0
                for k, v in ipairs(context.full_hand) do
                    if v.ability.name == "Gold Card" then gold = gold + 1 end
                end
                if gold > 0 then
                    ease_discard(card.ability.extra.discard_gain)
                    forced_message('+'..card.ability.extra.discard_gain..' '..localize('b_discard'), card, G.C.RED, true)
                end
            end
        end
    })
    
    -- Lighthouse
    SMODS.Joker({
        key = 'Lighthouse', atlas = 'tma_joker', pos = {x = 5, y = 2}, rarity = 1, cost = 5, blueprint_compat = false
    })

    -- War Chant
    SMODS.Joker({
        key = 'WarChant', atlas = 'tma_joker', pos = {x = 6, y = 2}, rarity = 1, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                mult_stuff = 30,
                active = false
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {card.ability.extra.mult_stuff}
            }
        end,
        calculate = function(self,card,context)
            if context.first_hand_drawn then
                if not card.ability.extra.active then
                    card.ability.extra.active = true
                    local eval = function() return card.ability.extra.active end
                    juice_card_until(card, eval, true)
                end
            end
            if context.joker_main and card.ability.extra.active then
                card.ability.extra.active = false
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult_stuff}},
                    mult_mod = card.ability.extra.mult_stuff
                }
            end
        end
    })

    -- Fractal
    SMODS.Joker({
        key = 'Fractal', atlas = 'tma_joker', pos = {x = 7, y = 2}, rarity = 2, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                xmult_per = 0.1
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {card.ability.extra.xmult_per}
            }
        end,
        calculate = function(self,card,context)
            if context.individual and context.other_card:is_suit("Clubs") and context.cardarea == G.play then
                local clubs = 0
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:is_suit("Clubs") then
                        clubs = clubs + 1
                    end
                end
                local total_xmult = 1 + card.ability.extra.xmult_per*clubs
                return {
                    x_mult = total_xmult,
                    card = card
                }
            end
        end
    })

    -- Mannequin
    SMODS.Joker({
        key = 'Mannequin', atlas = 'tma_joker', pos = {x = 8, y = 2}, rarity = 1, cost = 2, blueprint_compat = false, eternal_compat = false,
        config = {
            extra = {
                last_sold = nil
            }
        },
        loc_vars = function(self, info_queue, card)
            if card.ability.extra.last_sold ~= nil and card.ability ~= nil and card.ability.extra.last_sold.ability.name ~= nil then
                local name_sold = card.ability.extra.last_sold.ability.name and G.P_CENTERS[card.ability.extra.last_sold.config.center_key] or nil
                return {
                    vars = {(name_sold and (localize{type = 'name_text', key = name_sold.key, set = name_sold.set}) or name_sold.ability.name)}
                }
            else
                if G.GAME.last_sold_joker ~= nil and G.GAME.last_sold_joker.ability ~= nil and G.GAME.last_sold_joker.ability.name ~= nil then
                    local name_sold = G.GAME.last_sold_joker.ability.name and G.P_CENTERS[G.GAME.last_sold_joker.config.center_key] or nil
                    return {
                        vars = {(name_sold and (localize{type = 'name_text', key = name_sold.key, set = name_sold.set}) or name_sold.ability.name)}
                    }
                else
                return { vars = {"N/A"}}
                end
            end
        end,
        calculate = function(self,card,context)
            if context.selling_self and not context.blueprint then  
                if card.ability.extra.last_sold ~= nil and card.ability.extra.last_sold.ability.name ~= nil then
                    if card.ability.extra.last_sold.ability.set == "Joker" then
                        if #G.jokers.cards <= G.jokers.config.card_limit then 
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                            local new_card = copy_card(card.ability.extra.last_sold, nil, nil, nil, card.ability.extra.last_sold.edition and card.ability.extra.last_sold.edition.negative)
                            new_card:start_materialize()
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        else
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                        end
                    elseif card.ability.extra.last_sold.ability.set == "Statement" then
                        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then 
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                            local new_card = copy_card(card.ability.extra.last_sold, nil, nil, nil, card.ability.extra.last_sold.edition and card.ability.extra.last_sold.edition.negative)
                            new_card:start_materialize()
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                        else
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                        end
                    end
                elseif G.GAME.last_sold_joker ~= nil and G.GAME.last_sold_joker.ability.name ~= nil then
                    if G.GAME.last_sold_joker.ability.set == "Joker" then
                        if #G.jokers.cards <= G.jokers.config.card_limit then 
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                            local new_card = copy_card(G.GAME.last_sold_joker, nil, nil, nil, G.GAME.last_sold_joker.edition and G.GAME.last_sold_joker.edition.negative)
                            new_card:start_materialize()
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        else
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                        end
                    elseif G.GAME.last_sold_joker.ability.set == "Statement" then
                        if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then 
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                            local new_card = copy_card(G.GAME.last_sold_joker, nil, nil, nil,G.GAME.last_sold_joker.edition and G.GAME.last_sold_joker.edition.negative)
                            new_card:start_materialize()
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                        else
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_no_room_ex')})
                        end
                    end
                end
            end
        end
    })

    -- DeepBlue
    SMODS.Joker({
        key = 'DeepBlue', atlas = 'tma_joker', pos = {x = 9, y = 2}, rarity = 3, cost = 6, blueprint_compat = true,
        calculate = function(self,card,context)
            if not context.end_of_round and context.individual and context.cardarea == G.hand then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    return {
                        card = card,
                        chips = context.other_card:get_chip_bonus()
                    }
                end
            end
        end

    })
    
    -- 
    SMODS.Joker({
        key = 'Marionette', atlas = 'tma_joker', pos = {x = 0, y = 3}, rarity = 1, cost = 6, blueprint_compat = true,
        config = {
            extra = {
                mult_mod = 5,
                triggers = 0,
            }
        },
        loc_vars = function(self, info_queue, card)
            return {
                vars = {card.ability.extra.mult_mod}
            }
        end,
        calculate = function(self,card,context)
            if context.post_trigger and not context.blueprint then
                local other_joker = nil
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i-1] end
                end
                if context.other_joker == other_joker then
                    card.ability.extra.triggers = card.ability.extra.triggers + 1
                    card:juice_up()
                    return nil
                end
            end
            if context.joker_main and card.ability.extra.triggers > 0 then
                local trigs = card.ability.extra.triggers or 0
                card.ability.extra.triggers = 0
                return {
                    mult_mod = card.ability.extra.mult_mod*trigs,
                    message = localize{type='variable',key='a_mult',vars={card.ability.extra.mult_mod*trigs}},
                }
            end
        end
    })
    
    -- The Rot (Tarot)
    SMODS.Consumable {
        set = 'Tarot', atlas = 'tma_tarot', key = 'the_rot', consumable = true,
        pos = { x = 0, y = 0 },
        config = {tarots = 1}, hidden = true,
        can_use = function(self, card)
            return true
        end,
        in_pool = function(self)
            return false
        end,
        loc_vars = function(self) return {vars = {self.config.tarots}} end, cost_mult = 1.0, effect = "Round Bonus",
        use = function(self, card, area,copier)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('timpani')
                    local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'rot')
                    new_card:set_edition({negative = true}, true)
                    new_card:add_to_deck()
                    new_card:set_cost(1)
                    G.consumeables:emplace(new_card)
                    card:juice_up(0.3, 0.5)
                return true end }))
            delay(0.6)
        end
    }

    
    --[[
    SMODS.Enhancement {
        set = 'Enhanced', atlas = 'tma_tarot', key = 'rotting',
        pos = {x=0,y=1},
        config = {mult = 20, lose_mult = 5},
        loc_vars = function(self) return {vars = {self.config.mult, self.config.lose_mult}} end,
        calculate = function(self, card, context, effect)
            if context.cardarea == G.play and not context.repetition then
                SMODS.eval_this(card, {
                    mult_mod = self.config.mult,
                    message = localize({type = 'variable', key = 'a_mult', vars = {self.config.mult}}),
                })
            elseif context.discard then
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        self.config.mult = self.config.mult - self.config.lose_mult
                        return true
                    end)}))
                card_eval_status_text(self, 'variable', nil, nil, nil, {message = localize({key = 'a_minus_mult', type = 'variable', vars = {self.config.mult}}), colour = G.C.PURPLE})
            end
        end
    }
    ]]--
    -- Colony (Planet)
    local planet_q = function(self, card, badges)
        badges[#badges + 1] = create_badge(localize('k_planet_q'), get_type_colour(self or card.ability, card), nil, 1.2)
    end
    SMODS.Consumable {
        set = 'Planet', atlas = 'tma_tarot', key = 'colony',
        pos = { x = 1, y = 0 },hidden = true,
        set_card_type_badge = planet_q,
        can_use = function(self, card)
            return true
        end,
        in_pool = function(self)
            return false
        end,
        use = function(self, card, area, copier)
            local used_consumable = copier or card
            --Get most played hand type (logic yoinked from Telescope)
            local _planet, _hand, _tally = nil, nil, -1
            for k, v in ipairs(G.handlist) do
                if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                    _hand = v
                    _tally = G.GAME.hands[v].played
                end
            end
            if _hand then
                for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                    if v.config.hand_type == _hand then
                        _planet = v.key
                    end
                end
            end
            update_hand_text(
                { sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
                {
                    handname = localize(_hand, "poker_hands"),
                    chips = G.GAME.hands[_hand].chips,
                    mult = G.GAME.hands[_hand].mult,
                    level = G.GAME.hands[_hand].level,
                }
            )
            level_up_hand(used_consumable, _hand, false, 1)
            update_hand_text(
                { sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
                { mult = 0, chips = 0, handname = "", level = "" }
            )
        end,
    }
    -- Decay (Spectral)
    SMODS.Consumable {
        set = 'Spectral', atlas = 'tma_tarot', key = 'decay',
        pos = { x = 2, y = 0 }, hidden = true,
        can_use = function(self, card)
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and G.jokers.config.card_limit > 1 then 
                    return true
                end
            end
        end,
        in_pool = function(self)
            return false
        end,
        use = function(self, card, area, copier)
            local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('decay_choice'))
            G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
                local new_card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
                new_card:start_materialize()
                new_card:add_to_deck()
                local new_edition = {negative = true}
                new_card:set_edition(new_edition, true)
                if new_card.ability.eternal then
                    SMODS.Stickers['eternal']:apply(new_card, false)
                end
                SMODS.Stickers['perishable']:apply(new_card, true, 5)
                G.jokers:emplace(new_card)
                return true end }))
        end,
    }

    -- Dead Man's Hand
    SMODS.PokerHandPart{
    key = 'deadhand',
    func = function(hand)
        local current_cards = {}
        local hands = {}
        local activated = false
        local deadhanded = false
        for i = 1, #hand do
            table.insert(current_cards, hand[i])
        end
        if G.jokers ~= nil then
            for _, v in ipairs(G.jokers.cards) do
                if v.config.center.key == 'j_tma_Gunslinger' then
                    table.insert(hands, v.ability.extra.hand)
                    activated = true
                else
                    activated = false
                end
            end
        end
        local ace_black = 0
        local eight_black = 0
        for i = 1, #hand do
            if ((next(SMODS.find_card('c_tma_morph')) and SMODS.find_card('c_tma_morph')[1].ability.extra.active and  hand[i].ability.effect == "Wild Card") or hand[i]:get_id() == 14) and (hand[i]:is_suit("Spades", nil, true) or hand[i]:is_suit("Clubs", nil, true)) then
                ace_black = ace_black+1
            elseif ((next(SMODS.find_card('c_tma_morph')) and SMODS.find_card('c_tma_morph')[1].ability.extra.active and hand[i].ability.effect == "Wild Card") or hand[i]:get_id() == 8) then
                eight_black = eight_black+1
            end
        end

            if (eight_black >=2 and ace_black >=2 and activated) or deadhanded then
                return {hand}
            end
        return {}
    end
}

    SMODS.PokerHand{ -- Dead Man's Hand
        key = 'dead',
        above_hand = 'Flush Five',
        visible = false,
        chips = 1837,
        mult = 1876,
        l_chips = 0,
        l_mult = 0,
        example = {
            {'S_8', true},
            {'C_A', true},
            {'S_A', true},
            {'C_8', true}
        },
        evaluate = function(parts)
            if #parts._2 < 2 or not next(parts.tma_deadhand) then return {} end
            return { SMODS.merge_lists (parts._all_pairs, parts.tma_deadhand) }
        end
    }

    local evaluate_poker_hand_ref = evaluate_poker_hand
    function evaluate_poker_hand(hand)
        local ret = evaluate_poker_hand_ref(hand)
        local hands = {}
        if G.jokers ~= nil then
            for _, v in ipairs(G.jokers.cards) do
                if v.config.center.key == 'j_tma_Gunslinger' then
                    table.insert(hands, v.ability.extra.hand)
                end
            end
        end
        for i = 1, #hands do
            for k, v in pairs(ret) do
                if hands[i] == k and v ~= nil then
                    ret["tma_dead"] = ret[k]
                end
            end
        end
        return ret
    end

    -- Statements

    SMODS.UndiscoveredSprite({
        key = 'Statement',
        atlas = 'tma_tarot',
        pos = {x = 0, y = 1},
    })
    SMODS.Sound({
        key = 'tma_statement1',
        path = 'statement1.wav'
    })
    
    SMODS.Sound({
        key = 'tma_statement2',
        path = 'statement2.wav'
    })

    SMODS.ConsumableType {
        key = 'Statement',
        primary_colour = HEX("5AC34D"),
        secondary_colour = HEX("7BA85D"),
        loc_txt = {
            name = "Statement",
            collection = "Statements",
            undiscovered = {
                name = 'Unknown Statement',
                text = {
                    'Find this tape in an unseeded',
                    'run to find out what it does'
                }
            }
        },
        collection_rows = {5, 5, 5},
        shop_rate = 0.5
    }
    SMODS.Booster{
        key = 'audio_basic1',
        config = {extra = 2, choose = 1},
        atlas = 'tma_tarot',
        cost = 4,
        weight = 0.8,
        pos = { x = 0, y = 3 },
        loc_vars = function(self, info_queue, card)
            return {vars = {card.config.center.config.choose, card.ability.extra}}
        end,
        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Statement)
            ease_background_colour({ new_colour = G.C.SECONDARY_SET.Statement, special_colour = G.C.BLACK, contrast = 1 })
        end,
        create_card = function(self, card)
            return create_card("Statement", G.pack_cards, nil, nil, true, true, nil, "tma_audio")
        end,
        group_key = "k_tma_audio_pack",
    }
    SMODS.Booster{
        key = 'audio_basic2',
        config = {extra = 2, choose = 1},
        atlas = 'tma_tarot',
        cost = 4,
        weight = 0.8,
        pos = { x = 1, y = 3 },
        loc_vars = function(self, info_queue, card)
            return {vars = {card.config.center.config.choose, card.ability.extra}}
        end,
        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Statement)
            ease_background_colour({ new_colour = G.C.SECONDARY_SET.Statement, special_colour = G.C.BLACK, contrast = 1 })
        end,
        create_card = function(self, card)
            return create_card("Statement", G.pack_cards, nil, nil, true, true, nil, "tma_audio")
        end,
        group_key = "k_tma_audio_pack",
    }
    SMODS.Booster{
        key = 'audio_jumbo',
        config = {extra = 4, choose = 1},
        atlas = 'tma_tarot',
        cost = 6,
        weight = 0.8,
        pos = { x = 2, y = 3 },
        loc_vars = function(self, info_queue, card)
            return {vars = {card.config.center.config.choose, card.ability.extra}}
        end,
        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Statement)
            ease_background_colour({ new_colour = G.C.SECONDARY_SET.Statement, special_colour = G.C.BLACK, contrast = 1 })
        end,
        create_card = function(self, card)
            return create_card("Statement", G.pack_cards, nil, nil, true, true, nil, "tma_audio")
        end,
        group_key = "k_tma_audio_pack",
    }
    SMODS.Booster{
        key = 'audio_mega',
        config = {extra = 4, choose = 2},
        atlas = 'tma_tarot',
        cost = 8,
        weight = 0.8,
        pos = { x = 3, y = 3 },
        loc_vars = function(self, info_queue, card)
            return {vars = {card.config.center.config.choose, card.ability.extra}}
        end,
        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Statement)
            ease_background_colour({ new_colour = G.C.SECONDARY_SET.Statement, special_colour = G.C.BLACK, contrast = 1 })
        end,
        create_card = function(self, card)
            return create_card("Statement", G.pack_cards, nil, nil, true, true, nil, "tma_audio")
        end,
        group_key = "k_tma_audio_pack",
    }
    -- Nightfall
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'nightfall',
        pos = { x = 1, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.before and card.ability.extra.active then
                local darks = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:is_suit('Spades') or v:is_suit('Clubs') then 
                        darks[#darks+1] = v
                        v:set_ability(G.P_CENTERS.m_bonus, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true
                            end
                        })) 
                    end
                end
                if #darks > 0 then 
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_bonus'), colour = G.C.CHIPS, card = card})
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
            end
        end
    }
    -- Burnout
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'burnout',
        pos = { x = 2, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.before and card.ability.extra.active then
                local lights = {}
                for k, v in ipairs(context.scoring_hand) do
                    if v:is_suit('Hearts') or v:is_suit('Diamonds') then 
                        lights[#lights+1] = v
                        v:set_ability(G.P_CENTERS.m_mult, nil, true)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                                return true
                            end
                        })) 
                    end
                end
                if #lights > 0 then 
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_mult'), colour = G.C.MULT, card = card})
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
            end
        end
    }
    -- Parity
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'parity',
        pos = { x = 4, y = 1 },
        cost = 4,
        config = {extra = {active = false, chips = 31, mult = 4}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.chips, card.ability.extra.mult}
            }
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and card.ability.extra.active then
                if context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id()%2 == 0 or (next(SMODS.find_card('c_tma_morph')) and SMODS.find_card('c_tma_morph')[1].ability.extra.active and context.other_card.ability.effect == "Wild Card") then
                    return {
                        mult = card.ability.extra.mult, card = card
                    }
                elseif ((context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id()%2 == 1) or (context.other_card:get_id() == 14) or ((next(SMODS.find_card('c_tma_morph')) and SMODS.find_card('c_tma_morph')[1].ability.extra.active and context.other_card.ability.effect == "Wild Card"))) then
                    return {
                        chips = card.ability.extra.chips, card = card
                    }
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
            end
        end
    }

    
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'wonderland',
        pos = { x = 3, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.individual and card.ability.extra.active then
                    if context.other_card.effect ~= 'Stone Card' then
                    return {
                        mult = context.other_card.base.nominal
                    }
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'precipice',
        pos = { x = 5, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.before and context.cardarea == G.consumeables and card.ability.extra.active then
                return {
                    card = card,
                    level_up = true,
                    message = localize('k_level_up_ex')
                }
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'mystery',
        pos = { x = 6, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.discard and card.ability.extra.active then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.1,
                        func = (function()
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'preserve',
        pos = { x = 7, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            for k, v in ipairs(G.playing_cards) do
                v:set_debuff(false)
            end
            for k, v in ipairs(G.jokers) do
                v:set_debuff(false)
            end
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }

    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'research',
        pos = { x = 8, y = 1 },
        cost = 4,
        config = {extra = {active = false, repetitions = 1}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.repetition and context.cardarea == G.play and card.ability.extra.active then
                if context.other_card:get_id() >=2 and context.other_card:get_id() <= 10 then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra.repetitions,
                        card = card
                    }
                end
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }

    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'morph',
        pos = { x = 9, y = 1 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
            G.GAME.morphIsActive = true
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
            G.GAME.morphIsActive = true
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                G.GAME.morphIsActive = false
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'paradise',
        pos = { x = 0, y = 2 },
        cost = 4,
        config = {extra = {active = false, gold = 15}},
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.gold}}
        end,
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'divinity',
        pos = { x = 1, y = 2 },
        cost = 4,
        config = {extra = {active = false, xmult = 1, xmult_mod = 1}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.xmult_mod, card.ability.extra.xmult}}
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
            if context.end_of_round and not context.repetition and not context.individual and not card.ability.extra.active and not card.getting_sliced and not context.blueprint then
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod
                return {
                    message = localize('k_upgrade_ex'),
                    card = card,
                    colour = G.C.MULT
                }
                end
            if context.joker_main and card.ability.extra.xmult > 1 and card.ability.extra.active then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
                    colour = G.C.RED,
                    Xmult_mod = card.ability.extra.xmult
                }
            end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'indulgence',
        pos = { x = 2, y = 2 },
        cost = 4,
        config = {extra = {active = false, cost = 6}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.cost}}
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'glimmer',
        pos = { x = 3, y = 2 },
        cost = 4,
        config = {extra = {active = false, enhancedjokers = {}}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.cost}}
        end,
        use = function(self, card, area, copier)
            for k, v in ipairs(G.jokers.cards) do
                if v.ability.set == "Joker" and (not v.edition) then 
                    table.insert(card.ability.extra.enhancedjokers, v)
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            for k, v in ipairs(card.ability.extra.enhancedjokers) do
                edition = poll_edition('glimmer', nil, true, true)
                v:set_edition(edition, true)
                check_for_unlock({type = 'have_edition'})
            end
            return true end }))

            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'static',
        pos = { x = 4, y = 2 },
        cost = 4,
        config = {extra = {active = false, cards_to_hand = {}}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.h_size}}
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.joker_main and context.scoring_hand then
                card.ability.extra.cards_to_hand = context.scoring_hand
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Statement', atlas = 'tma_tarot', key = 'exhaustion',
        pos = { x = 5, y = 2 },
        cost = 4,
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.destroying_card and card.ability.extra.active and not context.repetition and not context.individual then
                return true
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    SMODS.Consumable {
        set = 'Spectral', atlas = 'tma_tarot', key = 'compulsion',
        pos = { x = 6, y = 2 },
        cost = 4, soul_set = "Statement",
        config = {extra = {active = false}},
        can_use = function(self, card)
            return not card.ability.extra.active
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card.ability.extra.cost}}
        end,
        use = function(self, card, area, copier)
            card.ability.extra.active = true
            play_sound('tma_statement1', 1.1 + math.random()*0.1, 0.8)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        load = function(self,card,card_table,other_card)
            local eval = function(card) return card.ability.extra.active end
            juice_card_until(card, eval, true)
        end,
        keep_on_use = function(self, card)
            return true
        end,
        calculate = function(self, card, context)
            if context.retrigger_joker_check and not context.retrigger_joker then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = card
                }   
            end
            if context.end_of_round and not context.repetition and not context.individual and not card.getting_sliced and card.ability.extra.active then
                card.getting_sliced = true
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    G.GAME.consumeable_buffer = 0
                    play_sound('tma_statement2', 1.0 + math.random()*0.1, 0.8)
                    card:start_dissolve()
                return true end }))
                end
        end
    }
    G.FUNCS.can_reserve_card = function(e)
        if #G.consumeables.cards < G.consumeables.config.card_limit then
          e.config.colour = G.C.GREEN
          e.config.button = "reserve_card"
        else
          e.config.colour = G.C.UI.BACKGROUND_INACTIVE
          e.config.button = nil
        end
      end
      G.FUNCS.reserve_card = function(e)
        local c1 = e.config.ref_table
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.1,
          func = function()
            c1.area:remove_card(c1)
            c1:add_to_deck()
            if c1.children.price then
              c1.children.price:remove()
            end
            c1.children.price = nil
            if c1.children.buy_button then
              c1.children.buy_button:remove()
            end
            c1.children.buy_button = nil
            remove_nils(c1.children)
            G.consumeables:emplace(c1)
            G.GAME.pack_choices = G.GAME.pack_choices - 1
            if G.GAME.pack_choices <= 0 then
              G.FUNCS.end_consumeable(nil, delay_fac)
            end
            return true
          end,
        }))
      end
    
      local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
      function G.UIDEF.use_and_sell_buttons(card)
        if (card.area == G.pack_cards and G.pack_cards) and card.ability.consumeable then --Add a use button
          if card.ability.set == "Statement" or card.ability.name == "c_tma_compulsion" then
            return {
              n = G.UIT.ROOT,
              config = { padding = -0.1, colour = G.C.CLEAR },
              nodes = {
                {
                  n = G.UIT.R,
                  config = {
                    ref_table = card,
                    r = 0.08,
                    padding = 0.1,
                    align = "bm",
                    minw = 0.5 * card.T.w - 0.15,
                    minh = 0.7 * card.T.h,
                    maxw = 0.7 * card.T.w - 0.15,
                    hover = true,
                    shadow = true,
                    colour = G.C.UI.BACKGROUND_INACTIVE,
                    one_press = true,
                    button = "use_card",
                    func = "can_reserve_card",
                  },
                  nodes = {
                    {
                      n = G.UIT.T,
                      config = {
                        text = localize("b_take"),
                        colour = G.C.UI.TEXT_LIGHT,
                        scale = 0.55,
                        shadow = true,
                      },
                    },
                  },
                },
              },
            }
          end
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
      end
      local GCanDiscard = G.FUNCS.can_discard
      G.FUNCS.can_discard = function(e)
        local indulgence = nil
	if G.consumeables then
        for i=1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.name == "c_tma_indulgence" and G.consumeables.cards[i].ability.extra.active then
                indulgence = G.consumeables.cards[i]
            end
        end
	end
        if not indulgence then return GCanDiscard(e) end
        if G.GAME.current_round.discards_left <= 0 or #G.hand.highlighted <= 0 then 
            if (G.GAME.dollars >= indulgence.ability.extra.cost) and not (#G.hand.highlighted <= 0) then
                e.config.colour = G.C.MONEY
                e.config.button = 'discard_cards_from_highlighted'
            else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
            end
        else
            e.config.colour = G.C.RED
            e.config.button = 'discard_cards_from_highlighted'
        end
      end
----------------------------------------------
------------MOD CODE END----------------------
