// Hero Damage main script
(function (hd) {
  // Avoid initializing it twice
  if (hd.hasInitialized) return;

  /*
   * Utils
  */

  // Copy the content to the clipboard
  hd.copyToClipboard = function copyToClipboard(elementId) {
    var copyText = document.getElementById(elementId);
    copyText.select();
    document.execCommand("Copy");
  };

  /*
   * Data Helpers
  */

  // Format number the US way
  function formatNumber(number) {
    return new Intl.NumberFormat("en-US").format(number);
  }

  // Remove the loading message
  function removeLoading () {
    var el = document.getElementById("herodamage-loading");
    el.parentNode.removeChild(el)
  }

  // Google Charts: Exclude empty rows
  function excludeEmptyRows(dataTable) {
    var view = new google.visualization.DataView(dataTable);
    var rowIndexes = view.getFilteredRows([{column: 1, value: null}]);
    view.hideRows(rowIndexes);
    return view.toDataTable();
  }

  // Google Charts:  Put rows whereas first column match array items at the top (last item will be displayed first)
  function putAtTheTop(data, specialRows) {
    var i, col, row;
    for (i = 0; i < specialRows.length; i++) {
      for (row = 0; row < data.getNumberOfRows(); row++) {
        if (data.getValue(row, 0) == specialRows[i]) {
          // Do nothing if it's already the first row
          if ( row != 0 ) {
            // Insert an empty row at the top, copy the wanted row properties in the first one
            data.insertRows(0, 1); // Be careful, it shiftes the index
            row = row + 1;
            data.setRowProperties(0, data.getRowProperties(row));
            for (col = 0; col < data.getNumberOfColumns(); col++) {
              data.setValue(0, col, data.getValue(row, col));
            }
            data.removeRow(row);
          }
          break;
        }
      }
    }
    return data;
  }

  /*
   * Data Loaders
  */

  // Combinations
  // Wrap is due to variable having function scope (could implement OOP at some point)
  (function () {
    var combinationsData;
    var hasBossDPS = false;
    var setSelect, legoSelect;

    hd.combinationsUpdate = function combinationsUpdate() {
      if (!combinationsData)
        return;
      var filterTalents = document.getElementById("combinations-table-filter-talents").value;
      var filterTalentsRegex = new RegExp("^" + filterTalents.replace(new RegExp("x|\\*", "ig"), "[0-3]"), "i");
      var filterSets = setSelect.val();
      var filterLegendaries = legoSelect.val();
      var combinationsRows = $.grep(combinationsData, function (columns) {
        if (filterTalents !== "" && !filterTalentsRegex.test(columns[1]))
          return false;
        if (filterSets.indexOf(columns[2]) < 0)
          return false;
        var legos = columns[3].split(", ");
        if ($(filterLegendaries).filter(legos).length < legos.length && columns[3] !== "None")
          return false;
        return true;
      });
      var tableData = document.getElementById("combinations-table-data");
      var $tableNav = $(document.getElementById("combinations-table-nav"));
      if ($tableNav.data("twbs-pagination"))
        $tableNav.twbsPagination("destroy");
      $tableNav.twbsPagination({
        totalPages: Math.max(1, Math.ceil(combinationsRows.length / 15)),
        visiblePages: 3,
        onPageClick: function (event, page) {
          var html = "";
          combinationsRows.slice((page - 1) * 15, page * 15).forEach(function (columns) {
            html += "<tr>";
            html += "<td>" + columns[0] + "</td>";
            html += "<td>" + columns[1] + "</td>";
            html += "<td>" + columns[2] + "</td>";
            html += "<td>" + columns[3] + "</td>";
            html += "<td>" + formatNumber(columns[4]) + "</td>";
            if (hasBossDPS) {
              html += "<td>";
              if (columns.length === 6)
                html += formatNumber(columns[5]);
              html += "</td>";
            }
            html += "</tr>";
          });
          tableData.innerHTML = html;
        }
      });
    };

    hd.combinationsInit = function combinationsInit(reportPath) {
      $.get("/" + reportPath, function (data) {
        var sets = [];
        var legos = [];
        var beltIdx;

        combinationsData = data;
        combinationsData.forEach(function (columns) {
          if ($.inArray(columns[2], sets) < 0) {
            sets.push(columns[2]);
          }
          columns[3].split(", ").forEach(function (lego) {
            if (lego !== "None" && $.inArray(lego, legos) < 0) {
              legos.push(lego);
            }
          });
          if (!hasBossDPS && columns.length === 6)
            hasBossDPS = true;
        });
        // Sets
        sets.sort().reverse();
        sets.forEach(function (set) {
          document.getElementById("combinations-table-filter-sets").insertAdjacentHTML("beforeend", "<option>" + set + "</option>");
        });
        setSelect = $("#combinations-table-filter-sets");
        setSelect.selectpicker("val", sets);
        setSelect.selectpicker("refresh");
        // Legendaries
        legos.sort();
        legos.forEach(function (lego) {
          document.getElementById("combinations-table-filter-legendaries").insertAdjacentHTML("beforeend", "<option>" + lego + "</option>");
        });
        legoSelect = $("#combinations-table-filter-legendaries");
        // Don't show Cinidaria by default
        beltIdx = legos.indexOf("Cinidaria");
        if (beltIdx > -1) {
          legos.splice(beltIdx, 1);
        }
        legoSelect.selectpicker("val", legos);
        legoSelect.selectpicker("refresh");
        // Boss DPS
        if (hasBossDPS) {
          document.getElementById("combinations-table-headers").insertAdjacentHTML("beforeend", "<th>Boss DPS</th>");
          document.getElementById("combinations-table-filters").insertAdjacentHTML("beforeend", "<th></th>");
        }
        hd.combinationsUpdate();
        removeLoading();
      });
    };
  })();

  // Relics
  hd.relicsInit = function relicsInit(reportPath, chartTitle) {
    function drawChart() {
      $.get("/" + reportPath, function (data) {
        var data = new google.visualization.arrayToDataTable(data);
        var col, row;

        // Sort by 3 relics dps (column 5)
        data.sort({column: 5, desc: true});

        // Move %DPSGain & WILvl at the top
        var specialRows = [
          'Weapon Item Level',
          '% DPS Gain'
        ];
        data = putAtTheTop(
          data,
          specialRows
        );

        // Mark annotation columns
        for (col = 2; col < data.getNumberOfColumns(); col += 2) {
          data.setColumnProperties(col, {type: "string", role: "annotation"});
        }

        // Add Tooltip and Style columns
        for (col = 3; col <= data.getNumberOfColumns(); col += 4) {
          data.insertColumn(col, {type: "string", role: "tooltip", "p": {"html": true}});
          data.insertColumn(col + 1, {type: "string", role: "style"});
        }

        // Define Crucible T2
        var CrucibleLightTraits = ["Light Speed", "Infusion of Light", "Secure in the Light", "Shocklight"];
        var CrucibleShadowTraits = ["Master of Shadows", "Murderous Intent", "Shadowbind", "Torment the Weak", "Chaotic Darkness", "Dark Sorrows"];

        // Calculate Differences
        for (row = 0; row < data.getNumberOfRows(); row++) {
          var relicStyle = "";
          var rowName = data.getValue(row, 0);
          if (rowName == specialRows[1]) { // % DPS Gain
            relicStyle = "stroke-width: 1; stroke-color: #808080; color: #b3b3b3"
          } else if (rowName == specialRows[0]) { // Weapon Item Level
            relicStyle = "stroke-width: 0.5; stroke-color: #4d4d4d; color: #808080"
          } else if ($.inArray(rowName, CrucibleLightTraits) >= 0) { // Light T2
            relicStyle = "stroke-width: 3; stroke-color: #bb8800; color: #ffcc00";
          } else if ($.inArray(rowName, CrucibleShadowTraits) >= 0) { // Shadow T2
            relicStyle = "stroke-width: 3; stroke-color: #5500aa; color: #8800ff";
          }
          var prevVal = 0;
          for (col = 1; col < data.getNumberOfColumns(); col += 4) {
            var curVal = data.getValue(row, col);
            var stepVal = curVal - prevVal;
            var tooltip = "<div class=\"chart-tooltip\"><b>" + data.getValue(row, col + 1) + "x " + rowName +
              "</b><br><b>Total:</b> " + formatNumber(curVal.toFixed()) +
              "<br><b>Increase:</b> " + formatNumber(stepVal.toFixed()) + "</div>";
            data.setValue(row, col + 2, tooltip);
            data.setValue(row, col + 3, relicStyle);
            data.setValue(row, col, stepVal);
            if (stepVal < 0) {
              data.setValue(row, col, 0);
              data.setValue(row, col + 1, "");
            }
            prevVal = curVal > prevVal ? curVal : prevVal;
          }
        }

        // Sort crucible traits to the bottom using a temporary column
        var sortCol = data.addColumn("number");
        for (row = 0; row < data.getNumberOfRows(); row++) {
          if ($.inArray(data.getValue(row, 0), CrucibleLightTraits) >= 0 || $.inArray(data.getValue(row, 0), CrucibleShadowTraits) >= 0) {
            data.setValue(row, sortCol, 1);
          } else {
            data.setValue(row, sortCol, 0);
          }
        }
        data.sort([{column: sortCol, desc: false}]);
        data.removeColumn(sortCol);

        // Get content width (to force a min-width on mobile, can't do it in css because of the overflow)
        var content = document.getElementById("fightstyle-tabs");
        var contentWidth = content.innerWidth - window.getComputedStyle(content, null).getPropertyValue("padding-left") * 2;

        // Set chart options
        var chartWidth = document.documentElement.clientWidth >= 768 ? contentWidth : 700;
        var bgColor = "#222222";
        var textColor = "#cccccc";
        var options = {
          title: chartTitle,
          backgroundColor: bgColor,
          chartArea: {
            top: 50,
            bottom: 100,
            left: 150,
            right: 50
          },
          hAxis: {
            gridlines: {
              count: 20
            },
            format: 'short',
            textStyle: {
              color: textColor
            },
            title: "DPS Increase",
            titleTextStyle: {
              color: textColor
            },
            viewWindowMode: 'maximized',
            viewWindow: {
              min: 0
            }
          },
          vAxis: {
            textStyle: {
              fontSize: 12,
              color: textColor
            },
            titleTextStyle: {
              color: textColor
            }
          },
          annotations: {
            highContrast: false,
            stem: {
              color: "transparent",
              length: -12
            },
            textStyle: {
              fontName: '"Helvetica Neue", Helvetica, Arial, sans-serif',
              fontSize: 10,
              bold: true,
              color: bgColor,
              auraColor: "transparent"
            }
          },
          titleTextStyle: {
            color: textColor
          },
          tooltip: {
            isHtml: true
          },
          legend: {
            position: "none"
          },
          isStacked: true,
          width: chartWidth
        };

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.BarChart(document.getElementById("google-chart"));
        chart.draw(excludeEmptyRows(data), options);
        removeLoading();
      });
    }

    google.charts.load("current", {"packages": ["corechart"]});
    google.charts.setOnLoadCallback(drawChart);
  };

  // Trinkets
  hd.trinketsInit = function trinketsInit(reportPath, chartTitle) {
    function drawChart() {
      $.get("/" + reportPath, function (data) {
        var data = new google.visualization.arrayToDataTable(data);
        var col, row;

        // Sorting
        var sortCol = data.addColumn("number");
        for (row = 0; row < data.getNumberOfRows(); row++) {
          var biggestTotalValue = 0;
          for (col = 1; col < sortCol; col++) {
            if (data.getValue(row, col) > biggestTotalValue)
              biggestTotalValue = data.getValue(row, col);
          }
          data.setValue(row, sortCol, biggestTotalValue);
        }
        data.sort([{column: sortCol, desc: true}]);
        data.removeColumn(sortCol);

        // Add Tooltip columns
        for (col = 2; col <= data.getNumberOfColumns(); col += 2) {
          data.insertColumn(col, {type: "string", role: "tooltip", "p": {"html": true}});
        }

        // Calculate Differences
        for (row = 0; row < data.getNumberOfRows(); row++) {
          var prevVal = 0;
          for (col = 1; col < data.getNumberOfColumns(); col += 2) {
            var curVal = data.getValue(row, col);
            var stepVal = curVal - prevVal;
            var tooltip = "<div class=\"chart-tooltip\"><b>" + data.getValue(row, 0) +
              "<br> Item Level " + data.getColumnLabel(col) + "</b>" +
              "<br><b>Total:</b> " + formatNumber(curVal.toFixed()) +
              "<br><b>Increase:</b> " + formatNumber(stepVal.toFixed()) + "</div>";
            data.setValue(row, col + 1, tooltip);
            data.setValue(row, col, stepVal);
            prevVal = curVal > prevVal ? curVal : prevVal;
          }
        }

        // Get content width (to force a min-width on mobile, can't do it in css because of the overflow)
        var content = document.getElementById("fightstyle-tabs");
        var contentWidth = content.innerWidth - window.getComputedStyle(content, null).getPropertyValue("padding-left") * 2;

        // Set chart options
        var chartWidth = document.documentElement.clientWidth >= 768 ? contentWidth : 700;
        var bgColor = "#222222";
        var textColor = "#cccccc";
        var options = {
          title: chartTitle,
          backgroundColor: bgColor,
          chartArea: {
            top: 50,
            bottom: 100,
            right: 150,
            left: 200
          },
          hAxis: {
            gridlines: {
              count: 20
            },
            format: "short",
            textStyle: {
              color: textColor
            },
            title: "DPS Increase",
            titleTextStyle: {
              color: textColor
            },
            viewWindowMode: 'maximized',
            viewWindow: {
              min: 0
            }
          },
          vAxis: {
            textStyle: {
              fontSize: 12,
              color: textColor
            },
            titleTextStyle: {
              color: textColor
            }
          },
          legend: {
            textStyle: {
              color: textColor
            }
          },
          titleTextStyle: {
            color: textColor
          },
          tooltip: {
            isHtml: true
          },
          isStacked: true,
          width: chartWidth
        };

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.BarChart(document.getElementById("google-chart"));
        chart.draw(excludeEmptyRows(data), options);
        removeLoading();
      });
    }

    google.charts.load("current", {"packages": ["corechart"]});
    google.charts.setOnLoadCallback(drawChart);
  };

  // Prevent further initialization
  hd.hasInitialized = true;

  window.herodamage = hd;

}(window.herodamage || {}));
