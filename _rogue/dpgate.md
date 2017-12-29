---
title: Deadly Poison Bug \#DPGate
description: Code to compare Deadly Poison bug impact using SimulationCraft
---

Deadly Poison Bug \#DPGate
==========================

Following the report made by Kojiyama (a WoW Theorycrafter that plays rogue) after seeing Asians logs about Deadly Poison bug (see: [this link](https://github.com/Ravenholdt-TC/Rogue/issues/81)), we implemented it in SimulationCraft.

To sim yourself and check the impact of this bug, you can copy and paste this code after your /simc output. E.g. on Raidbots, open "Advanced", insert your /simc Addon output and then, right after, the following code.
It'll automatically switch your talents to use Nightstalker and make a comparison between using the bug or not.

If you click on "Copy", the input will be automatically copied to your clipboard.
<p class="copybox">
  <textarea id="fokstring" class="form-control" rows="4" readonly>
talent_override=nightstalker
copy=NoBug
bugs=0
talent_override=nightstalker
  </textarea>
  <button class="btn btn-default" onclick="window.herodamage.copyToClipboard('fokstring');">Copy</button>
</p>

{% include layout-parts/ads/inarticle.jekyll %}

At the time I'm writing this, Raidbots isn't updated. The only way to check it is to build SimulationCraft from the sources. I'll update this post once it'll be done.
Until then, here is two pics showing how big the impact is, see how we went from bottom to top in 2 weeks. Do remember that we are still working on this, so we might optimize it furthermore.

![Assassination buildswith and without the bug](/assets/wow/img/rogue/dpgate/assassination.png "Assassination buildswith and without the bug")

![Assassination in stacked chart with and without the bug](/assets/wow/img/rogue/dpgate/stacked.png "Assassination in stacked chart with and without the bug")
