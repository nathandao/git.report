import React from 'react';
import _ from 'lodash';

import RepoCell from 'components/Charts/RepoCell';
// import HourlyCommits from 'components/Charts/HourlyCommits';
import TodayOverview from 'components/Dashboard/TodayOverview';
// import ReposOverview from 'components/Dashboard/ReposOverview';
import RepoSelector from 'components/RepoSelector/RepoSelector';

class Dashboard extends React.Component {
  _getVisibleRepos() {
    return _.select(this.props.repos, (repo) => {
      return repo.visible === true;
    });
  }

  repoPulses() {
    let repos = this._getVisibleRepos();
    let content = repos.map((repo) => {
      return <RepoCell commitsOverviews={ this.props.commitsOverviews } repoPulses={ this.props.repoPulses } repo={ repo } key={ 'repo-cell-' + repo.id }/>;
    });
    return content;
  }

  render() {
    return (
      <div>
        <section>
          <div className="col-third">
            <h3>Commits today</h3>
            <TodayOverview commitsData={ this.props.commits } visibleRepos={ this._getVisibleRepos() } />
          </div>
          <div className="col-two-third">
            <h3>Switch visibility</h3>
            <RepoSelector repos={ this.props.repos }/>
          </div>
        </section>
      </div>
    );
  }
}

export default Dashboard;
