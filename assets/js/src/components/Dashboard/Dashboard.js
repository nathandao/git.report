import React from 'react';
import _ from 'lodash';

import RepoCell from 'components/Charts/RepoCell';
import HourlyCommits from 'components/Charts/HourlyCommits';
import TodayOverview from 'components/Dashboard/TodayOverview';
import ReposOverview from 'components/Dashboard/ReposOverview';
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
      let pulse = _.find(this.props.repoPulses, pulseData => {
        return pulseData.repoId === repo.id;
      });
      return <RepoCell pulse={ pulse } repo={ repo } key={ 'repo-cell-' + repo.id }/>;
    });
    return content;
  }

  render() {
    return (
      <div>
        <section>
          <div className="col-half">
            <section>
              <div className="col-third">
                <h3>Commits today</h3>
                <TodayOverview commits={ this.props.commits } visibleRepos={ this._getVisibleRepos() } />
              </div>
              <div className="col-two-third">
                <h3>Switch visibility</h3>
                <RepoSelector repos={ this.props.repos }/>
              </div>
            </section>

            <div className="col-full">
              <h3>Hourly commits</h3>
              <HourlyCommits repos={ this._getVisibleRepos() } commits={ this.props.commits }/>
            </div>
          </div>
          <div className="col-half">
            <h3>Overviews</h3>
            <ReposOverview repos={ this._getVisibleRepos() } overviews={ this.props.overviews }/>
          </div>
        </section>
        <h1>Commit counts in the past 7 days</h1>
        <section>
          { this.repoPulses() }
        </section>
      </div>
    );
  }
}

export default Dashboard;
