import sys
import pyaudio
import musix

stream = pyaudio.PyAudio().open(
        format=pyaudio.paInt16,
        channels=2,
        rate=44100,
        output=True)

musix.init()
player = musix.load(sys.argv[1])

def print_meta(what):
    for name in what:
        val = player.get_meta(name)
        print(f"{name} = {val}\n")
player.on_meta(print_meta)

while True:
    samples = player.render(4096)
    stream.write(samples)

