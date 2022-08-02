panel = [[
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ $title                                       ┃
┣━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━┫
┃ $time         ┃ $s   ┃ $sng  ┃ $f     ┃ $fmt ┃
┗━━━━━━━━━━━━━━━┻━━━━━━┻━━━━━━━┻━━━━━━━━┻━━━━━━┛
]]


function render(meta)
    draw('title', meta.title)
    draw('fmt', meta.format)
    secs = meta.seconds
    len = meta.length
    if len == 0 then
        draw('time', string.format('%02d:%02d', secs // 60, secs % 60))
    else
        draw('time', string.format('%02d:%02d / %02d:%02d', secs // 60, secs % 60, len // 60, len % 60))
    end
end

function init()
    draw("s", "SONG")
    draw("f", "FORMAT")
end

set_theme({
        panel = panel, -- Scaled and parsed
        render_fn = render -- Function that draws
    })


