import control from 'control';

import RepoActions from 'actions/RepoActions';

class DashboardStore {
  constructor() {
    this.bindListeners({
      // onFlushCaches: DashboardActions.flushCaches,
      onRequestInitData: RepoActions.requestInitData,
      onLoadInitData: RepoActions.loadInitData,
    });
    this.state = {
      loadingInitData: false,
      errorMessage: '',
    };
  }

  onRequestInitData() {
    this.setState({
      loadingInitData: true,
    });
  }

  onLoadInitData() {
    this.setState({
      loadingInitData: false,
    });
  }
}

export default control.createStore(DashboardStore, 'DashboardStore');
