require('./ReposOverview.css');

import React from 'react';
import moment from 'moment';
import _ from 'lodash';

class ReposOverview extends React.Component {
  getCommitsOverview() {
    let content = [];
    let overviews = _.filter(this.props.overviews, (data) => {
      let repoIndex = _.findIndex(this.props.repos, (repo) => {
        return repo.id === data.repoId;
      });
      return repoIndex >= 0;
    });

    if (overviews.length > 0) {
      overviews.map((overviewData) => {
        let overview = overviewData.overview;
        let repoData = _.find(this.props.repos, (repo) => {
          return overviewData.repoId === repo.id;
        });
        let startDate = moment.unix(overview.start_timestamp).format('DD.MM.YYYY');
        let lastCommitDate = moment.unix(overview.last_commit.commit_timestamp).format('DD.MM.YYYY [at] hh:mm');
        let lastCommitInfo = overview.last_commit;
        let inlineStyle = {
          backgroundColor: repoData.color,
        };

        content.push(
          <tr key={ 'repo-overview-' + repoData.id }>
            <td style={ inlineStyle } rowSpan="2" className="repo-name"><strong>{ repoData.name }</strong></td>
            <td>{ startDate }</td>
            <td>{ overview.commit_count }</td>
            <td>{ overview.contributor_count }</td>
            <td>{ overview.lines}</td>
          </tr>
        );

        content.push(
          <tr key={ 'repo-last-commit-' + repoData.id } className="repo-last-commit">
            <td colSpan="4">
              Last commit on { lastCommitDate }: { lastCommitInfo.message }
            </td>
          </tr>
        );
      });
    }

    return content;
  }

  render() {
    let content = this.getCommitsOverview();
    if (content.length >= 0) {
      content = (
        <table className="repo-overview-table">
          <thead>
            <tr>
              <th></th>
              <th>Started</th>
              <th>Commits</th>
              <th>Contributors</th>
              <th>Lines</th>
            </tr>
          </thead>
          <tbody>
            { content }
          </tbody>
        </table>
      );
    } else {
      content = <div>Loading...</div>;
    }
    return (
      <div className="col-full">
        { content }
      </div>
    );
  }
}

export default ReposOverview;
