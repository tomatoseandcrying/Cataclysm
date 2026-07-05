G.FUNCS.clyt_generate_main_end = function(card, color, text)
    return {
        {
            n = G.UIT.C,
            config = { align = "bm", minh = 0.4 },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { ref_table = card, align = "m", colour = mix_colours(color, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                    nodes = {
                        { n = G.UIT.T, config = { text = ' ' .. text .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                    }
                }
            }
        }
    }
end