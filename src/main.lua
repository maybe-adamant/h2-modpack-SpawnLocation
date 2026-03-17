local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib'].public

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "SpawnInTrainingGrounds",
    name     = "Spawn in Training Grounds",
    category = "QoLSettings",
    group    = "QoL",
    tooltip  = "Spawns you in the Training Grounds instead of the House of Hades. Useful for testing and practicing.",
    default  = true,
    dataMutation = false,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
end

local function registerHooks()
    modutil.mod.Path.Context.Wrap("KillHero", function(base, victim, triggerArgs)
        modutil.mod.Path.Wrap("LoadMap", function(base, argTable)
            if not config.Enabled then
                base(argTable)
                return
            end
            if argTable.Name == "Hub_Main" then
                argTable.Name = "Hub_PreRun"
            end
            base(argTable)
        end)
    end)
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
        if public.definition.dataMutation and not mods['adamant-Core'] then
            SetupRunData()
        end
    end)
end)

lib.standaloneUI(public.definition, config, apply, restore)
