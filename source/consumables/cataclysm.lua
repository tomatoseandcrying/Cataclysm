--- Cataclysm Cards Base
if CLYT.debug then print("=-- Loading Cataclysm Cards ...") end

--- Atlas
SMODS.Atlas {
    key = "CataclysmSprites",
    path = "cataclysmcards.png",
    px = 83,
    py = 103
};

SMODS.Atlas {
    key = "CataclysmIndicators",
    path = "cataindicators.png",
    px = 23,
    py = 23
};

--- Cataclysm Cards Consumable Type
SMODS.ConsumableType {
    key = "Cataclysm",

    primary_colour = G.C.WHITE,
    secondary_colour = HEX("3D2228"),

    collection_rows = {4, 3},
    shop_rate = 0,

    select_card = "consumeables"
};

CLYT.Cataclysm = SMODS.Consumable:extend{
	object_type = "Consumable",
	set = "Colour",
    
    cost = 7, -- change ?
    display_size = { w = 83, h = 103 },
    atlas = "clyt_CataclysmSprites",

    use_main_end = true,
	set_ability = function(self, card, initial, delay_sprites)
        card.ability.active = false
        card.ability.default_pos = card.config.center.pos;
        card.ability.default_atlas = card.config.center.atlas;
        card.ability.default_vt_scale = card.VT.scale;
        card.ability.default_t_scale = card.T.scale;
	end,

    loc_vars = function(self, info, card)
        if not self.use_main_end then return end
        card.ability.rounds_remaining = card.ability.rounds_remaining or card.ability.rounds or 0;
        card.ability.active = card.ability.active or false;
        card.ability.rounds = card.ability.rounds or 1;

        local active = card.ability.active;
        local in_area = card.area == G.clyt_cataclysms;
        local progress = (card.ability.rounds - card.ability.rounds_remaining) .. " / " .. card.ability.rounds;
        local progress_colour = (active and G.C.GREEN) or (in_area and G.C.FILTER) or G.C.RED;
        local progress_text = (active and localize("k_clyt_active")) or (in_area and progress) or localize("k_clyt_inactive");

        return {
            main_end = G.FUNCS.clyt_generate_main_end(card, progress_colour, progress_text:lower())
        }
    end,

    set_indicator = function(self, card, shrink)
        if not card.config.center.indicator then return false end
        local indicator = card.config.center.indicator

        if shrink then
            -- card.T.scale = 0.34
            -- card.VT.scale = 0.34
            card.T.h = G.CARD_H*(indicator.display_size.h/95)*4
            card.T.w = G.CARD_W*(indicator.display_size.w/71)*4
            
            card.children.center:remove()
            card.children.center = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[indicator.atlas_key], indicator.pos)
            card.children.center.states.hover = card.states.hover
            card.children.center.states.click = card.states.click
            card.children.center.states.drag = card.states.drag
            card.children.center.states.collide.can = false
            card.children.center:set_role({major = card, role_type = 'Glued', draw_major = card})
            -- card.children.center.atlas = G.ASSET_ATLAS[indicator.atlas_key];
            -- -- card.children.center.scale = { x = card.children.center.atlas.px, y = card.children.center.atlas.py }
            -- card.children.center:set_sprite_pos(indicator.pos);
        else
            card.T.scale = card.ability.default_t_scale * indicator.scale_mod
            card.VT.scale = card.ability.default_vt_scale * indicator.scale_mod
            card.T.h = G.CARD_H*(indicator.display_size.h/23)
            card.T.w = G.CARD_W*(indicator.display_size.w/23)

            card.children.center:remove()
            card.children.center = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, card.ability.default_atlas, card.ability.default_pos)
            card.children.center.states.hover = card.states.hover
            card.children.center.states.click = card.states.click
            card.children.center.states.drag = card.states.drag
            card.children.center.states.collide.can = false
            card.children.center:set_role({major = card, role_type = 'Glued', draw_major = card})
            -- card.children.center.atlas = card.ability.default_atlas;
            -- card.children.center:set_sprite_pos({ x = card.ability.default_pos.x, y = card.ability.default_pos.y });
        end

        card:juice_up(0.3, 0.2);
    end,

    update = function(self, card, dt)
        if not card.config.center.indicator then return end
        if card.ability.active then
            if card.ability.indicating then
                card.ability.indicating = false;
                card.config.center.set_indicator(card.config.center, card, false);
            end
            return
        end
        if (not not not card.ability.indicating) and card.T.scale <= card.ability.default_t_scale * card.config.center.indicator.scale_mod * 1.2 then
            if card.children.center.atlas ~= G.ASSET_ATLAS[card.config.center.indicator.atlas_key] then
                card.config.center.set_indicator(card.config.center, card, true);
                card.ability.indicating = true;
            end
        elseif card.children.center.atlas ~= card.ability.default_atlas and card.ability.indicating and card.T.scale > card.ability.default_t_scale / card.config.center.indicator.scale_mod * 1.2 then
            card.config.center.set_indicator(card.config.center, card, false);
            card.ability.indicating = false;
        end
    end,

	can_use = function(self, card)
        if card.area == G.shop_jokers and G.shop_jokers then return false end
        if card.ability.active then
            if card.config.center.can_use_active then return card.config.center.can_use_active(self, card) end
        else
            if card.config.center.can_use_inactive then return card.config.center.can_use_inactive(self, card) end
        end
		return false
	end,

    use = function(self, card, area)
        if card.ability.active then
            if card.config.center.use_active then
                card.config.center.use_active(self, card)
            end
        else
            if card.config.center.use_inactive then card.config.center.use_inactive(self, card) end
            card.ability.rounds_remaining = card.ability.rounds
            G.consumeables:remove_card(card);
            G.clyt_cataclysms:emplace(card);
            CLYT.shrink_card(card);
        end
	end,

    keep_on_use = function(self, card)
        return not card.ability.active
    end,
}

-- Deluge
CLYT.Cataclysm {
    key = "deluge",
    set = "Cataclysm",
    pos = { x = 0, y = 0 },
}

-- Doomsday
CLYT.Cataclysm {
    key = "doomsday",
    set = "Cataclysm",
    pos = { x = 1, y = 0 },
}

-- Paroxysm
CLYT.Cataclysm {
    key = "paroxysm",
    set = "Cataclysm",
    pos = { x = 2, y = 0 },
}

-- Invasion
CLYT.Cataclysm {
    key = "invasion",
    set = "Cataclysm",
    pos = { x = 3, y = 0 },
    indicator = { 
        atlas_key = "clyt_CataclysmIndicators", 
        pos = { x = 3, y = 0 },
        display_size = { w = 23, h = 23 },
        scale_mod = 0.25
    },

    config = { rounds = 2, },

    can_use_inactive = function(self, card)
        return true
    end,
    can_use_active = function(self, card)
        return true
    end,
    use_inactive = function(self, card)
        card.ability.stored_discards = G.GAME.round_resets.discards
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.stored_discards
        ease_discard(-card.ability.stored_discards)
    end,
    use_active = function(self, card)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.stored_discards
        ease_discard(card.ability.stored_discards)

        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 2
    end,
}

-- Absolution
CLYT.Cataclysm {
    key = "absolution",
    set = "Cataclysm",
    pos = { x = 4, y = 0 },
}

-- Plague
CLYT.Cataclysm {
    key = "plague",
    set = "Cataclysm",
    pos = { x = 5, y = 0 },
}

-- Disaster
CLYT.Cataclysm {
    key = "disaster",
    set = "Cataclysm",
    pos = { x = 6, y = 0 },
    indicator = { 
        atlas_key = "clyt_CataclysmIndicators", 
        pos = { x = 6, y = 0 },
        display_size = { w = 23, h = 23 },
        scale_mod = 0.25
    },
    config = { rounds = 3, },
    can_use_inactive = function(self, card)
        return true
    end,
    can_use_active = function(self, card)
        return true
    end,
    use_inactive = function(self, card)
        G.hand.config.card_limit = G.hand.config.card_limit - 2
    end,
    use_active = function(self, card)
        SMODS.change_play_limit(1)
        G.hand.config.card_limit = G.hand.config.card_limit + 3
    end,
}

-- Collision
CLYT.Cataclysm {
    key = "collision",
    set = "Cataclysm",
    pos = { x = 7, y = 0 },
}

-- Takeover
CLYT.Cataclysm {
    key = "takeover",
    set = "Cataclysm",
    pos = { x = 8, y = 0 },
    indicator = { 
        atlas_key = "clyt_CataclysmIndicators", 
        pos = { x = 8, y = 0 },
        display_size = { w = 23, h = 23 },
        scale_mod = 0.25
    },

    config = { rounds = 3, stored_slots = 0, slots_gained = 1 },
    can_use_inactive = function(self, card)
        return true
    end,

    can_use_active = function(self, card)
        return true
    end,

    use_inactive = function(self, card)
        card.ability.stored_slots = G.consumeables.config.card_limit
        G.consumeables.config.card_limit = G.consumeables.config.card_limit - card.ability.stored_slots
    end,
    
    use_active = function(self, card)
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + card.ability.stored_slots
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.slots_gained
    end,
}

-- Maleficence
CLYT.Cataclysm {
    key = "maleficence",
    set = "Cataclysm",
    pos = { x = 0, y = 1 },
}

-- Rip
CLYT.Cataclysm {
    key = "rip",
    set = "Cataclysm",
    pos = { x = 1, y = 1 },
}

-- Crunch
CLYT.Cataclysm {
    key = "crunch",
    set = "Cataclysm",
    pos = { x = 2, y = 1 },
}

-- Heat Death
CLYT.Cataclysm {
    key = "heat_death",
    set = "Cataclysm",
    pos = { x = 3, y = 1 },
}

-- Vacuum Decay
CLYT.Cataclysm {
    key = "vacuum_decay",
    set = "Cataclysm",
    pos = { x = 4, y = 1 },
}

-- Occulture
CLYT.Cataclysm {
    key = "occulture",
    set = "Cataclysm",
    pos = { x = 5, y = 1 },
}

-- Postexistence
CLYT.Cataclysm {
    key = "postexistence",
    set = "Cataclysm",
    pos = { x = 6, y = 1 },
}

-- Stagnancy
CLYT.Cataclysm {
    key = "stagnancy",
    set = "Cataclysm",
    pos = { x = 7, y = 1 },
}

-- Tempest
CLYT.Cataclysm {
    key = "tempest",
    set = "Cataclysm",
    pos = { x = 8, y = 1 },
    indicator = { 
        atlas_key = "clyt_CataclysmIndicators", 
        pos = { x = 8, y = 1 },
        display_size = { w = 23, h = 23 },
        scale_mod = 0.25
    },
    config = { rounds = 3, blindsize = 2, },
    can_use_inactive = function(self, card)
        return true
    end,
    can_use_active = function(self, card)
        return true
    end,
    use_inactive = function(self, card)
        G.GAME.blind_size_multiplier = G.GAME.blind_size_multiplier * 2
    end,
    use_active = function(self, card)
        G.GAME.blind_size_multiplier = G.GAME.blind_size_multiplier / 2
		SMODS.change_voucher_limit(1)
    end,
}

-- Damnation
CLYT.Cataclysm {
    key = "damnation",
    set = "Cataclysm",
    pos = { x = 1, y = 2 },
}

-- Black Hole Sun
CLYT.Cataclysm {
    key = "black_hole_sun",
    set = "Cataclysm",
    pos = { x = 2, y = 2 },
}

-- Anathema
CLYT.Cataclysm {
    key = "anathema",
    set = "Cataclysm",
    pos = { x = 3, y = 2 },
}



-- miracle display

CLYT.custom_card_areas = function(game)
	game.clyt_cataclysms = CardArea(
		game.consumeables.T.x, game.consumeables.T.y - 0.6,
        game.consumeables.T.w, 0.5,
        { card_limit = 9999, type = 'joker', highlight_limit = 0, no_card_count = true, }
	)
end

local ca_rfh = CardArea.remove_from_highlighted
function CardArea:remove_from_highlighted(card, force)
    if card then
        ca_rfh(self, card, force)
    end
end

local ca_ath = CardArea.add_to_highlighted
function CardArea:add_to_highlighted(card, silent)
    if card and card.area ~= G.clyt_cataclysms then
        ca_ath(self, card, silent)
    end
end

-- thank you alexi !!!

--- Shrinks a card
function CLYT.shrink_card(card, instant, indicator)
    indicator = indicator or {};
    if card.clyt_scale_collision then return nil end
    card.clyt_scale_collision = true
    card.config.center.default_atlas = card.config.center.default_atlas or card.children.center.atlas;
    card.config.center.default_pos = card.config.center.default_pos or card.config.center.pos;

    if instant then
        if #indicator < 1 then
            card.T.scale = card.T.scale * 0.25
            card.VT.scale = card.VT.scale * 0.25

            card.children.center.atlas = card.config.center.default_atlas;
        else
            card.config.center.set_indicator(card.config.center, card, true);
        end
    else
        ease_value(card.T, "scale", -card.T.scale * (1 - 0.25), nil, "REAL", nil, 0.02, "outquad")
    end
end

function CLYT.unshrink_card(card, instant)
    if not card.clyt_scale_collision then return nil end
    card.config.center.default_atlas = card.config.center.default_atlas or card.children.center.atlas;
    card.config.center.default_pos = card.config.center.default_pos or card.config.center.pos;
    card.clyt_scale_collision = false
    
    if card.config.center.set_indicator then
        card.config.center.set_indicator(card.config.center, card, false);
    end
    card.ability.indicating = false;

    if instant then
        if #indicator < 1 then
            card.T.scale = card.T.scale / 0.25
            card.VT.scale = card.VT.scale / 0.25
        else
            card.config.center.set_indicator(card.config.center, card, false);
        end
    else
        ease_value(card.T, "scale", card.T.scale * 3, nil, "REAL", nil, 0.02, "outquad")
    end
end

local mju = Moveable.juice_up
function Moveable:juice_up(amount, rot_amt, ...)
    local ret = mju(self, amount, rot_amt, ...)

    if G.SETTINGS.reduced_motion then return end
    if self.clyt_scale_collision then
        self.VT.scale = self.VT.scale * self.T.scale
    end
    return ret
end

local game_start_run = Game.start_run
function Game:start_run(args)
    game_start_run(self, args)
    if G.clyt_cataclysms then
        if G.bcats_miracles and not G.GAME.clyt_bcats_fix then
            G.GAME.clyt_bcats_fix = true
            G.bcats_miracles.T.w = G.bcats_miracles.T.w * 0.45
            G.clyt_cataclysms.T.w = G.clyt_cataclysms.T.w * 0.45
            G.clyt_cataclysms.T.x = G.clyt_cataclysms.T.x + G.bcats_miracles.T.w * 0.55 / 0.45
        end

        for _, card in ipairs(G.clyt_cataclysms.cards) do
            CLYT.shrink_card(card, true)
        end
    end
end

--- End Debug
if CLYT.debug then print("=-- Successfully loaded!") end