---
title: "Artemis Synthesizer v2: Digital Audio Synthesizer Kit"
date: 2013-07-29 01:29:18
date_description: August 2012 - August 2013
categories: portfolio
tag: electronics
image: /assets/img/projects/artemis-synth/artemis-synth.jpg
documentation: http://happyrobotlabs.com/posts/project/artemis-synthesizer-a-music-synthesizer-kit/
source: http://www.github.com/cwoodall/artemis-synth
video: http://www.youtube.com/watch?v=ljBx9qjmdTc
partners: ["<a href='http://edf.bu.com'>Eric Hazen</a>", "<a href='http://www.samdamask.com'>Sam Damask</a>"]
id: 3
---

The Artemis Synthesizer is a digital audio synthesizer kit developed in my spare time with help from the [BU Electronic Design Facility][1]. The kits purpose was to help teach a group of female high school freshmen in the [Artemis][2] summer program how to solder. Assembly was designed to take between 2 and 4 hours for a beginner, but should take closer to 30 minutes for someone with prior experience.

The synthesizer utilizes an ATMega328 and a 12-bit DAC to produce the audio, in its default mode you can play 4 different 8 note scales. There is also a sequencer mode and an ability to change the waveform. To load sequences and new waveforms the [optoloader][3] interface is used, which uses javascript to blink a black square on a computer screen and a phototransistor to receive this message, which is then decoded on the microcontroller.

[1]: http://edf.bu.edu
[2]: http://www.bu.edu/lernet/artemis/
[3]: http://cwoodall.github.io/artemis-synth
