App.Router = Backbone.Router.extend({
  execute: function(callback, args, name) {
    if (this.authorize(name)) {
      if (callback) callback.apply(this, args);
    } else {
      this.showError('Access denied.');
    }
  },

  permissions: {
    'dashboard': [App.TeamRoles.guest, App.TeamRoles.member, App.TeamRoles.manager],
    'vacations': [App.TeamRoles.member, App.TeamRoles.admin],
    'holidays': [App.TeamRoles.guest, App.TeamRoles.member, App.TeamRoles.manager, App.TeamRoles.admin],
    'teams': [App.TeamRoles.admin],
    'users': [App.TeamRoles.admin],
    'reports': [App.TeamRoles.member, App.TeamRoles.admin]
  },

  routes: {
    'dashboard':  'dashboard',
    'vacations':  'vacations',
    'holidays':   'holidays',
    'teams':      'teams',
    'users':      'users',
    'reports':    'reports'
  },

  dashboard: function() {
    var approvalRequests = new App.Collections.ApprovalRequests(),
        availableVacations = new App.Collections.AvailableVacations(),
        holidays = new App.Collections.Holidays(),
        personalVacationRequests = new App.Collections.PersonalVacationRequests(),
        teams = new App.Collections.Teams();

    App.dashboard = new App.Views.Dashboard({
      'approvalRequests': approvalRequests,
      'availableVacations': availableVacations,
      'holidays': holidays,
      'personalVacationRequests': personalVacationRequests,
      'teams': teams,
    });

    personalVacationRequests.fetch()
      .then(function() {
        return holidays.fetch();
      })
      .then(function() {
        return teams.fetch();
      })
      .then(function() {
        return availableVacations.fetch();
      })
      .then(function() {
        return approvalRequests.fetch();
      })
      .then(function() {
        App.dashboard.render();
      });
  },

  vacations: function() {
    var availableVacations = new App.Collections.AvailableVacations(),
        holidays = new App.Collections.Holidays(),
        teamMates = new App.Collections.Users(),
        vacationApprovals = new App.Collections.VacationApprovals(),
        vacationRequests = new App.Collections.VacationRequests();

    availableVacations.url = function () {
      var userID = App.currentUser.get('id').toString();
      return 'users/'+userID+'/available_vacations';
    };

    App.vacation_requests = new App.Views.VacationRequests({
      'availableVacations': availableVacations,
      'holidays': holidays,
      'teamMates': teamMates,
      'vacationApprovals': vacationApprovals,
      'vacationRequests': vacationRequests,
    });

    availableVacations.fetch()
      .then(function() {
        return teamMates.fetch();
      })
      .then(function() {
        return holidays.fetch();
      })
      .then(function() {
        return vacationApprovals.fetch();
      })
      .then(function() {
        return vacationRequests.fetch();
      })
      .then(function() {
        App.vacation_requests.render();
      });
  },

  holidays: function() {
    var collection = new App.Collections.Holidays();
    App.holidays = new App.Views.Holidays({'collection':collection});
    collection.fetch();
  },

  reports: function() {
    var reports = new App.Collections.Reports();

    App.reports = new App.Views.Reports({
      'reports': reports
    });

    reports.fetch()
      .then(function() {
          App.reports.render();
      });
  },
  
  teams: function() {
    var roles = new App.Collections.Roles(),
        teams = new App.Collections.Teams(),
        users = new App.Collections.Users();

    App.teams = new App.Views.Teams({
      'roles':roles,
      'teams':teams,
      'users':users
    });

    roles.fetch()
      .then(function() {
        return teams.fetch();
      })
      .then(function() {
        return users.fetch();
      });
  },

  users: function() {
    var users = new App.Collections.Users();

    App.users = new App.Views.Users({
      'users': users
    });

    users.fetch()
      .then(function() {
          App.users.render();
      });
  },

  authorize: function(name) {
    var roles = App.currentUserRoles.pluck('role'),
        userHasAccessToPage = false;

    result = _.intersection(this.permissions[name], roles);
    userHasAccessToPage = _.isArray(result) && !_.isEmpty(result);
    return userHasAccessToPage;
  },

  showError: function(msg) {
    var theMessage = new App.Views.Message({
      messageType:'error',
      message:msg,
    }).render();
  },


});
