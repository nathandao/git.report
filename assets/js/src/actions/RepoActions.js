import control from 'control';

class RepoActions {
  constructor() {
    this.generateActions(
      'loadRepoList',
      'requestRepoListError',
      'reorderRepos',
      'switchRepoVisibility',

      'loadCommitsOverview',
      'requestCommitsOverviewError',

      'requestCommits',
      'loadCommits',

      'loadContributors',
      'requestContributorsError',

      'loadHours',
      'requestHoursError',

      'requestInitData',
      'requestInitDataError',
      'loadInitData'
    );
  }
}

export default control.createActions(RepoActions);
