import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import DashboardStore from 'stores/DashboardStore';
import RepoStore from 'stores/RepoStore';
import Dashboard from 'components/Dashboard/Dashboard';

class Home extends React.Component {
  static getStores() {
    return [RepoStore, DashboardStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  render() {
    return <Dashboard { ...this.props }/>;
  }
}

export default connectToStores(Home);
