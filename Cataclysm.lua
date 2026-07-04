-- Cataclysm Mod
CLYT = SMODS.current_mod;
CLYT.debug = true;

if CLYT.debug then
    print("=-- ...");
    print("=-- Cataclysm (Loading Sequence)");
end

--  Loading stuff
local function load_dir(subfolder)
    local mod_dir = CLYT.path;
    local dir_items = SMODS.NFS.getDirectoryItems(mod_dir .. subfolder);

    local loaded_items = {};
    for _, item in ipairs(dir_items) do
        if item:match("%.lua$") then
            local file_path = subfolder .. "/" .. item;
            loaded_items[#loaded_items + 1] = SMODS.load_file(file_path);
        end
    end

    for _, item in ipairs(loaded_items) do
        assert(item)();
    end
end

load_dir("source/extras");
load_dir("source/consumables");