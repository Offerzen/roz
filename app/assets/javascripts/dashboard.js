$(document).on('turbolinks:load', () => { 
  if(gon.budgets == undefined) { return }

  const { labels, datasets } = parseData(gon.budgets);

  var ctx = document.getElementsByClassName("budget")[0].getContext("2d");
  var budgetChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels,
      datasets
    },
    options: {
      legend: false,
      responsive: true,
      tooltips: {
        mode: "index",
        intersect: false
      },
      scales: {
        xAxes: [
          {
            gridLines: false,
            stacked: true,
            ticks: {
              maxRotation: 0,
              minRotation: 0,
              padding: 10,
              callback: function(label, index, labels) {
                return label.split(" ");
              }
            }
          }
        ],
        yAxes: [
          {
            stacked: true,
            ticks: {
              beginAtZero: true
            }
          }
        ]
      }
    }
  });

  window.onbeforeprint = function() {
    for (var id in Chart.instances) {
      Chart.instances[id].resize();
    }
  };

  function parseData(budgets) {
    const theme = {
      under: "#34a853",
      warning: "#ff6d01",
      over: "#ea4335",
      remaining: "gray"
    };
    let labels = [];
    let remainingValues = [];
    let spendValues = [];
    let spendColors = [];

    gon.budgets.forEach(({ name, budget, spend }) => {
      labels.push(name);
      spendValues.push(spend);
      remainingValues.push(Math.max(0, budget - spend));
      let color = theme.under;
      const spendRatio = spend / budget;
      if (spendRatio >= 1) {
        color = theme.over;
      } else if (spendRatio >= 0.8) {
        color = theme.warning;
      }
      spendColors.push(color);
    });

    return {
      labels,
      datasets: [
        {
          label: "Spend",
          backgroundColor: spendColors,
          data: spendValues
        },
        {
          label: "Remaining",
          backgroundColor: theme.remaining,
          data: remainingValues
        }
      ]
    };
  }
});