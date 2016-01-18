import request from 'reqwest';
import moment from 'moment';

import RepoActions from 'actions/RepoActions';
import {
  REPOS,
  API_INIT_DATA,
//  API_REPO_LIST,
//  API_OVERVIEW,
//  API_COMMITS,
} from 'constants/api';
import { PULSE_TIME_STAMPS } from 'constants/dashboard';

class RepoServices {

  initData() {
    let startTime = moment.unix(PULSE_TIME_STAMPS[0]).format('YYYY-MM-DD 00:00');
    RepoActions.requestInitData();
    request({
      url: API_INIT_DATA,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data: { from: startTime, in: REPOS },
      success: (resp) => {
        RepoActions.loadInitData(resp);
      },
      error: (err) => {
        RepoActions.requestInitDataError(err);
      },
    });
  }

  // requestCommitsOverviews(repoIds) {
  //   repoIds.map((repoId) => {
  //     this.requestCommitsOverview(repoId);
  //   });
  // }

  // requestCommitsOverview(repoId = null) {
  //   let data = {};
  //   if (repoId !== null) {
  //     data.in = repoId;
  //   }
  //   request({
  //     url: API_COMMITS_OVERVIEW,
  //     method: 'get',
  //     type: 'json',
  //     contentType: 'application/json',
  //     data,
  //     success: (resp) => {
  //       RepoActions.loadCommitsOverview({
  //         repoId,
  //         overviewData: resp,
  //       });
  //     },
  //     error: (err) => {
  //       RepoActions.requestCommitsOverviewError(err);
  //     },
  //   });
  // }

  // requestRepoOverviews(repoId = null) {
  //   let data = {};
  //   if (repoId !== null) {
  //     data.in = repoId;
  //   }
  //   request({
  //     url: API_REPO_OVERVIEW,
  //     method: 'get',
  //     type: 'json',
  //     contentType: 'application/json',
  //     data,
  //     success: (resp) => {
  //       resp.map((repoOverview) => {
  //         RepoActions.loadCommitsOverview(repoOverview);
  //       });
  //     },
  //     error: (err) => {
  //       RepoActions.requestCommitsOverviewError(err);
  //     },
  //   });
  // }

  // requestCommits(from, til) {
  //   request({
  //     url: API_COMMITS,
  //     method: 'get',
  //     type: 'json',
  //     dataType: 'application/json',
  //     data: { from, til },
  //     success: (resp) => {
  //       RepoActions.loadCommits(resp);
  //     },
  //     error: (err) => {
  //       RepoActions.requestTodayOverviewError(err);
  //     },
  //   });
  // }

  // requestContributors(repoId = null) {
  //   let data = {};
  //   if (repoId) {
  //     data.in = repoId;
  //   }
  //   request({
  //     url: API_AUTHORS,
  //     method: 'get',
  //     type: 'json',
  //     dataType: 'application/json',
  //     data,
  //     success: (resp) => {
  //       RepoActions.loadContributors(resp);
  //     },
  //     error: (err) => {
  //       RepoActions.requestContributorsError(err);
  //     },
  //   });
  // }

  // requestHours(repoId = null) {
  //   let data = {};
  //   if (repoId) {
  //     data.in = repoId;
  //   }
  //   request({
  //     url: API_HOURS,
  //     method: 'get',
  //     type: 'json',
  //     dataType: 'application/json',
  //     data,
  //     success: (resp) => {
  //       RepoActions.loadHours(resp);
  //     },
  //     error: (err) => {
  //       RepoActions.requestHoursError(err);
  //     },
  //   });
  // }
}

export default new RepoServices();
