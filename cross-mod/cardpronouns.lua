-----------
-- PRONOUNS
-- They/It
-----------
CardPronouns.Pronoun { key = "they_it",
    colour = HEX("A83EFF"),
    text_colour = G.C.WHITE,
    pronoun_table = { "They", "It" },
    in_pool = function()
        return false
    end,
}

-----------------------------
-- CARD PRONOUNS
-- Playing Card
-- King of Optics - They/Them
-----------------------------
CardPronouns.PlayingCardOverride { key = "king_of_optics",
	suit = "ovn_Optics",
	rank = "King",
	strict = true,
	pronoun = "they_them",
}

------------------------------
-- CARD PRONOUNS
-- Playing Card
-- Queen of Optics - They/Them
------------------------------
CardPronouns.PlayingCardOverride { key = "queen_of_optics",
	suit = "ovn_Optics",
	rank = "Queen",
	strict = true,
	pronoun = "they_them",
}

----------------------------
-- CARD PRONOUNS
-- Playing Card
-- all other Optics - It/Its
----------------------------
CardPronouns.PlayingCardOverride { key = "all_optics",
	suit = "ovn_Optics",
	strict = false,
	pronoun = "it_its",
}

--------------------
-- CARD PRONOUNS
-- Consumable
-- Eidolon - They/It
--------------------
SMODS.Consumable:take_ownership("c_ovn_eidolon", {
	pronouns = "they_it"
})