---
title: Fan of Knives Import
description: Code to simulate Mutilate vs Fan of Knives using SimulationCraft
---

Fan of Knives Comparison
========================

<div class="alert alert-warning">
  <strong>Warning!</strong> This interaction will be hotfixed with the weekly reset on Jan 9. Mutilate should again be your main generator in all Single Target situations.
</div>

With enough Mastery or Poison Knives relics, dropping Mutilate and using Fan of Knives as the main generator actually becomes an increase. If you see variations including "FoK" for Combinations or Relics, those are profiles using Fan of Knives instead of Mutilate.

To sim yourself and check whether using FoK as the main builder for Assassination is an increase, you can copy and paste this code after your /simc output. E.g. on Raidbots, open "Advanced", insert your /simc Addon output and then, right after, the following code.

If you click on "Copy", the input will be automatically copied to your clipboard.

{% include layout-parts/ads/inarticle.jekyll %}

With the **latest Raidbots version set to "Nightly"**, you can simply use:

<p class="copybox">
  <textarea id="fokstring" class="form-control" rows="2" readonly>
copy=FoK
fok_rotation=1
  </textarea>
  <button class="btn btn-default" onclick="window.herodamage.copyToClipboard('fokstring');">Copy</button>
</p>
