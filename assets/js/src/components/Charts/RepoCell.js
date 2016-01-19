import React from 'react';

import BaseChart from 'components/Charts/BaseChart';

class RepoCell extends React.Component {
  repoPulse() {
    let repoContent = <div>Loading...</div>;
    if (this.props.pulse) {
      repoContent = <BaseChart type="Line" chartData={ this.props.pulse.chartData } width="1000" height="400"/>;
    }
    return repoContent;
  }

  render() {
    let repo = this.props.repo;
    return (
      <div className="col-third" key={ repo.id }>
        <div className="col-full">
          <h4>{ repo.name } [ { repo.id } ]</h4>
        </div>
        { this.repoPulse() }
      </div>
    );
  }
}

export default RepoCell;
