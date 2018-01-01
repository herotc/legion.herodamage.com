---
title: "In-Depth: Combinator"
date: 2017-11-06 16:15:00 +0100
categories: theorycrafting tools
author: Mystler
---

We are getting closer and closer to beating the Burning Legion in the new Antorus raid. Our first simulation results for Tier 21 are released and it is time to go a little bit into detail about one of our tools - Combinator. How does it work? What can I do with the results? What are the issues?
<!--more-->

### What is Combinator?

All of the results on the "Combinations" pages are the output of a Ruby script called "Combinator". That script started out as a very simple one running a SimulationCraft profile for arbitrary talent combinations. I wrote and used it for my simulations after the rework for the Subtlety spec back in 7.2.5. Since then, Combinator has evolved much further.

As of now, Combinator does not simply permute talents for manually created profiles, but also creates legendary and set combinations. Besides, it can easily be extended for personal simulations or other classes. First of all, we create a baseline SimulationCraft profile that has no active talents and no set pieces or legendaries equipped. Using JSON files, we define available set pieces and legendaries for all the specs, as well as what set combinations and number of legendaries we are interested in. The fightstyle can be defined in another profile as well. Combinator allows us to choose from our profiles and templates interactively. In layman's terms, we can tell Combinator something like: Take the Rogue baseline profile and simulate all combinations using Rogue DPS legendaries, tier set combinations with T21 pieces (plus other tiers) and with talent permutations matching "xxx00xx" (where x means all) for single target boss fights. As you can imagine, and see in our results, this can lead to an enormous number of simulations.

### What can I learn from Combinator results?

There is a reason we decided to run so many combinations and not just simulate what might be considered "top gear" and "best builds". The main intention behind these simulations is to find outliers. By simulating so many combinations, we can possibly see (and have done so in the past) certain setups perform very well, that we might not have considered if we were running and investigating setups by hand.

With our table view and the filters in place, everyone can browse the results to find setups they care about. In my opinion, many guides out there have the issue that they only target one build for current tier gear and the top two legendaries. This, however, does not apply to everyone and can even lead new players to copy setups that may be inadequate for what they have available. By filtering our results, you can check out what setup might perform best with your legendaries, tier pieces, or preferred talent build. You have no tier pieces or legendaries because your character just reached level 110 and you would like to know what talents to play? No problem, just filter the results and narrow down what may be best for you.

### What do I have to be careful about?

Of course, running so many combinations also has disadvantages. It is very hard to generalize what gear, stats, and set slots a spec prefers with so many different builds around. Because of that, Combinator cannot fully optimize the gear and may be "biased" towards some setups. The slots with set pieces may not always be the best selection and, depending on the rest of the gear and the talents, other off-pieces from the raid may be better.

As of now, you can see an example for this in the results. For Assassination with T21 Mythic gear, the first Exsanguinate build is listed on page three with roughly 40k DPS behind the first. However, in the default profile for SimulationCraft, in which I already tried to improve the gear in all slots, both builds are almost equal.

### Sim Yoself

When we say that you should **simulate you own character** all the time, this is not just a disclaimer in case our results do not match yours. We encourage you to sim yourself because, especially due to special slots like trinkets, as well as warforging and titanforging, what gear you have available can have a noticeable impact. For example, with good T20 pieces available, targeted relics, and a good stat distribution - despite Combinator results - Exsanguiate is likely to beat the poison build in Antorus.

Here is my recommendation on how to use Combinator (and in a way also all of our other) results: Check out what the results are for what you have or care about and don't be afraid to look at more than just the top build. Based on what you can see in the results, run something like <a href="https://www.raidbots.com/simbot/topgear" title="Raidbots Top Gear" target="_blank" rel="nofollow">Raidbots Top Gear</a> for one or more talents in order to find something that is actually tailored for your own character.

![Sim Yoself]({% asset_path blogposts/combinator/simyoself.gif %}){: .img-responsive .center}

### An outlook into the future

Now, we know that a lot of people still want to look at a table and see what is "best", assuming certain gear limitations (like unforged  Mythic raid gear). We have plans to address the issues with tailored gear optimizations in Combinator by introducing another "Top Gear" feature. Top Gear will act like a "second pass" to Combinator and use its results to reiterate over the most promising combinations and try to optimize those profiles much more in-depth. On another "Top Gear" table you will be able to look at these results and have a better idea of how they will compete.

I cannot give an ETA on that feature, right now. Stay tuned! :wink:

