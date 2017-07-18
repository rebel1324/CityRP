local gohomeMotherfuckers = 15
local PANEL = {}
    function PANEL:Init()
        self.icons = {}
        for a = 1, 2 do
            for i = 1, 15 do
                self.icons[i * a] = "dildoinass" 
            end
        end
    end

    function PANEL:fillRoller()
    end

    function PANEL:roll()
    end

    function PANEL:finish()
        -- when the rolling is finished
    end

    function PANEL:Think()
        -- roll the mother fucker.
    end
vgui.Register("nutCrateRoller", PANEL, "EditablePanel")
