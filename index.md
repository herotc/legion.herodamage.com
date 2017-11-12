---
layout: default
title: false
description: Theorycrafting community, latest simulation results and resources -based on SimulationCraft- for World of Warcraft.
---

<article id="home">
  <section id="home-introduction" class="container">
    <div id="introduction-heading">
      <img src="/assets/img/logo.svg" alt="{{ site.name }} Logo" height="128" width="128" itemprop="logo">
      <h1>Hero<br>Damage</h1>
    </div>
    <p>
    Welcome to Hero Damage, the website where you can see the latest World of Warcraft simulations results for every class.<br>
    Please select your class below.
    </p>
  </section>

  <section id="home-picker" class="container">
    {% include layout-parts/wowclasspicker.html element="nav" elementID="home-picker" %}
  </section>
</article>
