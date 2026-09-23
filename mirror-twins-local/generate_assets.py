from pathlib import Path
import struct, zlib, math, wave

ROOT=Path(__file__).parent/'app/src/main/assets/www/assets'
ROOT.mkdir(parents=True,exist_ok=True)
AUDIO=ROOT/'audio'; AUDIO.mkdir(exist_ok=True)

def png_chunk(kind,data):
    return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)

def write_world(name, top, bottom, seed, glows):
    w,h=540,960
    raw=bytearray()
    state=seed & 0xffffffff
    for y in range(h):
        raw.append(0)
        t=y/(h-1)
        base=[int(top[i]*(1-t)+bottom[i]*t) for i in range(3)]
        for x in range(w):
            state=(1664525*state+1013904223)&0xffffffff
            n=((state>>24)&15)-7
            r,g,b=[max(0,min(255,c+n)) for c in base]
            for cx,cy,rad,col,strength in glows:
                dx=x-cx; dy=y-cy; d2=dx*dx+dy*dy
                if d2<rad*rad:
                    f=(1-math.sqrt(d2)/rad)*strength
                    r=min(255,int(r+col[0]*f)); g=min(255,int(g+col[1]*f)); b=min(255,int(b+col[2]*f))
            if 80<x<460 and 235<y<770 and ((y-235)%92<4 or (x-80)%95<3):
                r=min(255,r+12);g=min(255,g+14);b=min(255,b+18)
            raw.extend((r,g,b))
    data=png_chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,2,0,0,0))+png_chunk(b'IDAT',zlib.compress(bytes(raw),7))+png_chunk(b'IEND',b'')
    (ROOT/name).write_bytes(b'\x89PNG\r\n\x1a\n'+data)

write_world('world_garden.png',(8,20,45),(20,50,64),11,[(130,260,180,(38,110,220),.65),(420,230,170,(220,48,128),.55),(270,720,260,(22,105,80),.40)])
write_world('world_moon.png',(12,12,43),(31,22,61),22,[(120,250,170,(40,90,220),.62),(430,330,190,(160,55,215),.55),(270,690,260,(70,50,170),.38)])
write_world('world_mirror.png',(7,26,40),(15,19,41),33,[(135,210,175,(25,135,220),.66),(410,230,175,(220,45,135),.62),(270,700,270,(200,140,35),.30)])
write_world('world_night.png',(5,10,25),(18,27,52),44,[(95,260,160,(45,80,200),.62),(440,260,165,(205,40,110),.55),(270,760,260,(45,45,150),.42)])
write_world('splash.png',(5,10,26),(10,20,42),71,[(150,350,220,(40,110,230),.80),(390,350,220,(225,55,140),.75),(270,700,300,(150,105,35),.25)])

SR=22050
def wav(path, duration, sample_fn):
    count=int(SR*duration)
    with wave.open(str(path),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(SR)
        frames=bytearray()
        for i in range(count):
            v=max(-1.0,min(1.0,sample_fn(i/SR,i)))
            frames.extend(struct.pack('<h',int(v*32767)))
        f.writeframes(frames)

noise=0x13579BDF
def ambience(t,i):
    global noise
    noise=(1103515245*noise+12345)&0x7fffffff
    n=((noise>>12)&1023)/1023-.5
    chord=.12*math.sin(2*math.pi*110*t)+.08*math.sin(2*math.pi*165*t)+.055*math.sin(2*math.pi*220*t)
    pulse=.70+.30*math.sin(2*math.pi*.125*t)
    return chord*pulse+n*.018
wav(AUDIO/'music.wav',24.0,ambience)

def tone(freq,dur,decay,amp,extra=0):
    return lambda t,i: amp*math.sin(2*math.pi*freq*t)*math.exp(-decay*t)+(extra*math.sin(2*math.pi*freq*1.5*t)*math.exp(-decay*.7*t) if extra else 0)
wav(AUDIO/'move.wav',.16,tone(360,.16,18,.25))
wav(AUDIO/'crystal.wav',.34,tone(880,.34,7,.30,.16))
def win_fn(t,i):
    if t<.22: f=523
    elif t<.44: f=659
    else: f=784
    return .32*math.sin(2*math.pi*f*t)*math.exp(-2.8*max(0,t-.02))
wav(AUDIO/'win.wav',.82,win_fn)
wav(AUDIO/'tap.wav',.10,tone(220,.10,24,.18))
