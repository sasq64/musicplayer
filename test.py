import pyaudio
import pixpy as pix
import musix
import math

p = pyaudio.PyAudio()
stream = p.open(format=pyaudio.paInt16,
                channels=2,
                rate=44100,
                output=True)

musix.init()
player = musix.load('musicplayer/music/Castlevania.nsfe')

print(player.get_meta("game"))
print(player.get_meta("length"))


screen = pix.open_display((640, 480))

while pix.run_loop():
    screen.clear()
    screen.filled_circle(screen.size / 2, math.sin(screen.frame_counter / 100) * 100 + 100)
    sz = stream.get_write_available()
    if sz > 0:
        samples = player.render(sz * 2)
        stream.write(samples)
    screen.swap()

stream.close()




