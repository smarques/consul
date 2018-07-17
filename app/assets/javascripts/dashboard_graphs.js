//= require d3
//= require c3
//= require c3ext

(function(){
  'use strict';

  var ProposalGraph = function(url) {
    this.url = url;
    this.successfulProposalDataUrl = null;
    this.proposalAchievementsUrl = null;
    this.targetId = null;
    this.groupBy = null;
    this.proposalSuccess = null;
    this.progressLabel = 'Progress';
    this.supportsLabel = 'Supports';
    this.successLabel = 'Success';
    this.chart = null;
    this.goals = null;
    this.achievements = null;
    this.xColumnValues = null;
    this.succesfulColumnValues = null;
    this.progressColumnValues = null;
  };

  ProposalGraph.prototype.refresh = function() {
    this.refreshGoals()
      .then(this.refreshData.bind(this))
      .then(this.refreshSuccessfulData.bind(this))
      .then(this.refreshAchievements.bind(this))
      .done(this.draw.bind(this));
  };

  ProposalGraph.prototype.refreshGoals = function () {
    return $.ajax({
      url: '/dashboard/resources.json',
      cache: false,
      success: function(data) {
        this.parseGoals(data);
      }.bind(this)
    });
  };

  ProposalGraph.prototype.parseGoals = function(data) {
    var i, l;

    this.goals = [];
    for (i = 0, l = data.length; i < l; i += 1) {
      this.goals.push({
        value: data[i].required_supports,
        text: data[i].title
      });
    }
  };

  ProposalGraph.prototype.refreshData = function () {
    return $.ajax({
      url: this.url,
      cache: false,
      success: function (data) {
        this.parseData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseData = function(data) {
    var key; 
    
    this.xColumnValues = [ ];
    this.progressColumnValues =  [ this.progressLabel ];

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        this.xColumnValues.push(key);
        this.progressColumnValues.push(data[key]);
      }
    }
  };

  ProposalGraph.prototype.refreshSuccessfulData = function() {
    return $.ajax({
      url: this.successfulProposalDataUrl,
      cache: false,
      success: function (data) {
        this.parseSuccessfulProposalData(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseSuccessfulProposalData = function(data) {
    var key; 
    
    this.successfulColumnValues = [ this.successLabel ];

    for (key in data) {
      if (data.hasOwnProperty(key)) {
        this.addXColumnValue(key);
        this.successfulColumnValues.push(data[key]);
      }
    }
  };

  ProposalGraph.prototype.refreshAchievements = function() {
    return $.ajax({
      url: this.proposalAchievementsUrl,
      cache: false,
      success: function (data) {
        this.parseAchievements(data);
      }.bind(this),
      data: {
        group_by: this.groupBy
      }
    });
  };

  ProposalGraph.prototype.parseAchievements = function(data) {
    var group;

    this.achievements = [];
    for (group in data) {
      if (data.hasOwnProperty(group)) {
        this.addXColumnValue(group);
        this.achievements.push({
          value: group,
          text: data[group][data[group].length - 1].title 
        });
      }
    }
  };

  ProposalGraph.prototype.addXColumnValue = function (value) {
    if (this.xColumnValues.indexOf(value) === -1) {
      this.xColumnValues.push(value);
    }
  }

  ProposalGraph.prototype.draw = function(data) {
    this.xColumnValues = this.xColumnValues.sort();
    this.xColumnValues.unshift('x');

    this.chart = c3.generate({
      bindto: '#' + this.targetId,
      data: {
        x: 'x',
        columns: [
          this.xColumnValues,
          this.progressColumnValues,
          this.successfulColumnValues
        ]
      },
      axis: {
        y: {
          min: this.proposalSuccess * 0.1,
          max: this.proposalSuccess,
          label: { 
            text: this.supportsLabel,
            position: 'outer-middle'
          }
        },
        x: {
          type: 'category',
          tick: {
            fit: true,
            culling: {
              max: 15
            }
          }
        }
      },
      grid: {
        y: {
          lines: this.goals
        },
        x: {
          lines: this.achievements
        }
      },
      legend: {
        position: 'right'
      }
    });
  };

  $(document).ready(function () {
    $('[data-proposal-graph-url]').each(function () {
      var graph = new ProposalGraph($(this).data('proposal-graph-url'));
      graph.successfulProposalDataUrl = $(this).data('successful-proposal-graph-url');
      graph.proposalAchievementsUrl = $(this).data('proposal-achievements-url');
      graph.targetId = $(this).attr('id');
      graph.groupBy = $(this).data('proposal-graph-group-by');
      graph.progressLabel = $(this).data('proposal-graph-progress-label');
      graph.supportsLabel = $(this).data('proposal-graph-supports-label');
      graph.successLabel = $(this).data('proposal-graph-success-label');
      graph.proposalSuccess = parseInt($(this).data('proposal-success'), 10);

      graph.refresh();
    });
  });
})();
