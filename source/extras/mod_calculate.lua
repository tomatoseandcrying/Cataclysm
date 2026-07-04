CLYT.calculate = function(self, context)
	local res = {}

	if context.end_of_round and context.main_eval then
		for _, card in pairs(G.clyt_cataclysms.cards) do
			card.ability.rounds_remaining = card.ability.rounds_remaining - 1
			if card.ability.rounds_remaining == 0 then
				CLYT.unshrink_card(card)
				G.clyt_cataclysms:remove_card(card);
				G.consumeables:emplace(card);
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "Complete!",
					colour = G.C.RED,
					card = card,
				})
				
				card.ability.active = true;
			else
				local str = card.ability.rounds_remaining .. "/" .. card.ability.rounds
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = str,
					colour = G.C.RED,
					card = card,
				})
			end
		end
	end

	return SMODS.merge_effects(res)
end
