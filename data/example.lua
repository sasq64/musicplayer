panel = [[
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$>━┓
┃ $title_and_composer                            $> ┃
┃ $sub_title                                     $> ┃
┣━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━$>━┫
┃ $t_l          ┃ SONG ┃ $s_s  ┃ FORMAT ┃ $format$> ┃
┗━━━━━━━━━━━━━━━┻━━━━━━┻━━━━━━━┻━━━━━━━━┻━━━━━━━━$>━┛
]]

function psplit(s)
    parts = {}
    for p in string.gmatch(s, '[^/]+') do
        table.insert(parts, p)
    end
    return parts
end

function contains(list, element)
    for _,v in pairs(list) do
        if v == element then
            return true
        end
    end
    return false
end


function copy(src, dest)
    infile = io.open(src, "r")
    instr = infile:read("*a")
    infile:close()
    print(dest)

    outfile = io.open(dest, "w")
    outfile:write(instr)
    outfile:close()
end

function capitalize(txt)
    res = ''
    s = ''
    for p in string.gmatch(txt, '[^%s]+') do
        res = res .. s .. p:sub(1,1):upper()..p:sub(2)
        s = ' '
    end
    return res
end

function get_composer(meta)
    parts = psplit(meta.filename)
    composer = meta.composer
    if composer == '' then
       if #parts > 3 and contains(parts, 'MODLAND') then
           composer = parts[#parts - 1]
           if composer:find('coop-') == 1 then
               composer = parts[#parts - 2] .. ' & ' .. composer:sub(6)
           end
       else
           composer = '???'
       end
    end
    return composer
end

function ext(filename)
    return filename:match("^.+(%..+)$")
end

map(KEY_F3, function()
    meta = get_meta()
    composer = get_composer(meta)
    copy(meta.filename, "/Users/sasq/mods/" .. composer ..
            " - " .. meta.fixed_title .. ext(meta.filename))
end)


function update(meta)
    title = meta.fixed_title
    composer = meta.composer

    parts = psplit(meta.filename)

    if composer == '' then
        if #parts > 3 and contains(parts, 'MODLAND') then
            title = capitalize(title)
            composer = parts[#parts - 1]
            if composer:find('coop-') == 1 then
                composer = parts[#parts - 2] .. ' & ' .. composer:sub(6)
            end
        else
            composer = '???'
        end
    end
    meta.title_and_composer = title .. ' / ' .. composer
end

function init()
    colorize("SONG", YELLOW)
    colorize("FORMAT", YELLOW)
    -- colorize(1,1,80,WHITE,RED)
    var_color("sub_title", GRAY, BLACK)
    var_color("title_and_composer", WHITE, BLACK)
end

set_theme({
        panel = panel, -- Scaled and parsed
        init_fn = init, -- Called after panel base is drawn
        update_fn = update, -- Called whenever meta updates
        var_fg = RED,
})


