ITEM.name = "Bandoleer"
ITEM.desc = "조잡하게 만들어진 전투조끼."
ITEM.model = "models/equipmentpack/usgearbandoleer.mdl"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 150
ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["BoneMerge"] = true,
                    ["ClassName"] = "model",
                    ["UniqueID"] = "BANDOL_MODEL",
                    ["Model"] = "models/rebel1324/b_bandol.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "BANDOL_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}