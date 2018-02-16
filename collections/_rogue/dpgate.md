---
title: "Deadly Poison Bug #DPGate"
description: Code to compare Deadly Poison bug impact using SimulationCraft
---

Deadly Poison Bug \#DPGate
==========================

<div class="alert alert-danger">
  <strong>UPDATE!</strong> As of 01/03/2018, the bug has been hotfixed. You can no longer use it.
</div>

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

To sim it yourself, you have to use the 'nightly' version of SimulationCraft or Raidbots.
Here is two pics showing how big the impact is, see how we went from last to first in 2 weeks thanks to bugs. Do remember that we are still working on this, so we might optimize it furthermore.

![Assassination builds with and without the bug]({% asset wow/rogue/dpgate/assassination.png @path %} "Assassination builds with and without the bug")

![Assassination in stacked chart with and without the bug]({% asset wow/rogue/dpgate/stacked.png @path %} "Assassination in stacked chart with and without the bug")
