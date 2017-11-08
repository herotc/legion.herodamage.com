---
title: Changelog
description: Latest changes made to the website.
permalink: /changelog/
---

Website Changelog
=================

In this list, you can see the last 30 changes to our website repository on GitHub.

<div id="github-changelog" class="list-group"></div>
<script>
  $.getJSON("https://api.github.com/repos/{{ site.repository }}/commits", function(data) {
    $.each(data, function(idx, commit) {
      var messageLines = commit.commit.message.split("\n").filter(Boolean);
      var title = messageLines.shift();
      var messageString = messageLines.length > 0 ? messageLines.join('<br>') + '<br>' : '';
      var entry = '<a href="https://github.com/{{ site.repository }}/commit/' + commit.sha + '" target="blank" class="list-group-item">' +
        '<div class="media"><div class="media-left"><img src="' + commit.author.avatar_url + '&amp;s=84" width="42" height="42"></div>' +
        '<div class="media-body"><h4 class="media-heading">' + title + '</h4>' +
        messageString + new Date(commit.commit.author.date).toLocaleString("en-US") + ' by ' + commit.author.login +
        '</div></div></a>';
      $("#github-changelog").append(entry);
    });
  });
</script>
