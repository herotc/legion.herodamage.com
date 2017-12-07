---
title: Status
description: Simulations update dates.
permalink: /status/
simulationNames:
  - "combinations"
  - "relics"
  - "trinkets"
---

<article>
  <section class="container">
    {% for wow_class in site.wow_classes %}
      {% assign validCollections = "" %}
      {% for name in page.simulationNames %}
        {% assign validCollections = validCollections | append: wow_class | append: "-" | append: name %}
        {% unless forloop.last %}
          {% assign validCollections = validCollections | append: ", " %}
        {% endunless %}
      {% endfor %}
      {% assign simCollections = site.documents | where_exp: "item", "validCollections contains item.collection" | where_exp: "item", "item.collection != wow_class" | group_by: "collection" | sort: "name" %}
      <div>
        {% assign wowClassParts = wow_class | split: "_" %}
        {% capture wow_class_titleized %}{% for wowClassPart in wowClassParts %}{% if forloop.last %}{{ wowClassPart | capitalize }}{% else %}{% assign wowClassPart2 = wowClassPart | append: " " %}{{ wowClassPart2 | capitalize }}{% endif %}{% endfor %}{% endcapture %}
        <h2>{{ wow_class_titleized }}</h2>
        <ul>
          {% for simCollection in simCollections %}
            {% for simPage in simCollection.items %}
              {% assign simName = simPage.path | split: '/' %}
              <li>{{ simName.last | replace: '.html', '' }} - {{ simPage.lastupdate }}</li>
            {% endfor %}
          {% endfor %}
        </ul>
      </div>
    {% endfor %}
  </section>
</article>
