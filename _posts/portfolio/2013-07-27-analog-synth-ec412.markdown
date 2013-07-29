---
title: "Monophonic Analog Synthesizer with AR Enveloping"
date: 2013-04-21 01:29:18
date_description: April 2013 - May 2013
categories: portfolio
tag: electronics
image: /assets/img/projects/laser-turret/laser-turret.jpg
documentation: #
source: #
video: #
partners: ["<a href='http://benhavey.com'>Benjamin Havey</a>"]
id: 2
---

This Monophonic Analog Synthesizer was designed by Christopher Woodall and [Benjamin Havey](http://benhavey.com/). The synthesizer uses a homemade linearly actuated potentiometer as its input, a long with a button for articulation. The potentiometer voltage is fed through a linear to exponential converter and then a voltage controlled oscillator. The output of the VCO is then put through a analog multiplier designed using an opamp and discrete transistors which envelopes the square and triangle wave VCO outputs with a attack release (AR) envelope. The enveloped output is then filtered, amplified and pumped through speakers. Each piece of the synthesizer was simulated in LTSpice and then built on a breadboard.