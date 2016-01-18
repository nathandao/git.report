import _ from 'lodash';
import moment from 'moment';

import control from 'control';
import RepoActions from 'actions/RepoActions';
import {
  PULSE_TIME_STAMPS,
  PULSE_TIME_LABELS,
} from 'constants/dashboard';

class RepoStore {
  constructor() {
    this.bindActions(RepoActions);
    this.state = {
      repos: [],
      overviews: [],
      commits: [],
      repoPulses: [],
    };
  }

  onLoadInitData(data) {
    let repos = data.repoList;
    _.forEach(repos, (repo, index) => {
      repos[index].visible = true;
      repos[index].rgb = this._hexToRgb(repo.color);
    });
    this.setState({
      repos,
      overviews: data.overview,
      commits: data.commits,
      repoPulses: this._createPulseData(data.commits, repos),
    });
  }

  onLoadRepoList(repos) {
    _.forEach(repos, (repo, index) => {
      repos[index].visible = true;
      repos[index].rgb = this._hexToRgb(repos[index].color);
    });
    this.setState({
      repos,
    });
  }

  onSwitchRepoVisibility(repoId) {
    let repos = this.state.repos;
    let repoIndex = _.findIndex(repos, (repo) => {
      return repo.id === repoId;
    });

    if (repoIndex >= 0) {
      repos[repoIndex].visible = !repos[repoIndex].visible;
      this.setState({
        repos,
      });
    }
  }

  onLoadCommitsOverview(data) {
    let overviews = this.state.commitsOverviews;
    let repoIndex = _.findIndex(overviews, (overview) => {
      return overview.repoId === data.repoId;
    });

    if (repoIndex >= 0) {
      overviews[repoIndex] = data;
    } else {
      overviews.push(data);
    }
    this.setState({
      commitsOverviews: overviews,
    });
  }

  onLoadCommits(allCommitsData) {
    let commitsData = this.state.commitsData;
    _.forEach(allCommitsData, (data) => {
      let repoIndex = _.findIndex(commitsData, (commitData) => {
        return commitData.repoId === data.repoId;
      });

      if (repoIndex >= 0) {
        commitsData[repoIndex].commits = _.uniq(_.merge(
          commitsData[repoIndex].commits,
          data.commits
        ));
      } else {
        commitsData.push(data);
      }
    });
    this.setState({ commitsData });
  }

  onLoadContributors(newContributorsData) {
    let contributorsData = this.state.contributorsData;
    _.forEach(newContributorsData, (data) => {
      let repoIndex = _.findIndex(contributorsData, (repoContributorsData) => {
        return repoContributorsData.repoId === data.repoId;
      });

      if (repoIndex >= 0) {
        contributorsData[repoIndex] = data.authors;
      } else {
        contributorsData.push(data);
      }
    });
    this.setState({ contributorsData });
  }

  onLoadHours(newHoursData) {
    let hoursData = this.state.hoursData;
    _.forEach(newHoursData, (data) => {
      let repoIndex = _.findIndex(hoursData, (repoHoursData) => {
        return repoHoursData.repoId === data.repoId;
      });

      if (repoIndex > 0) {
        hoursData[repoIndex] = data.hours;
      } else {
        hoursData.push(data);
      }
    });
    this.setState({ hoursData });
  }

  _hexToRgb(hex) {
    let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16),
    } : null;
  }

  _rgba(rgb, a) {
    return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${a})`;
  }

  _createPulseData(commits, repos) {
    let repoPulses = [];
    _.forEach(commits, commitData => {
      let repoId = commitData.repoId;
      let repo = _.find(repos, repoData => {
        return repoData.id === repoId;
      });
      let rgb = repo.rgb;
      let pulseData = {
        repoId,
        chartData: {
          labels: PULSE_TIME_LABELS,
          datasets: {
            label: 'Commit count',
            fillColor: this._rgba(rgb, 0.5),
            strokeColor: this._rgba(rgb, 1),
            pointColor: this._rgba(rgb, 1),
            data: [],
          },
        },
      };
      for (let i = 0; i < PULSE_TIME_STAMPS.length - 1; i++) {
        let commitCount = _.filter(commitData.commits, commit => {
          let timeStamp = moment(new Date(commit.author_time)).unix();
          return timeStamp >= PULSE_TIME_STAMPS[i] && timeStamp < PULSE_TIME_STAMPS[i + 1];
        }).length;
        pulseData.chartData.datasets.data.push(commitCount);
      }
      repoPulses.push(pulseData);
    });
    return repoPulses;
  }
}

export default control.createStore(RepoStore, 'RepoStore');
