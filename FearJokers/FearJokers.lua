--- STEAMODDED HEADER
--- MOD_NAME: The Dread Jokers
--- MOD_ID: FearJokers
--- MOD_AUTHOR: [LunaAstraCassiopeia]
--- MOD_DESCRIPTION: Some Jokers inspired by the Magnus Archives podcast

----------------------------------------------
------------MOD CODE -------------------------


function SMODS.INIT.FearJokers()

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

    --[[ Adding Jokers
    local card_add_deck = Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        if not self.added_to_deck then
            if self.ability.name == 'j_tma_Boneturner' then
                G.hand:change_size(-self.ability.extra.h_size)
            end
        end
        return card_add_deck(self, from_debuff)
    end
    -- Losing Jokers
    local card_remove_deck = Card.remove_from_deck
    function Card:remove_from_deck(from_debuff)
        if self.added_to_deck then
            if self.ability.name == 'j_tma_Boneturner' then
                G.hand:change_size(self.ability.extra.h_size)
            end
        end
        return card_remove_deck(self, from_debuff)
    end ]]--

    -- Cool Straights :))))
    local cool_get_straight = get_straight
    function get_straight(hand)
        if not next(SMODS.find_card("j_tma_Boneturner")) then return cool_get_straight(hand) end
        local ret = {}
        local four_fingers = next(find_joker('Four Fingers'))
        if #hand > 5 or #hand < (5 - (four_fingers and 1 or 0)) then return ret else
        local t = {}
        local IDS = {}
        local face_replace = next(find_joker('j_tma_Boneturner'))
        for i=1, #hand do
            local id = hand[i]:get_id()
            if id > 1 and id < 15 then
                if IDS[id] then
                    IDS[id][#IDS[id]+1] = hand[i]
                else
                    IDS[id] = {hand[i]}
                end
            end
        end
    
        local straight_length = 0
        local straight = false
        local can_skip = next(find_joker('Shortcut')) 
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
        else
            straight_length = 0
            skipped_rank = false
            if not straight then t = {} end
            if straight then break end
            end
            if straight_length >= (5 - (four_fingers and 1 or 0)) then straight = true end 
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
        if not next(SMODS.find_card("j_tma_Boneturner")) then return cool_get_X_same(num, hand, or_more) end
        local vals = {}
        for i = 1, SMODS.Rank.max_id.value do
            vals[i] = {}
        end
        for i=#hand, 1, -1 do
            local curr = {}
            table.insert(curr, hand[i])
            for j=1, #hand do
                if hand[i]:get_id() == hand[j]:get_id() and i ~= j then
                    table.insert(curr, hand[j])
                elseif hand[i]:get_id() >= 11 and hand[i]:get_id() <= 13 and hand[j]:get_id() >= 11 and hand[j]:get_id() <= 13 and i ~= j then
                    table.insert(curr, hand[j])
                end
            end
            if or_more and (#curr >= num) or (#curr == num) then
                if curr[1]:get_id() >= 11 and curr[1]:get_id() <= 13 then
                    vals[13] = curr
                else
                    vals[curr[1]:get_id()] = curr
                end
            end
        end
        local ret = {}
        for i=#vals, 1, -1 do
            if next(vals[i]) then table.insert(ret, vals[i]) end
        end
        return ret
    end
    
    --[[ Wild Faces
    local card_get_id = Card.get_id
    function Card:get_id()
        local id = card_get_id(self)
        if id == 11 or id == 12 or id == 13 then
            if next(find_joker('j_tma_Boneturner')) then
                return 1006
            end
        end
        return card_get_id(self)
    end
    
    local card_is_face = Card.is_face
    function Card:is_face(from_boss)
        local id = self:get_id()
        if id == 1006 then
            return true
        end
        return card_is_face(self, from_boss)
    end ]]--
        
    
    --[[local card_is_suit = Card.get_id
    function Card:is_suit(suit, bypass_debuff, flush_calc)
        if self:is_face() then
            if flush_calc then
                if next(find_joker('j_tma_Boneturner')) then
                    return true
                end
            else
                if next(find_joker('j_tma_Boneturner')) then
                    return true
                end
            end
        end
        return card_is_suit(self, suit, bypass_debuff, flush_calc)
    end ]]--

    --NowhereToGo
    SMODS.Joker({
        key = 'tma_NowhereToGo', atlas = 'tma_joker', pos = {x = 0, y = 0}, rarity = 2, cost = 7, blueprint_compat = true, 
        config = {
            x_mult = 1,
            extra = {
                mult_mod = 0.2,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.x_mult, card.ability.extra.mult_mod}
            }
        end,
        calculate = function(self,card,context)
            if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
                card.ability.x_mult = 1
                return {
                    message = localize('k_reset'),
                    colour = G.C.RED
                }
            elseif SMODS.end_calculate_context(context) and card.ability.x_mult > 1 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                    Xmult_mod = card.ability.x_mult
                }
            end
            if context.individual and not context.blueprint and context.cardarea == G.play and context.other_card:is_suit("Spades") then
                card.ability.x_mult = card.ability.x_mult + card.ability.extra.mult_mod
                return {
                    extra = {focus = card, message = localize('k_upgrade_ex')},
                    card = card,
                    colour = G.C.RED
                }
            end
        end
    })
    
    -- Plague Doctor
    SMODS.Joker({
        key = 'tma_PlagueDoctor', atlas = 'tma_joker', pos = {x = 1, y = 0}, rarity = 2, cost = 5, blueprint_compat = false, 
        calculate = function(self,card,context)
            if context.ending_shop then
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
        key = 'tma_BlindSun', atlas = 'tma_joker', pos = {x = 2, y = 0}, rarity = 2, cost = 8, blueprint_compat = true, 
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
            if context.individual and context.cardarea == G.play and context.other_card then
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
        key = 'tma_LightlessFlame', atlas = 'tma_joker', pos = {x = 3, y = 0}, rarity = 1, cost = 4, blueprint_compat = true, 
        config = {
            mult_mod = 0,
            extra = {
                bonus_mult = 3,
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
            if SMODS.end_calculate_context(context) and card.ability.mult_mod > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.mult_mod}},
                    mult_mod = card.ability.mult_mod
                }
            end
        end
    })

    -- Last Laugh
    SMODS.Joker({
        key = 'tma_LastLaugh', atlas = 'tma_joker', pos = {x = 4, y = 0}, rarity = 2, cost = 6, blueprint_compat = true, 
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
            if SMODS.end_calculate_context(context) and #G.deck.cards == 0 then
                return {
                    message = localize{type='variable',key='a_xmult',vars={card.ability.extra.woah_x_mult}},
                    Xmult_mod = card.ability.x_mult
                }
            end
        end
    })

    -- Panopticon
    SMODS.Joker({
        key = 'tma_Panopticon', atlas = 'tma_joker', pos = {x = 5, y = 0}, rarity = 3, cost = 7, blueprint_compat = true, 
        config = {
            extra = {
                chips = 0,
                chips_mod = 30
            }
        },
        loc_vars = function(self,info_queue,card)
            local spectrals_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Spectral' then spectrals_used = spectrals_used + 1 end end
            return {vars = {card.ability.extra.chips_mod, spectrals_used*card.ability.extra.chips_mod}}
        end,
        calculate = function(self,card,context)
            if SMODS.end_calculate_context(context) then
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
        key = 'tma_Boneturner', atlas = 'tma_joker', pos = {x = 6, y = 0}, rarity = 3, cost = 8, blueprint_compat = false
    })
    
    -- Lonely Joker
    SMODS.Joker({
        key = 'tma_Lonely', atlas = 'tma_joker', pos = {x = 8, y = 0}, rarity = 1, cost = 5, blueprint_compat = true, 
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
            if context.before and not context.blueprint and next(context.poker_hands['High Card']) then
                card.ability.mult_mod = card.ability.mult_mod + card.ability.extra.mult_bonus
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED,
                    card = card
                }
            end
            if SMODS.end_calculate_context(context) and card.ability.mult_mod > 0 then
                return {
                    message = localize{type='variable',key='a_mult',vars={card.ability.mult_mod}},
                    mult_mod = card.ability.mult_mod
                }
            end
        end
    })

    -- Distortion
    SMODS.Joker({
        key = 'tma_Distortion', atlas = 'tma_joker', pos = {x = 9, y = 0}, rarity = 1, cost = 4, blueprint_compat = false
    })

    -- Fallen Titan
    SMODS.Joker({
        key = 'tma_FallenTitan', atlas = 'tma_joker', pos = {x = 7, y = 0}, rarity = 2, cost = 7, blueprint_compat = true, 
        config = {
            extra = {
                bonus_chips = 30
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
    
    -- The Rot (Tarot)
    SMODS.Consumable {
        set = 'Tarot', atlas = 'tma_tarot', key = 'tma_the_rot',
        pos = { x = 0, y = 0 },
        config = {max_highlighted = 1, mod_conv = 'm_stone'}, hidden = true,
        in_pool = function(self)
            return false
        end,
        loc_vars = function(self) return {vars = {self.config.max_highlighted}} end, effect = "Enhance", cost_mult = 1.0
    }
    --[[
    SMODS.Enhancement {
        set = 'Enhanced', atlas = 'tma_tarot', key = 'tma_rotting',
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
        set = 'Planet', atlas = 'tma_tarot', key = 'tma_colony',
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
        set = 'Spectral', atlas = 'tma_tarot', key = 'tma_decay',
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
end

----------------------------------------------
------------MOD CODE END----------------------
