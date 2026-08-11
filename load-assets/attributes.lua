local attributes = {
    "ovn_optics",
    "ovn_corrupting",
    "ovn_purifying",
}

for _,attr in ipairs(attributes) do
	SMODS.Attribute {key = attr}
end