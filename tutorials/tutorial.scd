s.boot;

(
    var notes, on, off;
    MIDIClient.init;
    MIDIIn.connectAll;

    notes = Array.newClear(128);

    on = MIDIFunc.noteOn({ |veloc, num, chan, src|
        notes[num] = Synth(\default, [\freq, num.midicps, \amp, veloc * 0.00315]);
    });

    off = MIDIFunc.noteOff({ |veloc, num, chan, src|
        notes[num].release;
    });

    q = { on.free; off.free; };
)

{ SinOsc.ar(440, 0,0.2)}.play;

(
    { var ampOsc;
        ampOsc = SinOsc.kr(0.5,1.5pi,0.5,0.5);
        SinOsc.ar(440,0,ampOsc);
    }.play;
)

{ [SinOsc.ar(440,0,0.2), SinOsc.ar(442,0,0.2)] }.play;

{ SinOsc.ar([440,442], 0,0.2) }.play;

(
    { var freq;
        freq = [[660,880], [440,660], 1320,880].choose;
        SinOsc.ar(freq,0,0.2);
    }.play;
)

{ Pan2.ar(PinkNoise.ar(0.2), SinOsc.kr(0.5)) }.play;
{ Blip.ar(800,4,0.1) }.play;

{ Mix.new([SinOsc.ar(440,0,0.2), Saw.ar(660,0.2)]).postln }.play;

(
    {
        var a,b;
        a = [SinOsc.ar(440,0,0.2), Saw.ar(662,0.2)];
        b = [SinOsc.ar(442,0,0.2), Saw.ar(660,0.2)];
        Mix([a,b]).postln;
    }.play;
)

(
    var n=99;
    {Mix.fill(n, { SinOsc.ar(500 + 500.0.rand, 0, 1 / n) })}.play;
)

{ PinkNoise.ar(0.2) + SinOsc.ar(440,0,0.2) + Saw.ar(660,0.2) }.scope;

SynthDef.new("tutorial-SinOsc", { Out.ar(0, SinOsc.ar(440,0,0.2)) }).play;

(
    SynthDef.new("tutorial-SinOsc-stereo", { var outArray;
        outArray = [SinOsc.ar(440,0,0.2), SinOsc.ar(442,0,0.2)];
        Out.ar(0,outArray)
    }).play;
)

x = { SinOsc.ar(660,0,0.2) }.play;
x.release;
y = SynthDef.new("tutorial-PinkNoise", { Out.ar(0, PinkNoise.ar(0.2)) }).play;
y.free;

SynthDef.new("tutorial-PinkNoise", { Out.ar(0, PinkNoise.ar(0.2)) }).add;

x = Synth.new("tutorial-PinkNoise");
x.free;
(
    SynthDef("tutorial-args", { | freq=440, out=0 |
        Out.ar(out, SinOsc.ar(freq, 0, 0.2));
    }).add;
)

x = Synth("tutorial-args");
y = Synth("tutorial-args", ["freq", 660, "out", 1]);
y.set("freq", 880);
y.free;
x.free;

(
    SynthDef("tutorial-DecayPink", { |outBus = 0, effectBus, direct=0.5|
        var source;
        source = Decay2.ar(Impulse.ar(2,0.25), 0.01, 0.2, PinkNoise.ar);
        Out.ar(outBus, source*direct);
        Out.ar(effectBus, source*(1-direct));
    }).add;

    SynthDef("tutorial-DecaySin", { |outBus=0, effectBus, direct=0.5|
        var source;
        source = Decay2.ar(Impulse.ar(0.1,0.25), 0.3, 1, SinOsc.ar(SinOsc.kr(0.2,0,110,440)));
        Out.ar(outBus, source * direct);
        Out.ar(effectBus, source * (1-direct));
    }).add;

    SynthDef("tutorial-Reverb", { |outBus=0, inBus|
        var input;
        input = In.ar(inBus, 1);
        16.do({ input = AllpassC.ar(input, 0.04, {Rand(0.001, 0.04) }.dup, 3)});
        Out.ar(outBus, input);
    }).add;

    b = Bus.audio(s, 1);
)
(
    x = Synth.new("tutorial-Reverb", [\inBus, b]);
    y = Synth.before(x, "tutorial-DecayPink", [\effectBus, b]);
    z = Synth.before(x, "tutorial-DecaySin", [\effectBus, b, \outBus, 1]);
)

y.set(\direct, 0.2);
z.set(\direct, 0.1);

x.free; y.free; z.free; b.free;

(
    b = Bus.control(s, 1); b.set(880);
    c = Bus.control(s, 1); c.set(884);
    x = SynthDef("tutorial-map", { |freq1 = 440, freq2=440|
        Out.ar(0, SinOsc.ar([freq1, freq2], 0,0.1));
    }).play(s);
)
x.map(\freq1, b, \freq2, c);

y = {Out.kr(b, SinOsc.kr(1,0,50,880))}.play(addAction: \addToHead);
y.free;
b.get({|val| val.postln; f=val;});

x.set(\freq2, f/2);

c.set(200);
x.free; b.free;c.free;

g = Group.new;
h = Group.before(g);
g.free; h.free;

(
    SynthDef(\tutorial_DecaySin2, { | outBus = 0, effectBus, direct = 0.5, freq = 440 |
        var source;
        source = Pan2.ar(Decay2.ar(Impulse.ar(Rand(0.3, 1), 0, 0.125), 0.3, 1,
        SinOsc.ar(SinOsc.kr(0.2, 0, 110, freq))), Rand(-1.0, 1.0));
        Out.ar(outBus, source * direct);
        Out.ar(effectBus, source * (1 - direct));
    }).add;

    SynthDef(\tutorial_Reverb2, { | outBus = 0, inBus |
        var input;
        input = In.ar(inBus, 2);
        16.do({ input = AllpassC.ar(input, 0.04, Rand(0.001, 0.04), 3)});
        Out.ar(outBus, input);
    }).add;
)

(
    ~sources = Group.new;
    ~effects = Group.after(~sources);
    ~bus = Bus.audio(s, 2);
)

(
    x = Synth(\tutorial_Reverb2, [\inBus, ~bus], ~effects);
    y = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0], ~sources);
    z = Synth(\tutorial_DecaySin2, [\effectBus, ~bus, \outBus, 0, \freq, 660], ~sources);
)

~sources.free; ~effects.free;
~bus.free;

currentEnvironment.clear;

s.queryAllNodes;

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
    x = SynthDef("tutorial-PlayBuf", { |out=0, bufnum|
        Out.ar( out,
            PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum))
        )
    }).play(s, [\bufnum, b]);
)
x.free;

b = Buffer.alloc(s, 512, 1);
b.cheby([1,0,1,1,0,1]);
(
    x = play({
        Shaper.ar(
            b,
            SinOsc.ar(300, 0, Line.kr(0,1,6)),
            0.5
        )
    });
)
b.plot;
x.free;

x = Pbind(\tutorial_DecaySin2, Pseries(0,1,30), \dur, 0.5).play;

(
    SynthDef(\sawFilt, { |out = 0, freq = 440, amp = 0.1, gate = 1, cf = 100, wobble = 3, t_bd, t_sd, pw = 0.4|
        var base = Splay.ar(RLPF.ar(Pulse.ar(freq * [0.99,0.5,1.01],pw),cf.lag(0.05),0.3).madd(SinOsc.ar(wobble).range(0.5,4)).sin) * 0.5;
        var env = Linen.kr(gate, attackTime: 0.01, releaseTime: 0.5, doneAction: 2);
        var sig = base;
        var bd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_bd,SampleDur.ir),1000),30,0.5,5).sin*2);
        var sd = tanh(Ringz.ar(LPF.ar(Trig.ar(t_sd,SampleDur.ir),1000),120,0.75,PinkNoise.ar(2!2)).sin*2);
        sd = HPF.ar(sd,60);
        sig = tanh(GVerb.ar(HPF.ar(base * env,30), 70, 11, 0.15)*0.5 + sig + bd + sd);
        Out.ar(out, sig*amp*env);
    }).add;
)

(
    p = Pproto(
        {
            ~id = (
                type: \on,
                dur: 0,
                instrument: \sawFilt,
                amp: 1,
            ).yield[\id];
            ~type = \set;
        },
        Ppar([
            Pbind(
                \args, #[freq],
                \freq, Pseq([49,47,50,48]-12,inf).midicps,
                \dur, 4,
            ),
            Pbind(
                \args, #[cf],
                \cf, Pseq([100,Prand([700,400,1100],3)],inf),
                \stutter, Prand([1,2,4,8],inf),
                \dur, PdurStutter(Pkey(\stutter)*2, 2),
                // NOTE: also useful is .collect on patterns!
                \dur, Prand([1,2,4,8], inf).collect{ |x| (1/x)!(x*2) }.flatten
            ),
            Pbind(
                \args, #[wobble],
                \wobble, Pxrand([3,1.5,6],inf),
                \dur, Prand([2,1],inf),
            ),
            Pbind(
                \args, #[t_bd],
                \t_bd, Pseq([1,0,0,1],inf),
                \dur, 0.5,
            ),
            Pbind(
                \args, #[t_sd],
                \t_sd, Pseq([0,0,1,0],inf),
                \dur, 0.5,
            ),
            Pbind(
                \args, #[pw],
                \pw, Prand([0.4,0.3,0.5],inf),
                \dur, 2,
            ),
        ])
    ).play;
)

p = Pgeom(1,2,10);
p.next;

q = p.asStream;
q.next;

r = p.asStream;
r.next;

[q.next, r.next]
(
    p = Pbind(
        \degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 1),
        \dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 1)
    ).play;
)
Pslide(#[1, 2, 3, 4, 5, 6, 7, 8], 10, 3, 1, 0, false).asStream.all;

// or, to show the segments as separate arrays
Pslide(#[1, 2, 3, 4, 5, 6, 7, 8], 10, 3, 1, 0, false).clump(3).asStream.all;

// Flock of Seagulls!
(
    p = Pbind(
        \degree, Pslide((-6, -4 .. 12), 8, 3, 1, 0),
        \dur, Pseq(#[0.1, 0.1, 0.2], inf),
        \sustain, 0.15
    ).play;
)

(
    p = Pbind(
        \degree, Pwrand((0..7), [4, 1, 3, 1, 3, 2, 1].normalizeSum, inf),
        \dur, 0.25
    ).play;
)
p.stop;
(
    // a synthdef browser
    SynthDescLib.global.read;
    SynthDescLib.global.browse;
)

(
    p = Pbind(
        \degree, Ppatlace([
            Pseries(0, 1, 8),    // first, third etc. notes
            Pseries(2, 1, 7)    // second, fourth etc. notes
        ], inf),
        \dur, 0.01
    ).play;
)
(
    p = Pbind(
        \degree, Ptuple([
            Pseries(7, -1, 8),
            Pseq([9, 7, 7, 7, 4, 4, 2, 2], 1),
            Pseq([4, 4, 4, 2, 2, 0, 0, -3], 1)
        ], 1),
        \dur, 1
    ).play;
)

e = (freq: 440, dur: 0.5);
e.at(\freq);
e[\freq];
e.freq;
e.play;

p = Pbind(\degree, Pwhite(0, 7, inf), \dur, 0.25, \legato, 1).play;
p.stop;
p = Pmono(\default, \degree, Pwhite(0,7,inf), \dur, 0.25).play;
p.stop;
(
    SynthDef(\sawpulse, { |out, freq = 440, gate = 0.5, plfofreq = 6, mw = 0, ffreq = 2000, rq = 0.3, freqlag = 0.05, amp = 1|
        var sig, plfo, fcurve;
        plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
        freq = Lag.kr(freq, freqlag) * plfo;
        fcurve = EnvGen.kr(Env.adsr(0, 0.3, 0.1, 20), gate);
        fcurve = (fcurve - 1).madd(0.7, 1) * ffreq;
        sig = Mix.ar([Pulse.ar(freq, 0.9), Saw.ar(freq*1.007)]);
        sig = RLPF.ar(sig, fcurve, rq)
        * EnvGen.kr(Env.adsr(0.04, 0.2, 0.6, 0.1), gate, doneAction: Done.freeSelf)
        * amp;
        Out.ar(out, sig ! 2)
    }).add;
)

p = PmonoArtic(\sawpulse, \dur, 0.2, \freq, Pwhite(1,8) * 100, \legato, Pwrand(#[0.5, 1.0], #[0.1, 0.9], inf) ).play;

p.stop;
(
    SynthDef(\harpsi, { |outbus = 0, freq = 440, amp = 0.1, gate = 1|
        var out;
        out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * Pulse.ar(freq, 0.25, 0.75);
        Out.ar(outbus, out ! 2);
    }).add;

    p = Pbind(
        \instrument, \harpsi,
        \degree, Pseries(0,5,8),
        \dur, 0.25,
        \gate, Pseries(0,0.025,8)
    ).play;
)

(
    var pitches = Pseries(0, Pconst(24, Pwhite(1,3,inf)), inf).asStream.all,
    mask = pitches.scramble[0 .. pitches.size div: 3];
    p = Pbind(
        \arpeg, Pseq(pitches[ .. pitches.size - 2] ++ pitches.reverse[ .. pitches.size - 2], inf),
        \note, Pif(Pfunc { | event | mask.includes(event[\arpeg]) }, Rest(0), Pkey(\arpeg)),
        \octave, 4,
        \dur, 0.125,
        \amp, 0.3
    ).play;
)

p.stop;
(
SynthDef(\trig_demo, { |out, freq = 440, gate = 1, t_trig = 1|    // t_trig here
    var    env = Decay2.kr(t_trig, 0.01, 0.1),
        sig = Saw.ar(freq, env)
            * Linen.kr(gate, 0.01, 0.1, 0.1, doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2)
}).add;
)
(
p = Pmono(\trig_demo,
    \freq, Pexprand(200, 800, inf),
    \trig, 8,    // note that this is NOT t_trig -- just \trig
    \delta, 0.125
).play;
)
p.stop;
(
var midi, dur;
midi = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1).asStream;
dur = Pseq([2, 2, 1, 0.5, 0.5, 1, 1, 2, 2, 3], 1).asStream;

SynthDef(\smooth, { |out, freq = 440, sustain = 1, amp = 0.5|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2)
}).add;

r = Task({
    var delta;
    while {
        delta = dur.next;
        delta.notNil
    } {
        Synth(\smooth, [freq: midi.next.midicps, sustain: delta]);
        delta.yield;
    }
}).play(quant: TempoClock.default.beats + 1.0);
)
(
SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15, detune = 1.005, preamp = 4|
    var    sig,
        env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
}).add;
)

TempoClock.default.tempo = 132/60;
(

p = Pxrand([
    Pbind(
        \instrument, \bass,
        \midinote, 36,
        \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
        \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
        \amp, 1.0, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 48, 36], 1),
        \dur, Pseq([0.25, 0.25, 0.5], 1),
        \amp, 1.0, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
        \amp, 1.0, \detune, 1.005
    ),
    Pmono(\bass,
        \midinote, Pseq([36, 39, 36, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
        \amp, 1.0, \detune, 1.005
    )
], inf).play(quant: 1);
)
p.stop; k.stop;
k.stop;

// totally cheesy, but who could resist?
(
SynthDef(\kik, { |out, preamp = 1, amp = 1|
    var    freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
        sig = SinOsc.ar(freq, 0.5pi, preamp).distort * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2);
}).add;

// before you play:
// what do you anticipate '\delta, 1' will do?
k = Pbind(\instrument, \kik, \delta, 1, \preamp, 4.5, \amp, 0.32).play(quant: 1);
)
